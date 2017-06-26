# rundeck-powershell-plugin

## Description

A [Rundeck Node Executor](http://rundeck.org/docs/plugins-user-guide/node-execution-plugins.html) plugin that allow to execute commands on local or remote nodes via native Powershell.

Tested on Centos 7.3 with [Rundeck](http://rundeck.org) 2.8.2 and [Powershell 6.0b3](https://github.com/PowerShell/PowerShell)

The idea is to replace the WinRM ruby plugin with the native Linux Powershell implementation.

_A note about the remote node authentication: the plugin supports both Basic and Negotiate(NTLM) types of authentication. This is because Powershell for Linux CAN authenticate via NTLM(SPNEGO) with a Windows Server, I just haven't been able to figure out how to...please see [this discussion on reddit](https://www.reddit.com/r/PowerShell/comments/6itek2/powershell_remoting_linux_windows_with_spnego/) and contribute if you can!_ 


## Installation

* Copy the zip file in $RDECK_BASE/libext
* Edit your project and select "Powershell Executor" as the default node executor and "Powershell script runner" as the Default Node Copier
* In the Default Node Executor section add the username and password (only used when invoking commands against a remote host) and select the Authentication Type.
* Edit your rundeck resources.xml and for each node add: 
  * node-executor="PSExe" file-copier="PSScript"

## Configuration on Windows
```
winrm set winrm/config/client/auth @{Basic="true"}
winrm set winrm/config/service/auth @{Basic="true"}
winrm set winrm/config/service @{AllowUnencrypted="true"}
```

## Details

This plugin can handle both remote commands and inline scripts.

If the script/command is run agains the local Rundeck host it will just run the command or the script in the local powershell environment

if the script/command is run against a remote node (tested on Windows 2016 with Basic Authentication) it will run an invoke-command.

The script copier doesn't actually copy anything, it just handles the creation and deletion of the temp script files which get then either executed locally or added to invoke-command with the -filepath parameter

## Credits

Much of this work has been inspired by the [Rundeck Telnet Plugin](https://github.com/adomaceo/telnet-plugin) and the [Rundeck WinRM Plugin](https://github.com/rundeck-plugins/rundeck-winrm-plugin)