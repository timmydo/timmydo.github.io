---
layout: post
title:  "Pinephone review"
date:  Sun, 23 Feb 2020 10:23:55 -0800
tags:
  - pinephone
  - pine64
  - linux
  - phone
---

Back in December, I bought a [PinePhone](https://www.pine64.org/pinephone). It's a $150 (USD) phone with hardware that more "free" (free as in free software/freedom/open source) than a typically phone, but less than something that aims to be totally pure like [Purism's Librem 5](https://puri.sm/products/librem-5). So it's a lot more approachable--coming a lot closer to an impulse buy for someone who wants to support the cause. I do enjoy having full control of what software I'd like to run on my phone. It's a unique experience to be able to ssh into your phone and send a SMS message through the command line. But novelties aside, to become the daily-driver phone, it needs to be able to handle the essentials. This isn't the fault of the hardware, and I think the high price of the Librem phone shows how much it costs to get software working.

The phone arrived a couple of weeks ago and I installed a couple of different distros to SD cards to test:

1. ubuntu touch / UBports
1. postmarketOS (plasma mobile)
1. manjaro-arm

Ubuntu touch's UI is probably the furthest along, but I can't tell from the forums I've looked at if it's still getting much active development as the others. Some weird things were broken on the image I tried--like the current time was set to the unix epoch.

PostmarketOS seems to be pretty active in the forums and on IRC. The first plasma mobile release I tried was pretty broken. Overlapping text in the UI, the power button shut down the OS, wifi wouldn't work reliably because of some keyring issue. The latest build fixes all that. It might be the most up to date with the pinephone hardware.

Marjaro-arm is probably in the middle of UBPorts and postmarketOS. Wifi works. Mobile data works after I ran a script from the terminal.


Right now, hardware-wise, they're roughly in the same state--they can't make/receive phone calls for general users. So no, they are not ready to be a daily-driver phone. Let me try to lay out different tiers of features that I'd want in a phone:


### Freedom hardware features

I thought I'd put this category at the top because it's a list of features that we don't have on any of the major smartphones released nowadays:

1. Open hardware / drivers. Running the latest Linux kernel.
1. Running software you choose (unless you jailbreak your other device... but then it's probably just sideloading something small than replacing everything)
1. Removable and replacable battery
1. Hardware kill switches
1. Micro SD Card, capabilty to boot from SD
1. Headphone jack (I don't use it, but some people are passionate about it)

You get these with the pinephone.

### Dumb phone features

We aren't there yet. But it should just be a matter of fixing the software. I need to investigate the charging issue more.

1. Charging should work. I didn't take this for granted until I got this phone. I'm able to charge it sometimes with a quick charge compatible charger, but it doesn't seem to charge with USB-PD or a low powered USB cable.
1. All-day batter life. I can't really use a phone that drains its battery in a couple of hours even if it's not being used. Especially if it's finnicky with charging. We might be able to get there just by underclocking it when it's not in use?
1. Make calls. I think people have been able to do this--I'd hope to see this for everyone in the next month.
1. Receive calls. This probably requires some more UI work, but I'd imagine it'd mostly be there already since this isn't the first phone.
1. Send SMS. I think this is mostly working. Some distros require you to manually enable the modem so this is probably mostly usability fixes at this point.
1. Receive SMS. Probably as easy as the previous one.
1. Camera. I don't think anyone is looking at this now. I can probably get by without one.
1. Contact list management. This probably requires some UI work, but nothing related to phone hardware so it's not a worry. I could always carry a contact list in a text file to work around...


### Feature phone features

1. Wifi. This works in the distros I've tried.
1. Lock screen. This works also, although I haven't see one lock on startup yet. Not that this would keep much secure given everything is on an easily removable unencrypted SD card.
1. Bluetooth. I haven't tested this yet. Would be necessary to receive calls in my car or listen to podcasts.
1. GPS/Maps. I haven't tested this yet. Probably not essential for me--my car has GPS/maps.
1. Web browser. The ones I've used so far are probably feature phone-level. I haven't tried complicated sites.


### Smart phone features

1. Web browser. This probably needs to be fairly polished and GPU-accelerated since it would need to be able to replace most of the apps.
1. Fingerprint or face unlock. Missing hardware, but not a show stopper.
1. NFC payments. Missing hardware, but not a show stopper.
1. Email. Might be able to use a web browser here, but this might be tough to get right.

### Smart phone apps

Here are some things I'd probably need to find a replacement for, but could probably live without.

1. Personal messenger. Skype (or another non-SMS messenger)
1. Work messenger. Microsoft Teams, Slack, etc.
1. YouTube (sort of the de facto way to watch something interesting but not a full show or movie)
1. Google Photos. Not sure if I'll need a photo upload tool if the camera doesn't work.
1. Maps
1. Nest
1. NY Times/Google feed
1. Podcasts
1. Authenticator (for GitHub, Work 2FA, etc.)
1. Password manager (Keepass, etc.)
1. Google Voice. (Keep my actual phone number separate from my current SIM card)
1. Calendar
1. Fast food apps
1. Uber/Lyft. I guess someone else will pay
1. Encrypted storage. The hardware doesn't have a TPM, but a good boot password might be enough for daily use. Probably a blocker for storing important passwords or personal data on the device
