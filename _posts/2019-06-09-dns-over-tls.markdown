---
layout: post
title:  "DNS over TLS"
date:   Sun, 09 Jun 2019 16:33:47 -0700
tags:
  - DNS
  - TLS
  - ubiquiti
  - edgerouter
  - unbound
---

When I'm not programming, sometimes I like to find small sysadmin-like projects to do for my home network. They're less work and I don't have to get in the zone to do them. One thing I had been wanting to do for a while was set up DNS over TLS.

In a nutshell, in a typical home internet setup, you ask your internet service provider (ISP) for an IP address and a DNS server. The DNS server lets your computer look up the IP address (from a name) when you want to connect to another computer on the internet. Some ISPs have slow DNS service, which means there might be some lag or latency when you connect to a website for the first time (the name to IP gets cached for a bit after a request). Some power users sometimes override the ISP's DNS server with from Google (8.8.8.8), Cloudflare (1.1.1.1), or quad9 (9.9.9.9), etc. That might help with lag.

Whatever you choose, that traffic isn't encrypted, so everyone between you and the DNS server gets to see what name you are requesting. ISPs will obviously see it since it goes through them regardless of which DNS server you use, and maybe they'll learn your interests and sell your data to advertisers. So, for whatever reason, you may decide to setup DNS over TLS so that you can encrypt the requests so that just the DNS server will see them.

At home, I have an [Ubiquiti EdgeRouter Lite](https://www.ui.com/edgemax/edgerouter-lite/) as my internet router. I found some instructions on how to set it up [on this blog](https://www.chameth.com/2017/12/17/dns-over-tls-on-edgerouter-lite/).

I'll summarize below in case that site goes offline someday. This assumes your router is 10.0.0.1 and you give out IP addresses on 10.0.0.0/24 (I haven't tested this):

```sh
ssh ubnt@10.0.0.1
sudo apt-get update && sudo apt-get install -y unbound
sudo wget ftp://FTP.INTERNIC.NET/domain/named.cache -O /var/lib/unbound/root.hints
configure
set system name-server 127.0.0.1
set service dhcp-server shared-network-name YOUR-NETWORK-NAME-HERE subnet 10.0.0.0/24 dns-server 10.0.0.1
set service dhcp-server use-dnsmasq disable
set service dns
commit
save
exit
sudo /etc/init.d/unbound restart
```

Below is my `/etc/unbound/unbound.conf` which forwards to 9.9.9.9.

```yaml
server:
    auto-trust-anchor-file: "/var/lib/unbound/root.key"
    verbosity: 1
    interface: 0.0.0.0
    interface: ::0
    port: 53
    do-ip4: yes
    do-ip6: yes
    do-udp: yes
    do-tcp: yes
    access-control: 127.0.0.0/8 allow
    access-control: 10.0.0.0/8 allow
    root-hints: "/var/lib/unbound/root.hints"

    hide-identity: yes
    hide-version: yes
    harden-glue: yes
    harden-dnssec-stripped: yes

    cache-min-ttl: 900
    cache-max-ttl: 14400
    prefetch: yes
    rrset-roundrobin: yes
    ssl-upstream: yes
    use-caps-for-id: yes

    private-address: 192.168.0.0/16
    private-address: 172.16.0.0/12
    private-address: 10.0.0.0/8

    #logfile: "/var/lib/unbound/unbound.log"
    verbosity: 0
    val-log-level: 3

forward-zone:
    name: "."
    forward-addr: 9.9.9.9@853
```

Hopefully home routers in the future will make it easier to set up.
