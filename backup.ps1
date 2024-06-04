$originalRepoURL = "https://github.com/bilelfeki/task-scheduler-interface"
$backupRepoUrl = "https://github.com/bilelfeki/task-scheduler-interface-backup"

$numberOfBrokenCommitLimit = 2
function getRepoNameFromUrl {
   param([Parameter(Mandatory = $True)][string] $url)
   return $url.Split('/')[-1]
}
function isRepoCloned {
   param ([Parameter(Mandatory = $True)] [string] $repoName)
   $search = Get-ChildItem -Path .\
   foreach ($result in $search) {
      if ($result.Name -eq ($repoName)) {
         return $true
      }
   }
   return $false
}
function extractCommitsFromLogsInHashMap {
   param([Parameter(Mandatory = $True)][string[]] $logs)
   $commitMap = @{}
   foreach ($log in $logs) {
      $commitMap[$log.split(' ')[0]] = '1'
   }
   return $commitMap
}
function goToClonedRepo {
   param($repoPath)
   Set-Location $repoPath
   
}
function goBack {
   Set-Location ..
}

function getNewCommitsFromLocalRepo {
   git pull > $null 2>&1
   $logs = git log --oneline
   return extractCommitsFromLogsInHashMap -logs $logs

}

function willBackUpBranchUpdated {
   param (
      [hashtable] $originalRepoCommits, [hashtable] $backupRepoCommit
   )
   $notFoundCommitNumber = 0
   foreach ($Key in $backupRepoCommit.Keys) {
      if (!$originalRepoCommits[$key]) {
         $notFoundCommitNumber = $notFoundCommitNumber + 1
      }
   }
   return $($notFoundCommitNumber -le $numberOfBrokenCommitLimit)
}
function Show-Notification {
   [cmdletbinding()]
   Param (
       [string]
       $ToastTitle,
       [string]
       [parameter(ValueFromPipeline)]
       $ToastText
   )

   [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
   $Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

   $RawXml = [xml] $Template.GetXml()
   ($RawXml.toast.visual.binding.text|where {$_.id -eq "1"}).AppendChild($RawXml.CreateTextNode($ToastTitle)) > $null
   ($RawXml.toast.visual.binding.text|where {$_.id -eq "2"}).AppendChild($RawXml.CreateTextNode($ToastText)) > $null
   
   $SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument
   $SerializedXml.LoadXml($RawXml.OuterXml)

   $Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml)
   $Toast.Tag = "PowerShell"
   $Toast.Group = "PowerShell"
   $Toast.ExpirationTime = [DateTimeOffset]::Now.AddDays(3)

   $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Backup Repo")
   $Notifier.Show($Toast);
}

$realCommitMap = @{}
$backUpCommitMap = @{}
$realRepoName = getRepoNameFromUrl -url $originalRepoURL
$backupRepoName = getRepoNameFromUrl -url $backupRepoUrl
$localBackupRepoPath = '.\' + $backupRepoName
$localRealRepoPath = '.\' + $realRepoName 
$isRealRepoCloned = isRepoCloned -repoName $realRepoName
$isBackUpRepoCloned = isRepoCloned -repoName $backupRepoName

if ($isRealRepoCloned -eq $false) {
   git clone $originalRepoURL
}
if ($isBackUpRepoCloned -eq $false) {
   git clone $backupRepoUrl
}

goToClonedRepo -repoPath $localRealRepoPath
$realCommitMap = getNewCommitsFromLocalRepo
goBack 

goToClonedRepo -repoPath $localBackupRepoPath
$backUpCommitMap = getNewCommitsFromLocalRepo
goBack 

$couldUpdateBackupRepo = willBackUpBranchUpdated -originalRepoCommits $realCommitMap -backupRepoCommit $backUpCommitMap

if ($couldUpdateBackupRepo) {
   Write-Output '**************updating backup repo****************'
   goToClonedRepo -repoPath $localRealRepoPath
   git push $backupRepoUrl 
   goBack 
}else {
   Show-Notification -ToastTitle 'Your Branch Has Some Problems Please Check It'
   Write-Output '**************send notif to the owner****************'
}
