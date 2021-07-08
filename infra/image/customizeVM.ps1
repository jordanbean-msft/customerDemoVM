[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$pathToWebSite
)

$ErrorActionPreference = "Stop"

Write-Host "Downloading userdata..."

$userData = Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET -Proxy $Null -Uri "http://169.254.169.254/metadata/instance/compute/userData?api-version=2021-01-01&format=text"
$customerName = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($userData))

Write-Host "Downloaded userdata"

Write-Host "Configuring WebSite $pathToWebSite with customer data for $customerName..."

$originalHtml = Get-Content -Path $pathToWebSite -Raw

$newHtml = $originalHtml -replace "{webSiteName}", $customerName

$newHtml | Set-Content -Path $pathToWebSite

Write-Host "Configured WebSite $pathToWebSite with customer data for $customerName"

Write-Host "Starting Windows Service W3SVC..."

Start-Service -ServiceName "W3SVC"

Write-Host "Started Windows Service W3SVC"

Import-Module IISAdministration

Write-Host "Starting WebSite ..."

Start-IISSite -Name "ApplicationWebSite"

Write-Host "Started WebSite"