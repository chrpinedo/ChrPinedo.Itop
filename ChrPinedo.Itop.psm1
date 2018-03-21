
Function Get-Object {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$False)]
    [string]$Uri,
    [Parameter(Mandatory=$true,ValueFromPipeline=$False)]
    [PSCredential]$Credential,
    [Parameter(Mandatory=$true,ValueFromPipeline=$False)]
    [string]$Class,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [string]$OQLFilter
  )
  [string]$Username = $Credential.UserName
  [string]$Password = $Credential.GetNetworkCredential().Password
  $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Username + ":" + $Password)
  $AuthHeader = "Basic " + [Convert]::ToBase64String($Bytes)
  $Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
  $Headers.Add("Authorization",$AuthHeader)
  $Headers.Add("Accept","application/json")
  $Headers.Add("Content-Type","application/json")
  Write-Verbose "OQLFilter: $OQLFilter"
  $Key =  "SELECT $Class"
  if ($OQLFilter) { $Key = $Key + " WHERE " + $OQLFilter }
  Write-Verbose "Key: $Key"
  $JsonData = @{
               operation = 'core/get'
               class = "$Class"
               key = ("$key")
               output_fields = '*'
               } | ConvertTo-Json -Compress
  $Uri = "$Uri&json_data=$JsonData"
  # Execute command and store returned JSON
  $ReturnedJSON = Invoke-RestMethod -Uri $Uri -Headers $Headers -Method Get -ContentType 'application/json'
  Write-Verbose "Server returned: $ReturnedJSON"

  # if no result
  if (!$ReturnedJSON.Objects) {
    Write-Warning "Search has returned 0 results."
    break
  }
  # if results
  $ObjData = @()
  foreach ($Name in ($ReturnedJSON.objects | Get-Member -MemberType Properties).Name){
    $ObjData += $ReturnedJSON.Objects.$Name.Fields
  }
  $ObjData
}

Function Get-VirtualMachine {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$False)]
    [string]$Uri,
    [Parameter(Mandatory=$true,ValueFromPipeline=$False)]
    [PSCredential]$Credential,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [string[]]$Name,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [ValidateSet("implementation","obsolete","production","stock")]
    [string[]]$Status,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [string[]]$OrganizationName,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [string[]]$VirtualHostName,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [string]$OQLFilter
  )

  $Class = "VirtualMachine"
  $FinalOQLFilter = @()
  if ($Name) {
    $Filter = " name IN ("
    Foreach ($AName in $Name) { $Filter += """$AName""," }
    $Filter = $Filter.Substring(0,$Filter.Length-1)
    $Filter += ") "
    $FinalOQLFilter += $Filter
  }
  if ($OrganizationName) {
    $Filter = " organization_name IN ("
    Foreach ($AOrganizationName in $OrganizationName) { $Filter += """$AOrganizationName""," }
    $Filter = $Filter.Substring(0,$Filter.Length-1)
    $Filter += ") "
    $FinalOQLFilter += $Filter
  }
  if ($Status) {
    $Filter = " status IN ("
    Foreach ($AStatus in $Status) { $Filter += """$AStatus""," }
    $Filter = $Filter.Substring(0,$Filter.Length-1)
    $Filter += ") "
    $FinalOQLFilter += $Filter
  }
  if ($VirtualHostName) {
    $Filter = " virtualhost_name IN ("
    Foreach ($AVirtualHostName in $VirtualHostName) { $Filter += """$AVirtualHostName""," }
    $Filter = $Filter.Substring(0,$Filter.Length-1)
    $Filter += ") "
    $FinalOQLFilter += $Filter
  }
  if ($OQLFilter) {
    $FinalOQLFilter += $OQLFilter
  }
  $FinalOQLFilterStr = $FinalOQLFilter -join " AND "
  Write-Verbose "FinalOQLFilterStr -> $FinalOQLFilterStr"
  Get-Object -Uri $uri -Credential $Credential -Class $Class -OQLFilter "$FinalOQLFilterStr"
}

Function Get-ApplicationSolution {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$False)]
    [string]$Uri,
    [Parameter(Mandatory=$true,ValueFromPipeline=$False)]
    [PSCredential]$Credential,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [string[]]$Name,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [ValidateSet("active","inactive")]
    [string[]]$Status,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [string[]]$OrganizationName,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [string]$OQLFilter
  )
  $Class = "ApplicationSolution"
  $FinalOQLFilter = @()
  if ($Name) {
    $Filter = " name IN ("
    Foreach ($AName in $Name) { $Filter += """$AName""," }
    $Filter = $Filter.Substring(0,$Filter.Length-1)
    $Filter += ") "
    $FinalOQLFilter += $Filter
  }
  if ($Status) {
    $Filter = " status IN ("
    Foreach ($AStatus in $Status) { $Filter += """$AStatus""," }
    $Filter = $Filter.Substring(0,$Filter.Length-1)
    $Filter += ") "
    $FinalOQLFilter += $Filter
  }
  if ($OrganizationName) {
    $Filter = " organization_name IN ("
    Foreach ($AOrganizationName in $OrganizationName) { $Filter += """$AOrganizationName""," }
    $Filter = $Filter.Substring(0,$Filter.Length-1)
    $Filter += ") "
    $FinalOQLFilter += $Filter
  }
  if ($OQLFilter) {
    $FinalOQLFilter += $OQLFilter
  }
  $FinalOQLFilterStr = $FinalOQLFilter -join " AND "
  Write-Verbose "FinalOQLFilterStr -> $FinalOQLFilterStr"
  Get-Object -Uri $uri -Credential $Credential -Class $Class -OQLFilter "$FinalOQLFilterStr"
}

Function Get-Organization {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$False)]
    [string]$Uri,
    [Parameter(Mandatory=$true,ValueFromPipeline=$False)]
    [PSCredential]$Credential,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [string[]]$Name,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [ValidateSet("active","inactive")]
    [string[]]$Status,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [string]$OQLFilter
  )
  $Class = "Organization"
  $FinalOQLFilter = @()
  if ($Name) {
    $Filter = " name IN ("
    Foreach ($AName in $Name) { $Filter += """$AName""," }
    $Filter = $Filter.Substring(0,$Filter.Length-1)
    $Filter += ") "
    $FinalOQLFilter += $Filter
  }
  if ($Status) {
    $Filter = " status IN ("
    Foreach ($AStatus in $Status) { $Filter += """$AStatus""," }
    $Filter = $Filter.Substring(0,$Filter.Length-1)
    $Filter += ") "
    $FinalOQLFilter += $Filter
  }
  if ($OQLFilter) {
    $FinalOQLFilter += $OQLFilter
  }
  $FinalOQLFilterStr = $FinalOQLFilter -join " AND "
  Write-Verbose "FinalOQLFilterStr -> $FinalOQLFilterStr"
  Get-Object -Uri $uri -Credential $Credential -Class $Class -OQLFilter "$FinalOQLFilterStr"
}

Function Get-Contact {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$False)]
    [string]$Uri,
    [Parameter(Mandatory=$true,ValueFromPipeline=$False)]
    [PSCredential]$Credential,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [int[]]$Id,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [string[]]$Name,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [string[]]$Email,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [ValidateSet("active","inactive")]
    [string[]]$Status,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [string[]]$OrganizationName,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [string]$OQLFilter
  )
  $Class = "Contact"
  $FinalOQLFilter = @()
  if ($Id) {
    $Filter = " id IN ("
    Foreach ($AId in $Id) { $Filter += "$AId," }
    $Filter = $Filter.Substring(0,$Filter.Length-1)
    $Filter += ") "
    $FinalOQLFilter += $Filter
  }
  if ($Name) {
    $Filter = " name IN ("
    Foreach ($AName in $Name) { $Filter += """$AName""," }
    $Filter = $Filter.Substring(0,$Filter.Length-1)
    $Filter += ") "
    $FinalOQLFilter += $Filter
  }
  if ($Email) {
    $Filter = " name IN ("
    Foreach ($AEmail in $Email) { $Filter += """$AEmail""," }
    $Filter = $Filter.Substring(0,$Filter.Length-1)
    $Filter += ") "
    $FinalOQLFilter += $Filter
  }
  if ($Status) {
    $Filter = " status IN ("
    Foreach ($AStatus in $Status) { $Filter += """$AStatus""," }
    $Filter = $Filter.Substring(0,$Filter.Length-1)
    $Filter += ") "
    $FinalOQLFilter += $Filter
  }
  if ($OrganizationName) {
    $Filter = " organization_name IN ("
    Foreach ($AOrganizationName in $OrganizationName) { $Filter += """$AOrganizationName""," }
    $Filter = $Filter.Substring(0,$Filter.Length-1)
    $Filter += ") "
    $FinalOQLFilter += $Filter
  }
  if ($OQLFilter) {
    $FinalOQLFilter += $OQLFilter
  }
  $FinalOQLFilterStr = $FinalOQLFilter -join " AND "
  Write-Verbose "FinalOQLFilterStr -> $FinalOQLFilterStr"
  Get-Object -Uri $uri -Credential $Credential -Class $Class -OQLFilter "$FinalOQLFilterStr"
}

Function Get-Person {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$False)]
    [string]$Uri,
    [Parameter(Mandatory=$true,ValueFromPipeline=$False)]
    [PSCredential]$Credential,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [int[]]$Id,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [string[]]$Name,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [string[]]$Email,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [ValidateSet("active","inactive")]
    [string[]]$Status,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [string[]]$OrganizationName,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [string]$OQLFilter
  )
  $Class = "Person"
  $FinalOQLFilter = @()
  if ($Id) {
    $Filter = " id IN ("
    Foreach ($AId in $Id) { $Filter += "$AId," }
    $Filter = $Filter.Substring(0,$Filter.Length-1)
    $Filter += ") "
    $FinalOQLFilter += $Filter
  }
  if ($Name) {
    $Filter = " name IN ("
    Foreach ($AName in $Name) { $Filter += """$AName""," }
    $Filter = $Filter.Substring(0,$Filter.Length-1)
    $Filter += ") "
    $FinalOQLFilter += $Filter
  }
  if ($Email) {
    $Filter = " name IN ("
    Foreach ($AEmail in $Email) { $Filter += """$AEmail""," }
    $Filter = $Filter.Substring(0,$Filter.Length-1)
    $Filter += ") "
    $FinalOQLFilter += $Filter
  }
  if ($Status) {
    $Filter = " status IN ("
    Foreach ($AStatus in $Status) { $Filter += """$AStatus""," }
    $Filter = $Filter.Substring(0,$Filter.Length-1)
    $Filter += ") "
    $FinalOQLFilter += $Filter
  }
  if ($OrganizationName) {
    $Filter = " organization_name IN ("
    Foreach ($AOrganizationName in $OrganizationName) { $Filter += """$AOrganizationName""," }
    $Filter = $Filter.Substring(0,$Filter.Length-1)
    $Filter += ") "
    $FinalOQLFilter += $Filter
  }
  if ($OQLFilter) {
    $FinalOQLFilter += $OQLFilter
  }
  $FinalOQLFilterStr = $FinalOQLFilter -join " AND "
  Write-Verbose "FinalOQLFilterStr -> $FinalOQLFilterStr"
  Get-Object -Uri $uri -Credential $Credential -Class $Class -OQLFilter "$FinalOQLFilterStr"
}

Function Get-Team {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$False)]
    [string]$Uri,
    [Parameter(Mandatory=$true,ValueFromPipeline=$False)]
    [PSCredential]$Credential,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [int[]]$Id,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [string[]]$Name,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [string[]]$Email,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [ValidateSet("active","inactive")]
    [string[]]$Status,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [string[]]$OrganizationName,
    [Parameter(Mandatory=$false,ValueFromPipeline=$False)]
    [string]$OQLFilter
  )
  $Class = "Team"
  $FinalOQLFilter = @()
  if ($Id) {
    $Filter = " id IN ("
    Foreach ($AId in $Id) { $Filter += "$AId," }
    $Filter = $Filter.Substring(0,$Filter.Length-1)
    $Filter += ") "
    $FinalOQLFilter += $Filter
  }
  if ($Name) {
    $Filter = " name IN ("
    Foreach ($AName in $Name) { $Filter += """$AName""," }
    $Filter = $Filter.Substring(0,$Filter.Length-1)
    $Filter += ") "
    $FinalOQLFilter += $Filter
  }
  if ($Email) {
    $Filter = " name IN ("
    Foreach ($AEmail in $Email) { $Filter += """$AEmail""," }
    $Filter = $Filter.Substring(0,$Filter.Length-1)
    $Filter += ") "
    $FinalOQLFilter += $Filter
  }
  if ($Status) {
    $Filter = " status IN ("
    Foreach ($AStatus in $Status) { $Filter += """$AStatus""," }
    $Filter = $Filter.Substring(0,$Filter.Length-1)
    $Filter += ") "
    $FinalOQLFilter += $Filter
  }
  if ($OrganizationName) {
    $Filter = " organization_name IN ("
    Foreach ($AOrganizationName in $OrganizationName) { $Filter += """$AOrganizationName""," }
    $Filter = $Filter.Substring(0,$Filter.Length-1)
    $Filter += ") "
    $FinalOQLFilter += $Filter
  }
  if ($OQLFilter) {
    $FinalOQLFilter += $OQLFilter
  }
  $FinalOQLFilterStr = $FinalOQLFilter -join " AND "
  Write-Verbose "FinalOQLFilterStr -> $FinalOQLFilterStr"
  Get-Object -Uri $uri -Credential $Credential -Class $Class -OQLFilter "$FinalOQLFilterStr"
}
