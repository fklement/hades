<p align=center><img src="logo.png" width="350px"></p>

[![hex.pm version](https://img.shields.io/hexpm/v/hades.svg?style=flat)](https://hex.pm/packages/hades)
[![Build Status](https://travis-ci.com/fklement/hades.svg?branch=master)](https://travis-ci.com/fklement/hades)
[![hex.pm downloads](https://img.shields.io/hexpm/dt/hades.svg?style=flat)](https://hex.pm/packages/hades)
[![hex.pm licence](https://img.shields.io/hexpm/l/hades.svg?style=flat)](https://hex.pm/packages/hades)

A wrapper for `NMAP` written in [Elixir](http://elixir-lang.org/).
> Used version: Nmap 7.80 

Nmap (network mapper), the god of port scanners used for network discovery and the basis for most security enumeration during the initial stages of a penetration test. The tool was written and maintained by Fyodor AKA Gordon Lyon.

Nmap displays exposed services on a target machine along with other useful information such as the verion and OS detection.

Nmap has made twelve movie appearances, including The Matrix Reloaded, Die Hard 4, Girl With the Dragon Tattoo, and The Bourne Ultimatum.

Documentation: https://hexdocs.pm/hades   
    

> **INFO**:   
> `Hades` is still under development and by far not complete. Feel free to contribute.  
> See [General Informations](##General-Informations) for more about this project

## Installation

To use Hades in your Mix projects, first add Hades as a dependency.

```elixir
def deps do
  [
    {:hades, "~> 0.0.1"},
  ]
end
```


## Prerequisites

[NMAP](https://nmap.org) must be installed.

### Add nmap command to sudoers

Some of the `NMAP` commands require `sudo` to be executed.
In order to process such commands with `Hades` you need to add those commads.  
The following shows an example on how to add one to sudoers:
```sh
Cmnd_Alias NMAP = /usr/bin/nmap -n -oG - -sU -p *

%wheel ALL=(root) NOPASSWD: NMAP

Defaults!NMAP !requiretty
```

If you want to know more about `NMAP sudo` behaviour you can find a thread on `SuperUser` here:  
[different behavior: “sudo nmap” vs just “nmap”?](https://superuser.com/questions/887887/different-behavior-sudo-nmap-vs-just-nmap)


## Configuration

You can optionally specify the `timeout` and the `output_path` in `config.exs`:

```elixir
config :hades, timeout: 20_000
config :hades, output_path: "/path/to/your/desired/output/folder"
```

The `timeout` is specified in milliseconds. 
If unspecified, return the default `timeout` which is currently `300_000` (corresponds to 5 minutes).
This `timeout` is propagated to the function `Task.await()`.
If the specified `timeout` period is exceeded, it is assumed that the process running the NMAP command has timed out.

The `output_path` is the place where the XML output of the executed `NMAP` command gets stored.
If there is nothing specified in the config then the default path (which is located in the `tmp` folder) will be returned.

## Examples

### Simple ping scan
The snippet below ping scans the network, and lists the target machine if it responds to ping.
```elixir
iex> Hades.new_command()
...> |> Hades.add_argument(Hades.Arguments.ScanTechniques.arg_sP())
...> |> Hades.add_target("192.168.120.42")
...> |> Hades.scan()
12:19:25.739 [info]  NMAP Output: "Starting Nmap 7.80 ( https://nmap.org ) at 2020-02-07 12:19 CET\n"

12:19:25.788 [info]  NMAP Output: "Nmap scan report for Felix-MACNCHEESEPRO.root.box (192.168.120.42)\nHost is up (0.00045s latency).\n"

12:19:25.788 [info]  NMAP Output: "Nmap done: 1 IP address (1 host up) scanned in 0.06 seconds\n"

12:19:25.789 [info]  Port exit: :exit_status: 0

12:19:25.789 [info]  EXIT

12:19:25.790 [info]  DOWN message from port: #Port<0.14>
%{
  hosts: [
    %{hostname: "Felix-MACNCHEESEPRO.root.box", ip: "192.168.120.42", ports: []}
  ],
  time: %{
    elapsed: 0.06,
    endstr: "Fri Feb  7 12:19:25 2020",
    startstr: "Fri Feb  7 12:19:25 2020",
    unix: 1581074365
  }
}
```
> **INFO**: Currently only standard single IPv4 specified targets are supported. In the future I'll add support for IPv4 ranges specified with a subnetmask.
> This will enable the functionality to scan targets in a specified IP range.

### Using the script argument
The execution of `nmap -sV -version-all -script vulners` in `Hades` looks like the following:
```elixir
iex> Hades.new_command()
...> |> Hades.add_argument(arg_sV())
...> |> Hades.add_argument(arg_version_all())
...> |> Hades.add_argument(arg_script("vulners"))
...> |> Hades.add_target("192.168.120.87")
...> |> Hades.scan()
12:25:13.092 [info]  NMAP Output: "Starting Nmap 7.80 ( https://nmap.org ) at 2020-02-07 12:25 CET\n"

12:25:47.026 [info]  NMAP Output: "Nmap scan report for batavis (192.168.120.87)\n"

12:25:47.030 [info]  NMAP Output: "Host is up (0.0076s latency).\nNot shown: 994 closed ports\nPORT ... CPE: cpe:/o:linux:linux_kernel\n\n"

12:25:47.031 [info]  NMAP Output: "Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .\nNmap done: 1 IP address (1 host up) scanned in 33.97 seconds\n"

12:25:47.060 [info]  Port exit: :exit_status: 0

12:25:47.060 [info]  EXIT

12:25:47.060 [info]  DOWN message from port: #Port<0.26>
%{
  hosts: [
    %{
      hostname: "batavis",
      ip: "192.168.120.87",
      ports: [
        %{
          name: "ssh",
          output: [],
          port: 22,
          product: "OpenSSH",
          script: [],
          state: "open",
          version: "7.4p1 Raspbian 10+deb9u6"
        },
        %{
          name: "domain",
          output: [],
          port: 53,
          product: "dnsmasq",
          script: [],
          state: "open",
          version: "pi-hole-2.80"
        },
        %{
          name: "http",
          output: [],
          port: 80,
          product: "Node.js Express framework",
          script: [],
          state: "open",
          version: ""
        },
        %{
          name: "http",
          output: ['Problem with XML parsing of /evox/about'],
          port: 3000,
          product: "Mongoose httpd",
          script: ["http-trane-info"],
          state: "open",
          version: ""
        },
        %{
          name: "http",
          output: ['lighttpd/1.4.45',
           '\ncpe:/a:lighttpd:lighttpd:1.4.45: \nCVE-2018-19052\t5.0\thttps://vulners.com/cve/CVE-2018-19052'],
          port: 8042,
          product: "lighttpd",
          script: ["http-server-header", "vulners"],
          state: "open",
          version: "1.4.45"
        }
      ]
    }
  ],
  time: %{
    elapsed: 33.97,
    endstr: "Fri Feb  7 12:25:47 2020",
    startstr: "Fri Feb  7 12:25:13 2020",
    unix: 1581074747
  }
}
```
Here the [nmap-vulners](https://github.com/vulnersCom/nmap-vulners) NSE script is used to provide informations on vulnerabilities of well-known services that are running on the target host.

## General Informations

I started implementing this wrapper because I needed to reliably execute 'NMAP' commands in an 'Elixir/Phoenix' project.
Currently not 100% of the `NMAP` functionality is implemented, because the current state is sufficient for the current project. 
But I will complete the functionality as soon as I find the time. 
In the meantime, if anyone would like to add anything, feel free to do so.

## Release notes

See the [changelog](CHANGELOG.md) for changes between versions.

## Disclaimer

Hades is not affiliated with nor endorsed by the NMAP project.

NMAP was created and is mainted by [Gordon Lyon](https://insecure.org/fyodor/).
You can contact him via fyodor@nmap.org.

Some of the documentation parts were copyed from the linux man pages [nmap(1) - Linux man page](https://linux.die.net/man/1/nmap)

