function Get-Object {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $Uri,
        [Parameter(Mandatory=$true)]
        [PSCredential]
        $Credential,
        [Parameter(Mandatory=$true)]
        [string]
        $Class,
        [Parameter(Mandatory=$false)]
        [string]
        $OQLFilter
    )
    process {
        [string]$Username = $Credential.UserName
        [string]$Password = $Credential.GetNetworkCredential().Password
        $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Username + ":" + $Password)
        $AuthHeader = "Basic " + [Convert]::ToBase64String($Bytes)
        $Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $Headers.Add("Authorization",$AuthHeader)
        $Headers.Add("Accept","application/json")
        $Headers.Add("Content-Type","application/json")
        Write-Verbose "OQLFilter parameter: $OQLFilter"
        $Key =  "SELECT $Class"
        if ($OQLFilter) {
            $Key = $Key + " WHERE " + $OQLFilter
        }
        Write-Verbose "Key: $Key"
        $JsonData = @{
            operation = 'core/get'
            class = "$Class"
            key = ("$Key")
            output_fields = '*'
        } | ConvertTo-Json -Compress
        $Uri = "$Uri&json_data=$JsonData"
        Write-Verbose "Uri: $Uri"
        $ReturnedJSON = Invoke-RestMethod -Uri $Uri -Headers $Headers -Method Get -ContentType 'application/json'
        Write-Verbose "Server returned: $ReturnedJSON"

        $ObjData = @()
        if (!$ReturnedJSON.Objects) {
            Write-Warning "Search has returned 0 results"
            break
        } else {
            foreach ($Name in ($ReturnedJSON.objects | Get-Member -MemberType Properties).Name) {
                $ObjData += $ReturnedJSON.Objects.$Name.Fields
            }
        }
        $ObjData
    }
}


function Get-VirtualMachine {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $Uri,
        [Parameter(Mandatory=$true)]
        [PSCredential]
        $Credential,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [string[]]
        $Name,
        [Parameter(Mandatory=$false)]
        [ValidateSet("implementation","obsolete","production","stock")]
        [string[]]
        $Status,
        [Parameter(Mandatory=$false)]
        [string[]]
        $OrganizationName,
        [Parameter(Mandatory=$false)]
        [string[]]
        $VirtualHostName,
        [Parameter(Mandatory=$false)]
        [string]
        $OQLFilter
    )
    process {
        $Class = "VirtualMachine"
        $FinalOQLFilter = @()
        if ($Name) {
            $Filter = " name IN ("
            foreach ($AName in $Name) { $Filter += """$AName""," }
            $Filter = $Filter.Substring(0,$Filter.Length-1)
            $Filter += ") "
            $FinalOQLFilter += $Filter
        }
        if ($OrganizationName) {
            $Filter = " organization_name IN ("
            foreach ($AOrganizationName in $OrganizationName) { $Filter += """$AOrganizationName""," }
            $Filter = $Filter.Substring(0,$Filter.Length-1)
            $Filter += ") "
            $FinalOQLFilter += $Filter
        }
        if ($Status) {
            $Filter = " status IN ("
            foreach ($AStatus in $Status) { $Filter += """$AStatus""," }
            $Filter = $Filter.Substring(0,$Filter.Length-1)
            $Filter += ") "
            $FinalOQLFilter += $Filter
        }
        if ($VirtualHostName) {
            $Filter = " virtualhost_name IN ("
            foreach ($AVirtualHostName in $VirtualHostName) { $Filter += """$AVirtualHostName""," }
            $Filter = $Filter.Substring(0,$Filter.Length-1)
            $Filter += ") "
            $FinalOQLFilter += $Filter
        }
        if ($OQLFilter) {
            $FinalOQLFilter += $OQLFilter
        }
        $FinalOQLFilterStr = $FinalOQLFilter -join " AND "
        Get-Object -Uri $Uri -Credential $Credential -Class $Class -OQLFilter $FinalOQLFilterStr
    }
}


function Get-ApplicationSolution {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $Uri,
        [Parameter(Mandatory=$true)]
        [PSCredential]
        $Credential,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [string[]]
        $Name,
        [Parameter(Mandatory=$false)]
        [ValidateSet("active","inactive")]
        [string[]]
        $Status,
        [Parameter(Mandatory=$false)]
        [string[]]
        $OrganizationName,
        [Parameter(Mandatory=$false)]
        [string]
        $OQLFilter
    )
    process {
        $Class = "ApplicationSolution"
        $FinalOQLFilter = @()
        if ($Name) {
            $Filter = " name IN ("
            foreach ($AName in $Name) { $Filter += """$AName""," }
            $Filter = $Filter.Substring(0,$Filter.Length-1)
            $Filter += ") "
            $FinalOQLFilter += $Filter
        }
        if ($Status) {
            $Filter = " status IN ("
            foreach ($AStatus in $Status) { $Filter += """$AStatus""," }
            $Filter = $Filter.Substring(0,$Filter.Length-1)
            $Filter += ") "
            $FinalOQLFilter += $Filter
        }
        if ($OrganizationName) {
            $Filter = " organization_name IN ("
            foreach ($AOrganizationName in $OrganizationName) { $Filter += """$AOrganizationName""," }
            $Filter = $Filter.Substring(0,$Filter.Length-1)
            $Filter += ") "
            $FinalOQLFilter += $Filter
        }
        if ($OQLFilter) {
            $FinalOQLFilter += $OQLFilter
        }
        $FinalOQLFilterStr = $FinalOQLFilter -join " AND "
        Get-Object -Uri $Uri -Credential $Credential -Class $Class -OQLFilter $FinalOQLFilterStr
    }
}


function Get-Organization {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $Uri,
        [Parameter(Mandatory=$true)]
        [PSCredential]
        $Credential,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [string[]]
        $Name,
        [Parameter(Mandatory=$false)]
        [ValidateSet("active","inactive")]
        [string[]]
        $Status,
        [Parameter(Mandatory=$false)]
        [string]
        $OQLFilter
    )
    process {
        $Class = "Organization"
        $FinalOQLFilter = @()
        if ($Name) {
            $Filter = " name IN ("
            foreach ($AName in $Name) { $Filter += """$AName""," }
            $Filter = $Filter.Substring(0,$Filter.Length-1)
            $Filter += ") "
            $FinalOQLFilter += $Filter
        }
        if ($Status) {
            $Filter = " status IN ("
            foreach ($AStatus in $Status) { $Filter += """$AStatus""," }
            $Filter = $Filter.Substring(0,$Filter.Length-1)
            $Filter += ") "
            $FinalOQLFilter += $Filter
        }
        if ($OQLFilter) {
            $FinalOQLFilter += $OQLFilter
        }
        $FinalOQLFilterStr = $FinalOQLFilter -join " AND "
        Get-Object -Uri $Uri -Credential $Credential -Class $Class -OQLFilter $FinalOQLFilterStr
    }
}


function Get-Contact {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $Uri,
        [Parameter(Mandatory=$true)]
        [PSCredential]
        $Credential,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [int[]]
        $Id,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [string[]]
        $Email,
        [Parameter(Mandatory=$false)]
        [string[]]
        $Name,
        [Parameter(Mandatory=$false)]
        [ValidateSet("active","inactive")]
        [string[]]
        $Status,
        [Parameter(Mandatory=$false)]
        [string[]]
        $OrganizationName,
        [Parameter(Mandatory=$false)]
        [string]
        $OQLFilter
    )
    process {
        $Class = "Contact"
        $FinalOQLFilter = @()
        if ($Id) {
            $Filter = " id IN ("
            foreach ($AId in $Id) { $Filter += "$AId," }
            $Filter = $Filter.Substring(0,$Filter.Length-1)
            $Filter += ") "
            $FinalOQLFilter += $Filter
        }
        if ($Email) {
            $Filter = " email IN ("
            foreach ($AEmail in $Email) { $Filter += """$AEmail""," }
            $Filter = $Filter.Substring(0,$Filter.Length-1)
            $Filter += ") "
            $FinalOQLFilter += $Filter
        }
        if ($Name) {
            $Filter = " name IN ("
            foreach ($AName in $Name) { $Filter += """$AName""," }
            $Filter = $Filter.Substring(0,$Filter.Length-1)
            $Filter += ") "
            $FinalOQLFilter += $Filter
        }
        if ($Status) {
            $Filter = " status IN ("
            foreach ($AStatus in $Status) { $Filter += """$AStatus""," }
            $Filter = $Filter.Substring(0,$Filter.Length-1)
            $Filter += ") "
            $FinalOQLFilter += $Filter
        }
        if ($OrganizationName) {
            $Filter = " organization_name IN ("
            foreach ($AOrganizationName in $OrganizationName) { $Filter += """$AOrganizationName""," }
            $Filter = $Filter.Substring(0,$Filter.Length-1)
            $Filter += ") "
            $FinalOQLFilter += $Filter
        }
        if ($OQLFilter) {
            $FinalOQLFilter += $OQLFilter
        }
        $FinalOQLFilterStr = $FinalOQLFilter -join " AND "
        Get-Object -Uri $Uri -Credential $Credential -Class $Class -OQLFilter $FinalOQLFilterStr
    }
}


function Get-Person {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $Uri,
        [Parameter(Mandatory=$true)]
        [PSCredential]
        $Credential,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [int[]]
        $Id,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [string[]]
        $Email,
        [Parameter(Mandatory=$false)]
        [string[]]
        $Name,
        [Parameter(Mandatory=$false)]
        [ValidateSet("active","inactive")]
        [string[]]
        $Status,
        [Parameter(Mandatory=$false)]
        [string[]]
        $OrganizationName,
        [Parameter(Mandatory=$false)]
        [string]
        $OQLFilter
    )
    process {
        $Class = "Person"
        $FinalOQLFilter = @()
        if ($Id) {
            $Filter = " id IN ("
            foreach ($AId in $Id) { $Filter += "$AId," }
            $Filter = $Filter.Substring(0,$Filter.Length-1)
            $Filter += ") "
            $FinalOQLFilter += $Filter
        }
        if ($Email) {
            $Filter = " email IN ("
            foreach ($AEmail in $Email) { $Filter += """$AEmail""," }
            $Filter = $Filter.Substring(0,$Filter.Length-1)
            $Filter += ") "
            $FinalOQLFilter += $Filter
        }
        if ($Name) {
            $Filter = " name IN ("
            foreach ($AName in $Name) { $Filter += """$AName""," }
            $Filter = $Filter.Substring(0,$Filter.Length-1)
            $Filter += ") "
            $FinalOQLFilter += $Filter
        }
        if ($Status) {
            $Filter = " status IN ("
            foreach ($AStatus in $Status) { $Filter += """$AStatus""," }
            $Filter = $Filter.Substring(0,$Filter.Length-1)
            $Filter += ") "
            $FinalOQLFilter += $Filter
        }
        if ($OrganizationName) {
            $Filter = " organization_name IN ("
            foreach ($AOrganizationName in $OrganizationName) { $Filter += """$AOrganizationName""," }
            $Filter = $Filter.Substring(0,$Filter.Length-1)
            $Filter += ") "
            $FinalOQLFilter += $Filter
        }
        if ($OQLFilter) {
            $FinalOQLFilter += $OQLFilter
        }
        $FinalOQLFilterStr = $FinalOQLFilter -join " AND "
        Get-Object -Uri $uri -Credential $Credential -Class $Class -OQLFilter $FinalOQLFilterStr
    }
}


function Get-Team {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $Uri,
        [Parameter(Mandatory=$true)]
        [PSCredential]
        $Credential,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [int[]]
        $Id,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [string[]]
        $Email,
        [Parameter(Mandatory=$false)]
        [string[]]
        $Name,
        [Parameter(Mandatory=$false)]
        [ValidateSet("active","inactive")]
        [string[]]
        $Status,
        [Parameter(Mandatory=$false)]
        [string[]]
        $OrganizationName,
        [Parameter(Mandatory=$false)]
        [string]
        $OQLFilter
    )
    process {
        $Class = "Team"
        $FinalOQLFilter = @()
        if ($Id) {
            $Filter = " id IN ("
            foreach ($AId in $Id) { $Filter += "$AId," }
            $Filter = $Filter.Substring(0,$Filter.Length-1)
            $Filter += ") "
            $FinalOQLFilter += $Filter
        }
        if ($Email) {
            $Filter = " email IN ("
            foreach ($AEmail in $Email) { $Filter += """$AEmail""," }
            $Filter = $Filter.Substring(0,$Filter.Length-1)
            $Filter += ") "
            $FinalOQLFilter += $Filter
        }
        if ($Name) {
            $Filter = " name IN ("
            foreach ($AName in $Name) { $Filter += """$AName""," }
            $Filter = $Filter.Substring(0,$Filter.Length-1)
            $Filter += ") "
            $FinalOQLFilter += $Filter
        }
        if ($Status) {
            $Filter = " status IN ("
            foreach ($AStatus in $Status) { $Filter += """$AStatus""," }
            $Filter = $Filter.Substring(0,$Filter.Length-1)
            $Filter += ") "
            $FinalOQLFilter += $Filter
        }
        if ($OrganizationName) {
            $Filter = " organization_name IN ("
            foreach ($AOrganizationName in $OrganizationName) { $Filter += """$AOrganizationName""," }
            $Filter = $Filter.Substring(0,$Filter.Length-1)
            $Filter += ") "
            $FinalOQLFilter += $Filter
        }
        if ($OQLFilter) {
            $FinalOQLFilter += $OQLFilter
        }
        $FinalOQLFilterStr = $FinalOQLFilter -join " AND "
        Get-Object -Uri $Uri -Credential $Credential -Class $Class -OQLFilter $FinalOQLFilterStr
    }
}
