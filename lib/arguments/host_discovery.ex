defmodule Hades.Arguments.HostDiscovery do
  @moduledoc """
  One of the very first steps in any network reconnaissance mission is to reduce a (sometimes huge) set of IP ranges into a list of active or interesting hosts. Scanning every port of every single IP address is slow and usually unnecessary. Of course what makes a host interesting depends greatly on the scan purposes. Network administrators may only be interested in hosts running a certain service, while security auditors may care about every single device with an IP address. An administrator may be comfortable using just an ICMP ping to locate hosts on his internal network, while an external penetration tester may use a diverse set of dozens of probes in an attempt to evade firewall restrictions.

  Because host discovery needs are so diverse, Nmap offers a wide variety of options for customizing the techniques used. Host discovery is sometimes called ping scan, but it goes well beyond the simple ICMP echo request packets associated with the ubiquitous ping tool. Users can skip the ping step entirely with a list scan (-sL) or by disabling ping (-Pn), or engage the network with arbitrary combinations of multi-port TCP SYN/ACK, UDP, SCTP INIT and ICMP probes. The goal of these probes is to solicit responses which demonstrate that an IP address is actually active (is being used by a host or network device). On many networks, only a small percentage of IP addresses are active at any given time. This is particularly common with private address space such as 10.0.0.0/8. That network has 16 million IPs, but I have seen it used by companies with less than a thousand machines. Host discovery can find those machines in a sparsely allocated sea of IP addresses.

  If no host discovery options are given, Nmap sends an ICMP echo request, a TCP SYN packet to port 443, a TCP ACK packet to port 80, and an ICMP timestamp request. These defaults are equivalent to the -PE -PS443 -PA80 -PP options. An exception to this is that an ARP scan is used for any targets which are on a local ethernet network. For unprivileged Unix shell users, the default probes are a SYN packet to ports 80 and 443 using the connect system call.. This host discovery is often sufficient when scanning local networks, but a more comprehensive set of discovery probes is recommended for security auditing.

  The -P* options (which select ping types) can be combined. You can increase your odds of penetrating strict firewalls by sending many probe types using different TCP ports/flags and ICMP codes. Also note that ARP discovery (-PR). is done by default against targets on a local ethernet network even if you specify other -P* options, because it is almost always faster and more effective.

  By default, Nmap does host discovery and then performs a port scan against each host it determines is online. This is true even if you specify non-default host discovery types such as UDP probes (-PU). Read about the -sn option to learn how to perform only host discovery, or use -Pn to skip host discovery and port scan all target hosts.
  """
  alias Hades.Argument
  require Hades.Helpers

  @known_options %{
    sL: %Argument{
      name: "-sL",
      context: :scan_type,
      desc: "List Scan - simply list targets to scan"
    },
    sn: %Argument{name: "-sn", context: :scan_type, desc: "Ping Scan - disable port scan"},
    Pn: %Argument{
      name: "-Pn",
      context: :scan_type,
      desc: "Treat all hosts as online -- skip host discovery"
    },
    PS: %Argument{
      name: "-PS",
      context: :scan_type,
      options: true,
      desc: "TCP SYN discovery to given ports"
    },
    PA: %Argument{
      name: "-PA",
      context: :scan_type,
      options: true,
      desc: "ACK discovery to given ports"
    },
    PU: %Argument{
      name: "-PU",
      context: :scan_type,
      options: true,
      desc: "UDP discovery to given ports"
    },
    PY: %Argument{
      name: "-PY",
      context: :scan_type,
      options: true,
      desc: "SCTP discovery to given ports"
    },
    PE: %Argument{
      name: "-PE",
      context: :scan_type,
      desc: "ICMP echo request discovery probes"
    },
    PP: %Argument{
      name: "-PP",
      context: :scan_type,
      desc: "Timestamp request discovery probes"
    },
    PM: %Argument{
      name: "-PM",
      context: :scan_type,
      desc: "Netmask request discovery probes"
    },
    PO: %Argument{
      name: "-PO",
      context: :scan_type,
      options: true,
      desc: "IP Protocol Ping"
    },
    n: %Argument{
      name: "-n",
      context: :scan_type,
      desc: "Never do DNS resolution [default: sometimes]"
    },
    R: %Argument{
      name: "-R",
      context: :scan_type,
      desc: "Always resolve [default: sometimes]"
    },
    dns_servers: %Argument{
      name: "--dns-servers",
      context: :option,
      options: true,
      desc: "Specify custom DNS servers"
    },
    system_dns: %Argument{
      name: "--system-dns",
      context: :option,
      desc: "Use OS's DNS resolver"
    },
    raceroute: %Argument{
      name: "--traceroute",
      context: :option,
      desc: "Trace hop path to each host"
    }
  }

  Hades.Helpers.option_functions(@known_options)
end
