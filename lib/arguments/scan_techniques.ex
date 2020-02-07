defmodule Hades.Arguments.ScanTechniques do
  @moduledoc """
  As a novice performing automotive repair, I can struggle for hours trying to fit my rudimentary tools (hammer, duct tape, wrench, etc.) to the task at hand. When I fail miserably and tow my jalopy to a real mechanic, he invariably fishes around in a huge tool chest until pulling out the perfect gizmo which makes the job seem effortless. The art of port scanning is similar. Experts understand the dozens of scan techniques and choose the appropriate one (or combination) for a given task. Inexperienced users and script kiddies,. on the other hand, try to solve every problem with the default SYN scan. Since Nmap is free, the only barrier to port scanning mastery is knowledge. That certainly beats the automotive world, where it may take great skill to determine that you need a strut spring compressor, then you still have to pay thousands of dollars for it.

  Most of the scan types are only available to privileged users.. This is because they send and receive raw packets,. which requires root access on Unix systems. Using an administrator account on Windows is recommended, though Nmap sometimes works for unprivileged users on that platform when WinPcap has already been loaded into the OS. Requiring root privileges was a serious limitation when Nmap was released in 1997, as many users only had access to shared shell accounts. Now, the world is different. Computers are cheaper, far more people have always-on direct Internet access, and desktop Unix systems (including Linux and Mac OS X) are prevalent. A Windows version of Nmap is now available, allowing it to run on even more desktops. For all these reasons, users have less need to run Nmap from limited shared shell accounts. This is fortunate, as the privileged options make Nmap far more powerful and flexible.

  While Nmap attempts to produce accurate results, keep in mind that all of its insights are based on packets returned by the target machines (or firewalls in front of them). Such hosts may be untrustworthy and send responses intended to confuse or mislead Nmap. Much more common are non-RFC-compliant hosts that do not respond as they should to Nmap probes. FIN, NULL, and Xmas scans are particularly susceptible to this problem. Such issues are specific to certain scan types and so are discussed in the individual scan type entries.

  This section documents the dozen or so port scan techniques supported by Nmap. Only one method may be used at a time, except that UDP scan (-sU) and any one of the SCTP scan types (-sY, -sZ) may be combined with any one of the TCP scan types. As a memory aid, port scan type options are of the form -sC, where C is a prominent character in the scan name, usually the first. The one exception to this is the deprecated FTP bounce scan (-b). By default, Nmap performs a SYN Scan, though it substitutes a connect scan if the user does not have proper privileges to send raw packets (requires root access on Unix) or if IPv6 targets were specified. Of the scans listed in this section, unprivileged users can only execute connect and FTP bounce scans.
  """
  alias Hades.Argument
  require Hades.Helpers

  @known_options %{
    sS: %Argument{name: "-sS", context: :scan_type, desc: "TCP SYN"},
    sT: %Argument{name: "-sT", context: :scan_type, desc: "Connect()"},
    sA: %Argument{name: "-sA", context: :scan_type, desc: "ACK"},
    sW: %Argument{name: "-sW", context: :scan_type, desc: "Window"},
    sM: %Argument{name: "-sM", context: :scan_type, desc: "Maimon scans"},
    sU: %Argument{name: "-sU", context: :scan_type, desc: "UDP Scan"},
    sP: %Argument{name: "-sP", context: :scan_type, desc: "Ping Scan"}
  }

  Hades.Helpers.option_functions(@known_options)
end
