---
layout: post
title:  "Parallel async tasks in C#"
date:   Sat, 08 Jun 2019 13:24:08 -0700
tags:
  - C#
  - async
  - tasks
  - parallel
---
I recently came upon the need to write some code that downloaded a bunch of smallish files from azure blob storage. The first http request would download a JSON manifest file, which has a list of 100k+ files, then I want to download a subset of them (like 60k files).

The original code looked sort of like this (it was probably written to download 10-100 files):

```cs
var tasks = files.Select(file => DownloadAsync(file));
await Task.WhenAll(tasks);
```

The issue with the above code is that it will choke if you have thousands of files--once `Task.WhenAll` starts awaiting on too many tasks at once, some of the later http requests start to time out. The reason I'm writing this post was because it took a while to find a good answer on [stack overflow](https://stackoverflow.com/questions/45717447/concurrent-requests-with-httpclient-take-longer-than-expected).

The download function looks like this. This uses the [Polly library](https://github.com/App-vNext/Polly). It might be worth refactoring this to reuse the policy instead of creating a new one for each `ExecuteAsync`:

```cs
private async Task Download(string sasurl, string localpath)
{
    await Policy
        .Handle<HttpRequestException>()
        .Or<SocketException>()
        .Or<IOException>()
        .Or<TaskCanceledException>()
        .WaitAndRetryAsync(10,
            retryAttempt => TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)),
            (e, t) =>
            {
                Console.WriteLine($"Exception {e} on {sasurl} -> {localpath}");
                if (File.Exists(localpath))
                {
                    File.Delete(localpath);
                }
            })
        .ExecuteAsync(async () =>
        {
            using (var blob = await _contentClient.GetStreamAsync(sasurl))
            using (var fileStream = new FileStream(localpath, FileMode.CreateNew))
            {
                await blob.CopyToAsync(fileStream);
            }
        });
}
```

The parallel version of the code looks like this (`DownloadGrouping` calls `Download` and copies to the identical files):

```cs
var uniqueBlobs = _files.GroupBy(keySelector: file => file.Blob.Id, resultSelector: (key, file) => file).ToList();
var throttler = new ActionBlock<IEnumerable<VstsFile>>(list => DownloadGrouping(list, localDestination), new ExecutionDataflowBlockOptions { MaxDegreeOfParallelism = ConcurrentDownloadCount });

foreach (var grouping in uniqueBlobs)
{
    throttler.Post(grouping);
}

throttler.Complete();
await throttler.Completion;
```

The key here is that this `ActionBlock` construct will keep `MaxDegreeOfParallelism` tasks running, whereas batching it manually with groups and `Task.WhenAll` means you might have times where you're waiting for one task to finish before starting the next batch.
