[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$resourceGroupname,
		[Parameter()]
		[string]
		$imageTemplateName
)

$ErrorActionPreference = "Stop"

Import-Module Az.Resources

Invoke-AzResourceAction -ResourceGroupName $resourceGroupname `
												-ResourceName $imageTemplateName `
												-ResourceType Microsoft.VirtualMachineImages/imageTemplates `
												-ApiVersion "2020-02-14" `
												-Action Run `
												-Force