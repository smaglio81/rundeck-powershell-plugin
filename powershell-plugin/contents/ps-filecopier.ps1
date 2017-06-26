#!/usr/bin/powershell
#Script needed to handle the running of scripts: the generated script file is not uploaded on the remote node but instead invoke-command is launched with the -filepath option
Param(
    $Filepath,
    $Destpath
)
$Destpath = "$Destpath.ps1"
copy-item $Filepath $Destpath
$Destpath