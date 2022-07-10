function Test-Elevated {
    # Get the ID and security principal of the current user account
    $myIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $myPrincipal = new-object System.Security.Principal.WindowsPrincipal($myIdentity)
    # Check to see if we are currently running "as Administrator"
    return $myPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Convert-PSObjectToHashtable {
    Param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    process {
        if ($null -eq $InputObject) { return $null }

        if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [String]) {
            $collection = @(
                foreach ($object in $InputObject) { Convert-PSObjectToHashtable $object }
            )

            Write-Output -NoEnumerate $collection
        }
        elseif ($InputObject -is [PSObject]) {
            $hash = @{}

            foreach ($property in $InputObject.PSObject.Properties) {
                $hash[$property.Name] = Convert-PSObjectToHashtable $property.Value
            }

            $hash
        }
        else {
            $InputObject
        }
    }
}

function Prompt-ForChoice() {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0, Mandatory = $TRUE)]
        [String]
        $Question,

        [Parameter(Position = 1, Mandatory = $FALSE)]
        [String]
        $Default = "y"
    )

    Write-Host $Question

    if ($Default.ToLower() -eq "y") {
        do {
            $Reply = Read-Host -Prompt "[Y] Yes [N] No (default is 'Y')"
        }
        while (-not ($Reply -match "^(?:y|yes|n|no)$"))
        
        if ($Reply -match "^(?:n|no)$") { return $FALSE }
        return $TRUE
    }
    else {
        do {
            $Reply = Read-Host -Prompt "[Y] Yes [N] No (default is 'N')"
        }
        while (-not ($Reply -match "^(?:y|yes|n|no)$"))

        if ($Reply -match "^(?:y|yes)$") { return $TRUE }
        return $FALSE
    }
}

function Get-PSRepositoryTrustedStatus() {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0, Mandatory = $TRUE)]
        [String]
        $PSRepositoryName
    )
    
    try {
        if (-not (Get-PSRepository -Name $PSRepositoryName -ErrorAction SilentlyContinue)) {
            return $FALSE
        }
        
        if ((Get-PSRepository -Name $PSRepositoryName).InstallationPolicy -eq "Trusted") {
            return $TRUE
        }
        return $FALSE
    }
    catch [Exception] {
        return $FALSE
    }
}
function Select-FromArrayOptions() {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0, Mandatory = $TRUE)]
        [Array]
        $Array
    )

    # Force $Array to always be an array, even if only 1 thing in it, to remove if/then test.
    #$Array = @($Array)

    Do {
        for ($i = 0; $i -lt $Array.count; $i++) {
            Write-Host -ForegroundColor "Yellow" "  $($i+1)." $Array[$i]
        }
        $Reply = (Read-Host 'Please enter one of the available options (nummeric)') -as [int]

    } While ((-not $Reply) -or (0 -gt $Reply) -or ($Array.Count -lt $Reply))

    return $Array[$Reply - 1]
}