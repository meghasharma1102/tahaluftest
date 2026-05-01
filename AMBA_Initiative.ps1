Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-RequiredEnvironmentVariable {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Name
  )

  $value = [Environment]::GetEnvironmentVariable($Name)

  if ([string]::IsNullOrWhiteSpace($value)) {
    throw "Required environment variable '$Name' is missing."
  }

  return $value.Trim()
}

function Get-OptionalEnvironmentVariable {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Name
  )

  $value = [Environment]::GetEnvironmentVariable($Name)

  if ([string]::IsNullOrWhiteSpace($value)) {
    return $null
  }

  return $value.Trim()
}

$mgName = Get-RequiredEnvironmentVariable -Name "AMBA_MANAGEMENT_GROUP_NAME"
$resourceGroupName = Get-RequiredEnvironmentVariable -Name "AMBA_RESOURCE_GROUP_NAME"
$location = Get-RequiredEnvironmentVariable -Name "AMBA_LOCATION"
$alertEmailsRaw = Get-RequiredEnvironmentVariable -Name "AMBA_ALERT_EMAILS"
$subscriptionId = Get-RequiredEnvironmentVariable -Name "AMBA_SUBSCRIPTION_ID"
$expectedTenantId = Get-OptionalEnvironmentVariable -Name "AMBA_TENANT_ID"

if ([string]::IsNullOrWhiteSpace($expectedTenantId)) {
  $expectedTenantId = Get-OptionalEnvironmentVariable -Name "ARM_TENANT_ID"
}

if ([string]::IsNullOrWhiteSpace($expectedTenantId)) {
  $expectedTenantId = Get-OptionalEnvironmentVariable -Name "AZURE_TENANT_ID"
}

$templateUri = [Environment]::GetEnvironmentVariable("AMBA_TEMPLATE_URI")
if ([string]::IsNullOrWhiteSpace($templateUri)) {
  $templateUri = "https://raw.githubusercontent.com/Azure/azure-monitor-baseline-alerts/2025-10-01/patterns/alz/alzArm.json"
}

$paramUri = [Environment]::GetEnvironmentVariable("AMBA_PARAM_URI")
if ([string]::IsNullOrWhiteSpace($paramUri)) {
  $paramUri = "https://raw.githubusercontent.com/Azure/azure-monitor-baseline-alerts/2025-10-01/patterns/alz/alzArm.param.json"
}

$alertEmails = @(
  $alertEmailsRaw.Split(",", [System.StringSplitOptions]::RemoveEmptyEntries) |
    ForEach-Object { $_.Trim() } |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
)

if ($alertEmails.Count -eq 0) {
  throw "AMBA_ALERT_EMAILS must contain at least one email address."
}

$paramFile = Join-Path $PSScriptRoot "alzArm.param.json"
$modifiedParamFile = Join-Path $PSScriptRoot "alzArm.param.modified.json"
$deploymentName = "amba-MainDeployment-$(Get-Date -Format 'yyyyMMddHHmmss')"
$managementGroupParameterNames = @(
  "enterpriseScaleCompanyPrefix",
  "platformManagementGroup",
  "IdentityManagementGroup",
  "managementManagementGroup",
  "connectivityManagementGroup",
  "LandingZoneManagementGroup"
)

Write-Host "========================================="
Write-Host " AMBA Deployment - Starting"
Write-Host "========================================="

Write-Host "[1/5] Checking dependencies..."
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
  throw "Azure CLI (az) is not installed or not available on PATH."
}
Write-Host "Dependencies OK"

Write-Host "[2/5] Downloading alzArm.param.json..."
Remove-Item $paramFile -Force -ErrorAction SilentlyContinue
Remove-Item $modifiedParamFile -Force -ErrorAction SilentlyContinue
Invoke-WebRequest -Uri $paramUri -OutFile $paramFile

if (-not (Test-Path $paramFile)) {
  throw "Failed to download AMBA parameter file from $paramUri."
}
Write-Host "Downloaded: $paramFile"

Write-Host "[3/5] Modifying parameters..."
$params = Get-Content $paramFile -Raw | ConvertFrom-Json

foreach ($parameterName in $managementGroupParameterNames) {
  if ($null -eq $params.parameters.$parameterName) {
    throw "Expected AMBA parameter '$parameterName' was not found in the downloaded parameter file."
  }

  $params.parameters.$parameterName.value = $mgName
}

$params.parameters.ALZMonitorResourceGroupName.value = $resourceGroupName
$params.parameters.ALZMonitorResourceGroupLocation.value = $location
$params.parameters.ALZMonitorActionGroupEmail.value = $alertEmails
$params.parameters.managementSubscriptionId.value = $subscriptionId
$params | ConvertTo-Json -Depth 50 | Set-Content $modifiedParamFile -Encoding UTF8
Write-Host "Parameters modified"

Write-Host "[4/6] Verifying Azure login..."
$account = az account show --output json | ConvertFrom-Json
if ($LASTEXITCODE -ne 0) {
  throw "Azure CLI is not logged in."
}

Write-Host "[5/6] Selecting Azure subscription context..."
if ($account.id -ne $subscriptionId) {
  az account set --subscription $subscriptionId --only-show-errors
  if ($LASTEXITCODE -ne 0) {
    throw "Unable to switch Azure CLI context to subscription '$subscriptionId'."
  }

  $account = az account show --output json | ConvertFrom-Json
  if ($LASTEXITCODE -ne 0) {
    throw "Azure CLI context could not be reloaded after switching subscriptions."
  }
}

if ($account.id -ne $subscriptionId) {
  throw "Azure CLI is using subscription '$($account.id)' but AMBA_SUBSCRIPTION_ID is '$subscriptionId'."
}

if (-not [string]::IsNullOrWhiteSpace($expectedTenantId) -and $account.tenantId -ne $expectedTenantId) {
  throw "Azure CLI is using tenant '$($account.tenantId)' but the deployment expects tenant '$expectedTenantId'."
}

Write-Host "Azure login OK - subscription: $($account.id), tenant: $($account.tenantId)"

Write-Host "[6/6] Deploying: $deploymentName to MG: $mgName"
az deployment mg create `
  --name $deploymentName `
  --management-group-id $mgName `
  --location $location `
  --template-uri $templateUri `
  --parameters "@$modifiedParamFile" `
  --only-show-errors

if ($LASTEXITCODE -ne 0) {
  throw "AMBA deployment failed."
}

Write-Host "========================================="
Write-Host " AMBA Deployment Complete"
Write-Host "========================================="
