#!/usr/bin/powershell

#region script-handling
try {
    if ($ENV:RD_EXEC_COMMAND -like "chmod +x*") {
        #chmod is not needed
        #write-output "skip chmod"
    }
    elseif ($ENV:RD_EXEC_COMMAND -like "/tmp/*") {
        #if the command contains the path of the temp script we will either run it directly (if the selected node is the rundeck host) or send it to the remote host with "invoke-command"
        $path = "$ENV:RD_EXEC_COMMAND"
        move-item $path "$($path).ps1"
        if ($ENV:RD_NODE_DESCRIPTION -like "Rundeck server node") {
            #we are running on local node
            Write-Output "running script on local node"
            & "$($path).ps1"
        }
        else {
            $PlainPassword = $ENV:RD_CONFIG_PASS
            $SecurePassword = ConvertTo-SecureString $PlainPassword -AsPlainText -Force
            $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $ENV:RD_CONFIG_USER, $SecurePassword
            Write-Output "running script on $ENV:RD_NODE_NAME as $ENV:RD_CONFIG_USER"
            Invoke-Command -ComputerName $ENV:RD_NODE_NAME -Credential $Credentials -Filepath "$($path).ps1" -Authentication $ENV:RD_CONFIG_AUTHTYPE
        }
    }
    elseif ( $ENV:RD_EXEC_COMMAND -like "rm -f*") {
        #delete the temp script file after we run it
        write-output "removing temp file"
        $path = $ENV:RD_EXEC_COMMAND -replace "rm -f "
        remove-item "$($path).ps1"
    }
    #endregion
    #region command-handling
    else {
        #single command mode, run directly or send to remote host
        $scriptblock = [Scriptblock]::Create($ENV:RD_EXEC_COMMAND)
        if ($ENV:RD_NODE_DESCRIPTION -like "Rundeck server node") {
            Write-Output "running $ENV:RD_EXEC_COMMAND on local node"
            & $scriptblock
        }
        else {
            $PlainPassword = $ENV:RD_CONFIG_PASS
            $SecurePassword = ConvertTo-SecureString $PlainPassword -AsPlainText -Force
            $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $ENV:RD_CONFIG_USER, $SecurePassword
        
            Write-Output "running $ENV:RD_EXEC_COMMAND on $ENV:RD_NODE_NAME as $ENV:RD_CONFIG_USER"
            Invoke-Command -ComputerName $ENV:RD_NODE_NAME -Credential $Credentials -Command $scriptblock -Authentication $ENV:RD_CONFIG_AUTHTYPE
        }
    }
} catch {
    exit 1
}
#endregion