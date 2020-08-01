---
layout: post
title:  "Home office renovation"
date:  Sat, 01 Aug 2020 14:21:53 -0700
tags:
  - audio
  - home office
---

It's been a month since my last post and I wanted to write about
something but I haven't really tinkered with any new technology in the
last month other than buying a Raspberry Pi 4 kit off Amazon. It's touted as a
$35 computer but when you buy a kit with 8GB RAM, a case/fan, a preformatted
SD-card, etc. etc. you end up spending more like $135. For most simple
web-based tasks, it's probably enough procesing power. I think you'd
probably want a network-based hard drive for storing real files. I
ended up putting this in my fstab to connect to my NAS:

```
//<ip.address>/scratch /mnt/scratch cifs user=timmy,uid=1000,gid=1000,rw,dir_mode=0775,file_mode=0775 0 0
```

Anyways the point of this post was to follow up on my Audio 101 post--I bought
some speakers but to get the most out of them I needed some room
treatment. My home office had a pretty strong echo because there
wasn't anything on the walls or floor. I bought some bass traps ($60-ish) and
acoustic foam ($100) and nailed it into the wall with T-Pins (you'd get these
at a craft store for like $4). I was looking at glue also, but this seemed
better. Removable glue options seemed like more labor and more
difficult to keep the foam attached to the wall. I put some on the
ceiling also. I understand the way I covered the walls might not be
the best for sound, but I ended up going more for form over
function. It's a little tacky, but much more interesting than the
white walls that were there before.


![Home office picture](/assets/homeoffice-2020-08-01.png)

- Kinesis Advantage Qwerty-Dvorak
- Razer DeathAdder Chroma/Elite
- Razer Goliathus Extended Control Soft Gaming Mouse Mat
- GeekDesk v3 (right)
- KEF LSX Speakers (position adjusted since picture)
- Monitor: Two Dell U3415W 34-inch Curved LED-Lit Monitor
- White PC (2017): Intel Core i7-7700K, 32GB, Samsung 960 EVO 1TB, 1080 Ti
- Black PC (2013): Intel Core i5-4570, 16GB, home NAS, Furman PST-8 (new)
- Schiit Modi/Magni and Modi/Vali 2 for Senheisser HD6XX and
  beyerdynamic DT 990 600Ohm (not pictured)


Maybe I should clean up the wires next.
