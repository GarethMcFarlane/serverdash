# Server Status Powershell Script
# v1.1
# Gareth McFarlane
# Com Connect Services


# Add Server Backup Snapin
Add-PSSnapin windows.serverbackup -ErrorAction SilentlyContinue

# Get parameters
$computerName = $env:COMPUTERNAME
$domainName = $env:USERDOMAIN
$result = 'No backup configured'
$lastBackup = 'Never'
$lastSummary = Get-WBSummary
$backupCopies = 0
$today = Get-Date
$yesterday = $today.AddDays(-1)


 # Checks that a scheduled backup exists
 if (Get-WBPolicy){
    $lastJob = Get-WBJob -Previous 1
    $result = $lastJob.HResult
    $lastBackup = $lastJob.EndTime.ToString()
    $backupCopies = $lastSummary.NumberOfVersions         
} 

# Creates JSON data
$server = (New-Object PSObject | 
           Add-Member -PassThru BackupResult $result |
           Add-Member -PassThru LastBackupTime $lastBackup |
           Add-Member -PassThru NumberOfCopies $backupCopies
)


# If the URL exists, Firebase will use it, if not it will create one for the domain and server.
$uri = "https://boiling-fire-537.firebaseio.com/servers/" + $domainName + "/" + $computerName + ".json"
#Convert to JSON and send.
$json = $server | ConvertTo-Json
$response = Invoke-RestMethod $uri -Method Put -Body $json -ContentType 'application/json'



$logs = @("Application", "System")
$types = @("Warning", "Critical","Error")

foreach ($log in $logs){
	foreach ($type in $types){
	
		$errors = New-Object PSObject
		
		$events = get-eventlog -logname $log -after $yesterday | Where {$_.entryType -Match $type}
		$table = $events | Group EventID, Source
	
		foreach($row in $table) {
			Add-Member -InputObject $errors -MemberType NoteProperty -Name $row.Name -Value $row.Count
		}
	

$uri = "https://boiling-fire-537.firebaseio.com/servers/" + $domainName + "/" + $computerName + "/logs/" + $log + "/" + $type + ".json"
#Convert to JSON and send.
$json = $errors | ConvertTo-Json
$response = Invoke-RestMethod $uri -Method Put -Body $json -ContentType 'application/json'
	
	}
}
	