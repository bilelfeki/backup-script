$originalRepoURL = "https://github.com/bilelfeki/task-scheduler-interface"
$backupRepoUrl = "https://github.com/bilelfeki/task-scheduler-interface-backup"

$numberOfBrokenCommitLimit = 3
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
   foreach ($Key in $backupRepoCommit.Keys) {
      $notFoundCommitNumber = 0
      if (!$originalRepoCommits[$key]) {
         $notFoundCommitNumber = $notFoundCommitNumber + 1
      }
   }
   return $($notFoundCommitNumber -le $numberOfBrokenCommitLimit)
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
git push $backupRepoUrl 
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
   Write-Output '**************send notif to the owner****************'
}
