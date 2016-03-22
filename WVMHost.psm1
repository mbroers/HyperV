  function Write-Log
  {
    param
      (
        [parameter(mandatory=$false)]
        [System.String]
        $message
      )
    $date = get-date -format 'yyyy-MM-dd hh:mm:ss.zz'
    Write-Host "$date $message"
    $postSlackMessage = @{token="$slackToken";channel="#$slackChannel";text="$env:computername $message";username="$slackUsername"}
    Invoke-RestMethod -Uri https://leapfrogonline.slack.com/api/chat.postMessage -Body $postSlackMessage
    Out-File -InputObject "$date $message" -FilePath "C:\Program Files (x86)\Ansible\ansible-playbook.log" -Append
  }

function get-vm_slack{
  param
    (
      [string]$slackToken,
      [string]$slackChannel,
      [string]$slackUsername
    )
  

  $osversion = [string][environment]::osversion.version.major + "." + [string][environment]::osversion.version.minor
  if ($osversion -eq "6.1"){import-module hyperv}
      
  $results = get-vm
  $results_string = $results | out-string
  $results_codeblock = "``````" + $results_string + "``````"
  
  write-log $results_codeblock
  
}

function pause-vm_slack{
  param
    (
      [string]$slackToken,
      [string]$slackChannel,
      [string]$slackUsername
    )

  $osversion = [string][environment]::osversion.version.major + "." + [string][environment]::osversion.version.minor
  if ($osversion -eq "6.1"){import-module hyperv}

  $results = get-vm
  $results_string = $results | out-string
  $results_codeblock = "``````" + $results_string + "``````"
  
  write-log $results_codeblock
  write-log "Pausing VMs standby..."

  if ($osversion -eq "6.1")
    {
      get-vm -running | save-vm -force
    }  
  else
    {
      get-vm | where state -eq 'running' | suspend-vm
    }

  start-sleep -s 10

  $results = get-vm
  $results_string = $results | out-string
  $results_codeblock = "``````" + $results_string + "``````"

  write-log $results_codeblock

}

function resume-vm_slack{
  param
    (
      [string]$slackToken,
      [string]$slackChannel,
      [string]$slackUsername
    )

  $osversion = [string][environment]::osversion.version.major + "." + [string][environment]::osversion.version.minor
  if ($osversion -eq "6.1"){import-module hyperv}

  $results = get-vm
  $results_string = $results | out-string
  $results_codeblock = "``````" + $results_string + "``````"
  
  write-log $results_codeblock
  write-log "Resuming VMs standby..."

  if ($osversion -eq "6.1")
    {
      get-vm -paused | start-vm
    }
  else
    {
      get-vm | where state -eq 'paused' | resume-vm
    }
  start-sleep -s 10

  $results = get-vm
  $results_string = $results | out-string
  $results_codeblock = "``````" + $results_string + "``````"

  write-log $results_codeblock

}