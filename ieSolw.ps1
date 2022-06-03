Add-Type -AssemblyName PresentationCore,PresentationFramework

$version = "1.0"
$githubver = "https://raw.githubusercontent.com/asmirbelkic/iesolw/main/currentversion.txt"
$updatefile = "https://raw.githubusercontent.com/asmirbelkic/iesolw/main/ieSolw.ps1"

function UpdatesAvailable(){
	$updateavailable = $false
	$nextversion = $null
	try
	{
		$nextversion = (New-Object System.Net.WebClient).DownloadString($githubver).Trim([Environment]::NewLine)
	}
	catch [System.Exception] 
	{
		Write-Host $_
	}
	
	Write-Host "Version actuelle: $version"
	Write-Host "Nouvelle version: $nextversion"
	if ($nextversion -ne $null -and $version -ne $nextversion)
	{
		#An update is most likely available, but make sure
		$updateavailable = $false
		$curr = $version.Split('.')
		$next = $nextversion.Split('.')
		for($i=0; $i -le ($curr.Count -1); $i++)
		{
			if ([int]$next[$i] -gt [int]$curr[$i])
			{
				$updateavailable = $true
				break
			}
		}
	}
	return $updateavailable
}
function DownloadFile($url) {
	$ls = (New-Object System.Net.WebClient).Downloadstring($url)
	try {
		Remove-Item "$($PWD.Path)\ieSolw.ps1"
		$ls | Out-File "$($PWD.Path)\ieSolw.ps1"
	}
	catch [System.Exception] {
			Write-Output "Error saving new version of ieSolw.ps1"
			throw
			Read-Host "Press any key to exit."
			exit
	}
	$msgTitle = "Succes"
	$msgBody = "Mise a jour termine vous pouvez relancer ieSolw"
	[System.Windows.MessageBox]::Show($msgBody,$msgTitle)
	exit
}
function Process-Update() {
	if (Test-Connection 8.8.8.8 -Count 1 -Quiet) {
		$updatepath = "$($PWD.Path)\update.ps1"
		if (Test-Path -Path $updatepath)	
		{
			#Remove-Item $updatepath
		}
		if (UpdatesAvailable)
		{
			$msgTitle = "Mise a jour"
			$msgBody = "Une mise a jour est disponible, voulez vous mettre a jour IESolw ?"
			$msgButton = 'YesNo'
			$msgImage = 'Question'
			$result = [System.Windows.MessageBox]::Show($msgBody,$msgTitle,$msgButton,$msgImage)
			if ($result -eq 'Yes')
			{	
				DownloadFile($updatefile)
			}
		}
	}
	else
	{
		Write-Message "Unable to check for updates. Internet connection not available."
	}
}

Process-Update