# SBD
As a post exploitation tool, this script is designed to give the user access to Linux utilities that may otherwise be unavailabe on a compromised system.

Besides including [BusyBox](https://busybox.net/about.html), SBD also provides functionality to download static binaries for net utilities namely; Ncat, Socat, Nmap, and Ngrok.

## Usage

After a system has been succesfully compromised `wget` or `git` SBD to the system in question, depending on what's available. From there making it executable and running it with `chmod +x sbd.sh && ./sbd.sh` should bring you to a menu. The options for which are as follows;

```
1) Help			 4) Deploy BusyBox	  7) Quit
2) Set Outpath		 5) Deploy Net Utilities
3) Deploy All		 6) Clean up

```
The `Help` option shows this informational message. The `Set Outpath` option allows you to define a directory to which the static binaries will be deployed. `Deploy All` downloads all static binaries available with this tool. `Deploy BusyBox` downloads a BusyBox binary with built-in Linux Utilities. Choosing the `Deploy Net Utilities` option will download static binaries for Ncat, Socat, Nmap, and Ngrok. With Ngrok being a portforwarding/tunneling utility. `Clean up` removes all downloaded files and; `Quit` exits SBD.

### Note

SBD was released to be a complimentary script to my [RootHelper](https://github.com/NullArray/RootHelper) tool. But I have decided to release it as a stand-alone version as well
