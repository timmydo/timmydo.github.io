---
layout: post
title:  "Email with aerc, offlineimap, systemd, and emacs"
date:  Sat, 18 Jan 2020 21:19:55 -0800
tags:
  - aerc
  - offlineimap
  - linux
  - systemd
---

I recently moved my primary desktop computer to [Ubuntu 19.10](https://ubuntu.com/) running [Sway](https://swaywm.org/) without xwayland. It's a limited experience at this point, because a lot of apps still require X11 support (VS Code, Chromium, etc.). I'm hoping to get a custom build of Chromium and Electron with ozone wayland, but in the meantime, Firefox works and actually everything else I can run in a terminal window. GNOME apps also work. Other than a few minor issues with Firefox (cursor hand icon appearing when hovering over links), everything is nice and smooth.

Since you can spend a lifetime customizing everything to your liking, I thought I'd write out how I set up my email. The unix way is to use a lot of small, purpose-built programs and stitch things together, and I've found that to be the best way for me to handle email. I look forward to having better integration with the [git send email](https://git-send-email.io/) workflow.

For reading email, I'm currently trying out [aerc](https://aerc-mail.org/). It runs in the terminal. I set it to use emacs as the editor as I'm not a fan of vi. My [config](https://github.com/timmydo/config/tree/master/aerc) isn't really that interesting so far--I've just changed some bindings and set address completion to grep an address book file. So far aerc has been a little buggy, and was slow when reading directly from IMAP, so I setup [offlineimap](https://www.offlineimap.org/) to download emails locally in [Maildir](https://en.wikipedia.org/wiki/Maildir) format. This seems like the right thing to do: have a bunch of apps that work together using file abstractions (treating email as files). Maybe I'll eventually set up [Notmuch](https://notmuchmail.org/) to go through my email. About 15 years ago I used [Gnus](https://en.wikipedia.org/wiki/Gnus) for email (and before that, mutt), but this time I wanted to try something more UNIXy and less Emacs Lisp OS.

My offlineimap [config](https://github.com/timmydo/config/tree/master/offlineimap) is pretty straightforward. When you run offlineimap, it sort of behaves like an `rsync` over IMAP. But it doesn't really do the daemon thing, or at least it recommends that you set that up with systemd. The [systemd config](https://github.com/timmydo/config/tree/master/systemd/user) is basically taken straight from the offlineimap docs which I found by running `dpkg -L offlineimap`. It makes sure I have each account running a sync every 5 minutes. I read some reviews that isync/mbsync is faster than offlineimap, but that hasn't really bothered me yet.

For passwords, I moved to [pass](https://www.passwordstore.org/) from [keepass](https://keepass.info/). I didn't see any keepass clients that would work in Sway, and it's nifty having one that works in the terminal and uses gnupg under the covers. The offlineimap config has a custom python script that calls gpg to decrypt the email passwords.

