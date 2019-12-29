---
layout: post
title:  "Building Linux Images with cloud-init"
date:  Sun, 29 Dec 2019 13:57:14 -0800
tags:
  - cloud-init
  - pmbootstrap
  - linux
  - postmarketos
---

In my last blog post, I mentioned how I wanted to create a FOSS Linux phone for fun. I ordered a phone from a company that is trying to make [open source smart phones](https://www.pine64.org/pinephone/). While that is in the mail, I thought I'd do some research on what kind of Linux distro I could put on it. The main article I read that got me excited about it was [this review of the PinePhone](https://drewdevault.com/2019/12/18/PinePhone-review.html).

I've been using Windows professionally for the last 7 years, so actually a lot has happened since I last used it. Two big things that are now here are [Wayland](https://en.wikipedia.org/wiki/Wayland_%28display_server_protocol%29) and [systemd](https://www.freedesktop.org/wiki/Software/systemd/). From my experience so far, I like both more than their predecessors.


The review I mentioned above talks about [postmarketOS](https://postmarketos.org/). I downloaded pmbootstrap from git and took a look at the code. It was a fairly impressive python project to create chroots and bootstrap an OS image from scratch. postmarketOS based on Alpine linux, which uses [OpenRC](https://en.wikipedia.org/wiki/OpenRC) rather than systemd. I tried a few different configurations through qemu (weston, KDE plasma mobile, phosh) with varying degrees of success. I hit an old bug where my `/etc/resolv.conf` from my host Ubuntu machine was copied into the phone, which uses systemd's local 127.0.0.53 resolver, which didn't work in the qemu instance. One machine I tried from didn't have accelerated graphics, which also caused its own set of issues.

I decided to stop playing with [pmbootstrap](https://gitlab.com/postmarketOS/pmbootstrap) and looked at options for how I might create something similar (being fully aware that Linux isn't on the desktop in 2019 because no one can agree on anything--whether it's systemd vs openrc, gnome vs kde, free vs open source, snap vs flatpak, glibc vs musl, etc.). Maybe Linux won on mobile because Android was less fragmented in that respect.

Anyways, so I came back to reading about [debootstrap](https://wiki.debian.org/Debootstrap), because I remembered it was the Debian equivalent to pmbootstrap, but it didn't feel as effortless when I was going through old documentation. I remembered coming across [cloud-init](https://cloud-init.io/) previously and thought that might make a better alternative. There are basically two ways you could do it--you could have a bunch of custom scripts that distro builders use to create a distro, or you could start with a finished distro image that has cloud-init installed, and then use those hooks to customize what you want.

I think using cloud-init would be the more supported way now-a-days to customize a distro, so here is basically how I did it. Mostly taken from [the cloud-init nocloud docs](https://cloudinit.readthedocs.io/en/latest/topics/datasources/nocloud.html).

Create `user-data.yaml`:

Replace `timmy` with your username.
Replace the `passwd` with the output from running `mkpasswd --method=SHA-512`.
Replace the `ssh_authorized_keys` with output from `ssh-add -L`.

```yaml
#cloud-config
users:
  - name: timmy
    lock_passwd: False
    sudo: ALL=(ALL) ALL
    passwd: "$6$H75nZXChcglVn$OFTJP885tC9ukX6.N9DbVsUmSDiMCkKhCM2U0nUt1TfSEbFTwREOEydJ0jSA2c3pV9cjy2DSQ2bHjiHC9LehL0"
    ssh_authorized_keys:
      - "ssh-rsa 123 timmy@machine1"
    groups: users
password: passw0rd
ssh_pwauth: True
```

Create `meta-data.yaml`:

```yaml
instance-id: local01
local-hostname: cloudimg
```

Download Debian:

```sh
curl -Lo debian-arm64.qcow2 'https://cdimage.debian.org/cdimage/openstack/current/debian-10.2.0-openstack-arm64.qcow2'
```

Create the seed.img with the yaml configuration files:

```sh
cloud-localds -v seed.img user-data.yaml meta-data.yaml
```

Try it in [qemu](https://www.qemu.org/):

```sh
qemu-system-aarch64 -m 2G -M virt -cpu cortex-a53 \
	-bios /usr/share/qemu-efi-aarch64/QEMU_EFI.fd \
	-drive if=none,file=debian-arm64.qcow2,id=hd0 -device virtio-blk-device,drive=hd0 \
	-drive if=none,file=seed.img,format=raw,id=cidata -device virtio-blk-device,drive=cidata \
	-device e1000,netdev=net0 -netdev user,id=net0,hostfwd=tcp:127.0.0.1:5555-:22 \
	-nographic
```

You should be able to login at the prompt. (If you didn't change anything, try `timmy` and `password`)
