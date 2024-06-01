$originalRepo="https://github.com/bilelfeki/task-scheduler-interface"
$backupRepo="https://github.com/bilelfeki/task-scheduler-interface-backup"

try {
   $search = Get-ChildItem -Path .\
   $isRealRepoCloned = $false
   $isBackUpRepoCloned = $false
   
   $realRepoName=$originalRepo.Split('/')[-1]
   $backupRepoName=$backupRepo.Split('/')[-1]
   $localBackupRepoPath = '.\' + $backupRepoName
   $localRealRepoPath= '.\' + $realRepoName 

   $realCommitMap=@{}
   $backUpCommitMap=@{}
   foreach ($result in $search){
      if ($result.Name -eq ($realRepoName)) {
         $isRealRepoCloned = $true
      }
      if ($result.Name -eq ($backupRepoName)) {
         $isBackUpRepoCloned = $true         
      }
   }
   if ($isRealRepoCloned -eq $true -AND $isBackUpRepoCloned -eq $true) {
      echo 'updating repository'

      cd $localRealRepoPath
 
      $pull= git pull
      echo $pull
      $logs = git log --oneline
      #search for the updated commit 
      #put it in hashmap
      foreach($log in $logs){
         $realCommitMap[$log.split(' ')[0]] = '1'
         echo $log.split(' ')[0] 
      }

      cd ..
      cd $localBackupRepoPath
      $pull= git pull
      echo $pull
      $logs = git log --oneline
      #search for the updated commit 
      #put it in hashmap
      foreach($log in $logs){
         $backUpCommitMap[$log.split(' ')[0]] = '1'
         echo $log.split(' ')[0] 
      }

      #get new commits

      echo $realCommitMap
      echo $backUpCommitMap

   } else {
      if($isRealRepoCloned -eq $false){
         git clone $originalRepo
      }
      if($isBackUpRepoCloned -eq $false){
         git clone $backupRepo
      }
   }
} catch {
   Write-Error "An error occurred: $_"
}
