<#
.SYNOPSIS
    Configures a Windows 10/11 workstation for reliable always-on operation.

.DESCRIPTION
    Main behavior:
      - Creates or reuses one custom power plan named "Always On Workstation".
      - AC: system sleep, display timeout, and disk timeout = Never.
      - DC: system sleep, display timeout, and disk timeout = 30 minutes.
      - Disables Windows hibernation (S4 / Fast Startup dependency).
      - Disables hybrid sleep on AC.
      - Disables USB selective suspend on AC and DC.
      - Disables PCIe Link State Power Management on AC and DC.
      - Sets processor minimum/maximum to 10/100% AC and 0/100% DC.
      - Disables adaptive brightness on AC and enables it on DC when supported.
      - Dynamically discovers physical Ethernet/Wi-Fi adapters and disables
        known EEE/Green/Power-Saving advanced properties when the driver exposes them.
      - Dell: disables DeepSleepCtrl when the supported Dell BIOS CIM interface exposes it.
      - HP: disables S5 Maximum Power Savings (or the equivalent exposed name) when supported.
      - Writes a log to C:\ProgramData\AlwaysOnWorkstation\AlwaysOnWorkstation.log.

    The script is designed to be rerunnable. It reuses the existing custom power plan
    rather than creating another copy each time.

.PARAMETER Restart
    Schedule a reboot in 60 seconds after configuration. Default: no automatic reboot.

.PARAMETER NoSelfElevation
    Do not attempt a UAC self-elevation. Useful for SCCM, scheduled tasks, WinRM, or other
    management tools that already run the script elevated. If not elevated, the script exits.

.EXAMPLE
    .\Always-On-Workstation.ps1

.EXAMPLE
    .\Always-On-Workstation.ps1 -Restart

.EXAMPLE
    .\Always-On-Workstation.ps1 -NoSelfElevation

.NOTES
    Author: Brad Rott
    Target: Windows 10/11, Windows PowerShell 5.1+
#>

[CmdletBinding()]
param(
    [switch]$Restart,
    [switch]$NoSelfElevation
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$PlanName = 'Always On Workstation'
$LogDirectory = Join-Path $env:ProgramData 'AlwaysOnWorkstation'
$LogPath = Join-Path $LogDirectory 'AlwaysOnWorkstation.log'
$script:Warnings = 0
$script:Failures = 0
$script:RebootRecommended = $false

# Use GUIDs for settings without reliable aliases.
$PowerGuids = @{
    SleepSubgroup       = '238c9fa8-0aad-41ed-83f4-97be242c8f20'
    HybridSleep         = '94ac6d29-73ce-41a6-809f-6363ba21b47e'
    UsbSubgroup         = '2a737441-1930-4402-8d77-b2bebba308a3'
    UsbSelectiveSuspend = '48e6b7a6-50f5-4782-a5d4-53bb8f07e226'
    PcieSubgroup        = '501a4d13-42af-4429-9fd1-a8218c268e20'
    PcieLinkState       = 'ee12f906-d277-404b-b6da-e5fa1a576df5'
    ProcessorSubgroup   = '54533251-82be-4824-96c1-47b60b740d00'
    ProcessorMin        = '893dee8e-2bef-41e0-89c6-b55d0929964c'
    ProcessorMax        = 'bc5038f7-23e0-4960-96da-33abaf5935ec'
    VideoSubgroup       = '7516b95f-f776-4464-8c53-06167f40cc99'
    AdaptiveBrightness  = 'aded5e82-b909-4619-9949-f5d71dac0bcb'
}

function Write-Status {
    param(
        [Parameter(Mandatory = $true)][ValidateSet('INFO','OK','SKIP','WARN','FAIL')][string]$Level,
        [Parameter(Mandatory = $true)][string]$Message
    )

    $line = '[{0}] [{1}] {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level, $Message

    switch ($Level) {
        'OK'   { Write-Host $line -ForegroundColor Green }
        'SKIP' { Write-Host $line -ForegroundColor DarkGray }
        'WARN' { Write-Host $line -ForegroundColor Yellow; $script:Warnings++ }
        'FAIL' { Write-Host $line -ForegroundColor Red; $script:Failures++ }
        default { Write-Host $line }
    }

    try { Add-Content -LiteralPath $LogPath -Value $line -Encoding UTF8 } catch { }
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Ensure-Administrator {
    if (Test-IsAdministrator) { return }

    if ($NoSelfElevation) {
        throw 'Administrator privileges are required, and -NoSelfElevation was specified.'
    }

    # UAC self-elevation is useful for an interactive local launch. For remote/SCCM deployment,
    # run already elevated and pass -NoSelfElevation so the job never waits for a hidden UAC prompt.
    if (-not [Environment]::UserInteractive) {
        throw 'Administrator privileges are required. Noninteractive sessions cannot answer UAC; run the script elevated.'
    }

    if ([string]::IsNullOrWhiteSpace($PSCommandPath)) {
        throw 'Unable to self-elevate because the script path is unavailable.'
    }

    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ('"{0}"' -f $PSCommandPath))
    if ($Restart) { $argList += '-Restart' }
    $argList += '-NoSelfElevation'

    Start-Process -FilePath 'powershell.exe' -ArgumentList ($argList -join ' ') -Verb RunAs | Out-Null
    exit 0
}

function Invoke-PowerCfg {
    param(
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [Parameter(Mandatory = $true)][string]$Description,
        [switch]$Required
    )

    $output = & powercfg.exe @Arguments 2>&1
    $exitCode = $LASTEXITCODE
    $text = ($output | Out-String).Trim()

    if ($exitCode -eq 0) {
        Write-Status OK $Description
        return $true
    }

    if ($Required) {
        Write-Status FAIL ("{0} -- powercfg exit {1}: {2}" -f $Description, $exitCode, $text)
    }
    else {
        Write-Status WARN ("{0} -- unsupported or failed (exit {1}): {2}" -f $Description, $exitCode, $text)
    }
    return $false
}

function Get-PowerSchemeList {
    $lines = & powercfg.exe /list 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Unable to enumerate power schemes: $($lines -join ' ')" }

    $schemes = @()
    foreach ($line in $lines) {
        # Typical English output:
        # Power Scheme GUID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  (Name) *
        if ($line -match '([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})\s+\((.+?)\)(\s+\*)?\s*$') {
            $schemes += [pscustomobject]@{
                Guid = $matches[1]
                Name = $matches[2]
                Active = [bool]$matches[3]
            }
        }
    }
    return $schemes
}

function Get-ActivePowerSchemeGuid {
    $output = & powercfg.exe /getactivescheme 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Unable to read active power scheme: $($output -join ' ')" }
    $joined = $output -join ' '
    if ($joined -notmatch '([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})') {
        throw "Unable to parse active power scheme GUID from: $joined"
    }
    return $matches[1]
}

function Ensure-CustomPowerPlan {
    $schemes = @(Get-PowerSchemeList)
    $existingPlans = @($schemes | Where-Object { $_.Name -eq $PlanName })

    if ($existingPlans.Count -gt 0) {
        if ($existingPlans.Count -gt 1) {
            Write-Status WARN ("Found {0} existing '{1}' plans from older runs. Reusing one instead of creating another." -f $existingPlans.Count, $PlanName)
        }

        $chosen = $existingPlans | Where-Object { $_.Active } | Select-Object -First 1
        if ($null -eq $chosen) { $chosen = $existingPlans | Select-Object -First 1 }

        if (-not (Invoke-PowerCfg -Arguments @('/setactive', $chosen.Guid) -Description "Activated existing '$PlanName' plan" -Required)) {
            throw "Unable to activate existing '$PlanName' power plan."
        }
        return $chosen.Guid
    }

    $sourceGuid = Get-ActivePowerSchemeGuid
    $dupOutput = & powercfg.exe /duplicatescheme $sourceGuid 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Unable to duplicate active power plan: $($dupOutput -join ' ')" }

    $dupText = $dupOutput -join ' '
    if ($dupText -notmatch '([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})') {
        throw "Power plan was duplicated, but the new GUID could not be parsed: $dupText"
    }

    $newGuid = $matches[1]
    if (-not (Invoke-PowerCfg -Arguments @('/changename', $newGuid, $PlanName) -Description "Named new power plan '$PlanName'" -Required)) {
        throw "Unable to name the new '$PlanName' power plan."
    }
    if (-not (Invoke-PowerCfg -Arguments @('/setactive', $newGuid) -Description "Activated new '$PlanName' plan" -Required)) {
        throw "Unable to activate the new '$PlanName' power plan."
    }
    return $newGuid
}

function Set-WindowsPowerConfiguration {
    Write-Status INFO 'Applying Windows power settings.'

    # /change applies to the active plan and does not accept a plan GUID.
    Invoke-PowerCfg -Arguments @('/change','standby-timeout-ac','0')  -Description 'AC system sleep: Never' | Out-Null
    Invoke-PowerCfg -Arguments @('/change','standby-timeout-dc','30') -Description 'DC system sleep: 30 minutes' | Out-Null
    Invoke-PowerCfg -Arguments @('/change','monitor-timeout-ac','0')  -Description 'AC display timeout: Never' | Out-Null
    Invoke-PowerCfg -Arguments @('/change','monitor-timeout-dc','30') -Description 'DC display timeout: 30 minutes' | Out-Null
    Invoke-PowerCfg -Arguments @('/change','disk-timeout-ac','0')     -Description 'AC disk timeout: Never' | Out-Null
    Invoke-PowerCfg -Arguments @('/change','disk-timeout-dc','30')    -Description 'DC disk timeout: 30 minutes' | Out-Null

    # Set hybrid sleep BEFORE disabling hibernation. Once hibernation is disabled, Windows can hide/remove
    # the hybrid-sleep setting and powercfg may report it as invalid on some machines.
    Invoke-PowerCfg -Arguments @('/setacvalueindex','SCHEME_CURRENT',$PowerGuids.SleepSubgroup,$PowerGuids.HybridSleep,'0') -Description 'AC hybrid sleep disabled' | Out-Null

    # Hibernation is global, not just per-plan. This also disables Fast Startup on normal Windows configurations.
    Invoke-PowerCfg -Arguments @('/hibernate','off') -Description 'Windows hibernation (S4) disabled' | Out-Null


    Invoke-PowerCfg -Arguments @('/setacvalueindex','SCHEME_CURRENT',$PowerGuids.UsbSubgroup,$PowerGuids.UsbSelectiveSuspend,'0') -Description 'AC USB selective suspend disabled' | Out-Null
    Invoke-PowerCfg -Arguments @('/setdcvalueindex','SCHEME_CURRENT',$PowerGuids.UsbSubgroup,$PowerGuids.UsbSelectiveSuspend,'0') -Description 'DC USB selective suspend disabled' | Out-Null

    # PCIe Link State Power Management / ASPM.
    Invoke-PowerCfg -Arguments @('/setacvalueindex','SCHEME_CURRENT',$PowerGuids.PcieSubgroup,$PowerGuids.PcieLinkState,'0') -Description 'AC PCIe Link State Power Management disabled' | Out-Null
    Invoke-PowerCfg -Arguments @('/setdcvalueindex','SCHEME_CURRENT',$PowerGuids.PcieSubgroup,$PowerGuids.PcieLinkState,'0') -Description 'DC PCIe Link State Power Management disabled' | Out-Null

    # Processor state.
    Invoke-PowerCfg -Arguments @('/setacvalueindex','SCHEME_CURRENT',$PowerGuids.ProcessorSubgroup,$PowerGuids.ProcessorMin,'10') -Description 'AC minimum processor state: 10%' | Out-Null
    Invoke-PowerCfg -Arguments @('/setdcvalueindex','SCHEME_CURRENT',$PowerGuids.ProcessorSubgroup,$PowerGuids.ProcessorMin,'0')  -Description 'DC minimum processor state: 0%' | Out-Null
    Invoke-PowerCfg -Arguments @('/setacvalueindex','SCHEME_CURRENT',$PowerGuids.ProcessorSubgroup,$PowerGuids.ProcessorMax,'100') -Description 'AC maximum processor state: 100%' | Out-Null
    Invoke-PowerCfg -Arguments @('/setdcvalueindex','SCHEME_CURRENT',$PowerGuids.ProcessorSubgroup,$PowerGuids.ProcessorMax,'100') -Description 'DC maximum processor state: 100%' | Out-Null

    # Adaptive brightness is not exposed on every system. Unsupported hardware is a warning, not fatal.
    Invoke-PowerCfg -Arguments @('/setacvalueindex','SCHEME_CURRENT',$PowerGuids.VideoSubgroup,$PowerGuids.AdaptiveBrightness,'0') -Description 'AC adaptive brightness disabled' | Out-Null
    Invoke-PowerCfg -Arguments @('/setdcvalueindex','SCHEME_CURRENT',$PowerGuids.VideoSubgroup,$PowerGuids.AdaptiveBrightness,'1') -Description 'DC adaptive brightness enabled' | Out-Null

    # Commit/re-activate after indexed changes.
    Invoke-PowerCfg -Arguments @('/setactive','SCHEME_CURRENT') -Description 'Re-applied active power scheme' -Required | Out-Null
}

function Get-DisabledRegistryValue {
    param([Parameter(Mandatory = $true)]$Property)

    # Prefer the driver's own display-to-registry mapping instead of assuming every vendor uses 0/1.
    try {
        $validDisplay = @()
        $validRegistry = @()
        if ($Property.PSObject.Properties.Name -contains 'ValidDisplayValues' -and $null -ne $Property.ValidDisplayValues) {
            $validDisplay = @($Property.ValidDisplayValues)
        }
        if ($Property.PSObject.Properties.Name -contains 'ValidRegistryValues' -and $null -ne $Property.ValidRegistryValues) {
            $validRegistry = @($Property.ValidRegistryValues)
        }

        foreach ($candidate in @('Disabled','Disable','Off')) {
            for ($i = 0; $i -lt $validDisplay.Count; $i++) {
                if ([string]$validDisplay[$i] -eq $candidate -and $i -lt $validRegistry.Count) {
                    return [string]$validRegistry[$i]
                }
            }
        }

        # Safe fallback for the known tested properties when the driver does not expose display mappings.
        foreach ($candidate in @(0, '0')) {
            if ($validRegistry -contains $candidate) { return [string]$candidate }
        }
    }
    catch { }

    return $null
}

function Disable-NicEnergySaving {
    Write-Status INFO 'Discovering physical network adapters (Ethernet and Wi-Fi).'

    try {
        $adapters = @(Get-NetAdapter -Physical -ErrorAction Stop)
    }
    catch {
        Write-Status WARN ("Unable to enumerate physical NICs: {0}" -f $_.Exception.Message)
        return
    }

    if ($adapters.Count -eq 0) {
        Write-Status SKIP 'No physical network adapters were returned by Get-NetAdapter -Physical.'
        return
    }

    $targetKeywords = @('*EEE', 'EnableGreenEthernet', 'PowerSavingMode')

    foreach ($adapter in $adapters) {
        Write-Status INFO ("NIC: {0} -- {1}" -f $adapter.Name, $adapter.InterfaceDescription)

        try {
            $properties = @(Get-NetAdapterAdvancedProperty -Name $adapter.Name -AllProperties -ErrorAction Stop)
        }
        catch {
            Write-Status WARN ("{0}: cannot query advanced properties: {1}" -f $adapter.Name, $_.Exception.Message)
            continue
        }

        foreach ($keyword in $targetKeywords) {
            $prop = $properties | Where-Object { $_.RegistryKeyword -eq $keyword } | Select-Object -First 1
            if ($null -eq $prop) {
                Write-Status SKIP ("{0}: {1} not exposed by this driver" -f $adapter.Name, $keyword)
                continue
            }

            $disabledRegistryValue = Get-DisabledRegistryValue -Property $prop
            if ($null -eq $disabledRegistryValue) {
                Write-Status WARN ("{0}: {1} exists, but the driver did not publish a safe Disabled/Off mapping; left unchanged." -f $adapter.Name, $keyword)
                continue
            }

            try {
                Set-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword $keyword -RegistryValue $disabledRegistryValue -NoRestart -ErrorAction Stop
                Write-Status OK ("{0}: disabled {1} ({2})" -f $adapter.Name, $keyword, $prop.DisplayName)
                $script:RebootRecommended = $true
            }
            catch {
                Write-Status WARN ("{0}: unable to disable {1}: {2}" -f $adapter.Name, $keyword, $_.Exception.Message)
            }
        }

        # We deliberately do not force Set-NetAdapterPowerManagement/AllowComputerToTurnOffDevice:
        # some tested NIC drivers reported those fields as Unsupported. The script only changes
        # properties the installed driver actually exposes.
    }
}

function Get-Manufacturer {
    try {
        return (Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop).Manufacturer
    }
    catch {
        Write-Status WARN ("Unable to determine computer manufacturer: {0}" -f $_.Exception.Message)
        return ''
    }
}

function Set-DellDeepSleep {
    Write-Status INFO 'Dell detected; checking for DeepSleepCtrl.'

    # Use the agentless Dell BIOS interface first.
    try {
        $namespace = 'root/dcim/sysman/biosattributes'
        $attr = Get-CimInstance -Namespace $namespace -ClassName EnumerationAttribute -ErrorAction Stop |
            Where-Object { $_.AttributeName -eq 'DeepSleepCtrl' } |
            Select-Object -First 1

        if ($null -ne $attr) {
            $current = [string]$attr.CurrentValue
            if ($current -eq 'Disabled') {
                Write-Status SKIP 'Dell DeepSleepCtrl is already Disabled.'
                return
            }

            $iface = Get-CimInstance -Namespace $namespace -ClassName BIOSAttributeInterface -ErrorAction Stop | Select-Object -First 1
            if ($null -eq $iface) { throw 'BIOSAttributeInterface was not returned.' }

            $result = Invoke-CimMethod -InputObject $iface -MethodName SetAttribute -Arguments @{
                SecType        = 0
                SecHndCount    = 0
                SecHandle      = [byte[]]@()
                AttributeName  = 'DeepSleepCtrl'
                AttributeValue = 'Disabled'
            } -ErrorAction Stop

            $status = $null
            if ($result.PSObject.Properties.Name -contains 'Status') { $status = $result.Status }
            if ($null -eq $status -or [int]$status -eq 0) {
                Write-Status OK 'Dell DeepSleepCtrl set to Disabled.'
                $script:RebootRecommended = $true
                return
            }

            Write-Status WARN ("Dell BIOS returned status {0} while setting DeepSleepCtrl." -f $status)
            return
        }
    }
    catch {
        Write-Status SKIP ("Dell biosattributes interface unavailable or not usable: {0}" -f $_.Exception.Message)
    }

    # Fallback for Dell Command | Monitor systems exposing root\dcim\sysman / DCIM_BIOSService.
    try {
        $namespace = 'root/dcim/sysman'
        $attr = Get-CimInstance -Namespace $namespace -ClassName DCIM_BIOSEnumeration -ErrorAction Stop |
            Where-Object { $_.AttributeName -eq 'DeepSleepCtrl' } |
            Select-Object -First 1

        if ($null -eq $attr) {
            Write-Status SKIP 'Dell DeepSleepCtrl is not exposed on this system.'
            return
        }

        $desiredValue = 'Disabled'
        if (($attr.PSObject.Properties.Name -contains 'PossibleValues') -and
            ($attr.PSObject.Properties.Name -contains 'PossibleValuesDescription')) {
            $values = @($attr.PossibleValues)
            $descriptions = @($attr.PossibleValuesDescription)
            for ($i = 0; $i -lt [Math]::Min($values.Count, $descriptions.Count); $i++) {
                if ([string]$descriptions[$i] -eq 'Disabled') {
                    $desiredValue = [string]$values[$i]
                    break
                }
            }
        }

        if (@($attr.CurrentValue) -contains $desiredValue -or [string]$attr.CurrentValue -eq 'Disabled') {
            Write-Status SKIP 'Dell DeepSleepCtrl is already Disabled.'
            return
        }

        $service = Get-CimInstance -Namespace $namespace -ClassName DCIM_BIOSService -ErrorAction Stop | Select-Object -First 1
        $result = Invoke-CimMethod -InputObject $service -MethodName SetBIOSAttributes -Arguments @{
            AttributeName  = @('DeepSleepCtrl')
            AttributeValue = @($desiredValue)
        } -ErrorAction Stop

        $returnValue = $null
        if ($result.PSObject.Properties.Name -contains 'ReturnValue') { $returnValue = $result.ReturnValue }
        if ($null -eq $returnValue -or [int]$returnValue -eq 0) {
            Write-Status OK 'Dell DeepSleepCtrl set to Disabled through DCIM_BIOSService.'
            $script:RebootRecommended = $true
        }
        else {
            Write-Status WARN ("Dell DCIM_BIOSService returned {0}; a BIOS administrator password may be required." -f $returnValue)
        }
    }
    catch {
        Write-Status SKIP ("Dell DeepSleepCtrl could not be changed: {0}" -f $_.Exception.Message)
    }
}

function Get-HpBiosSettings {
    try {
        return @(Get-CimInstance -Namespace 'root/HP/InstrumentedBIOS' -ClassName HP_BIOSSetting -ErrorAction Stop)
    }
    catch {
        return @()
    }
}

function Invoke-HpBiosSetting {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Value
    )

    try {
        $iface = Get-CimInstance -Namespace 'root/HP/InstrumentedBIOS' -ClassName HP_BIOSSettingInterface -ErrorAction Stop | Select-Object -First 1
        if ($null -eq $iface) { throw 'HP_BIOSSettingInterface was not returned.' }

        # <utf-16/> is accepted by HP's interface as an empty password token on systems with no BIOS password.
        $result = Invoke-CimMethod -InputObject $iface -MethodName SetBIOSSetting -Arguments @{
            Name = $Name
            Value = $Value
            Password = '<utf-16/>'
        } -ErrorAction Stop

        $returnCode = $null
        foreach ($field in @('Return','ReturnValue')) {
            if ($result.PSObject.Properties.Name -contains $field) {
                $returnCode = [int]$result.$field
                break
            }
        }

        if ($null -eq $returnCode -or $returnCode -eq 0) {
            Write-Status OK ("HP BIOS: {0} = {1}" -f $Name, $Value)
            $script:RebootRecommended = $true
            return $true
        }

        Write-Status WARN ("HP BIOS rejected '{0} = {1}' with return code {2}. A BIOS password or different firmware value may be required." -f $Name, $Value, $returnCode)
        return $false
    }
    catch {
        Write-Status WARN ("HP BIOS setting '{0}' could not be changed: {1}" -f $Name, $_.Exception.Message)
        return $false
    }
}

function Set-HpPowerFirmware {
    Write-Status INFO 'HP detected; checking InstrumentedBIOS power settings.'
    $settings = @(Get-HpBiosSettings)
    if ($settings.Count -eq 0) {
        Write-Status SKIP 'HP InstrumentedBIOS settings are not exposed on this system.'
        return
    }

    $s5Names = @(
        'S5 Maximum Power Savings',
        'S4/S5 Max Power Savings',
        'Deep Sleep'
    )

    $setting = $null
    foreach ($name in $s5Names) {
        $setting = $settings | Where-Object { $_.Name -eq $name } | Select-Object -First 1
        if ($null -ne $setting) { break }
    }

    if ($null -eq $setting) {
        Write-Status SKIP 'No supported HP S4/S5 deep power-saving setting was found.'
    }
    else {
        $current = ''
        if ($setting.PSObject.Properties.Name -contains 'CurrentValue') { $current = [string]$setting.CurrentValue }
        elseif ($setting.PSObject.Properties.Name -contains 'Value') { $current = [string]$setting.Value }

        if ($current -match '^(Disable|Disabled|Off)(,|$)') {
            Write-Status SKIP ("HP BIOS '{0}' is already disabled." -f $setting.Name)
        }
        else {
            [void](Invoke-HpBiosSetting -Name $setting.Name -Value 'Disable')
        }
    }

}

function Set-ManufacturerFirmwarePower {
    $manufacturer = Get-Manufacturer
    if ([string]::IsNullOrWhiteSpace($manufacturer)) { return }

    Write-Status INFO ("Manufacturer: {0}" -f $manufacturer)

    if ($manufacturer -match 'Dell') {
        Set-DellDeepSleep
    }
    elseif ($manufacturer -match 'HP|Hewlett-Packard') {
        Set-HpPowerFirmware
    }
    else {
        Write-Status SKIP ("No manufacturer-specific BIOS power changes are defined for '{0}'." -f $manufacturer)
    }
}

function Write-FinalSummary {
    Write-Host ''
    Write-Host '================ Always On Workstation Summary ================'
    try {
        $active = (& powercfg.exe /getactivescheme 2>&1 | Out-String).Trim()
        Write-Host ("Active power scheme: {0}" -f $active)
    }
    catch { }

    Write-Host ("Warnings: {0}" -f $script:Warnings)
    Write-Host ("Failures: {0}" -f $script:Failures)
    Write-Host ("Log: {0}" -f $LogPath)

    if ($script:RebootRecommended) {
        Write-Host 'A reboot is recommended because firmware and/or NIC settings were changed.' -ForegroundColor Yellow
    }
}

try {
    Ensure-Administrator

    if (-not (Test-Path -LiteralPath $LogDirectory)) {
        New-Item -Path $LogDirectory -ItemType Directory -Force | Out-Null
    }

    Write-Status INFO 'Starting Always On Workstation configuration.'
    Write-Status INFO ("Computer: {0}; User: {1}" -f $env:COMPUTERNAME, [Security.Principal.WindowsIdentity]::GetCurrent().Name)

    $planGuid = Ensure-CustomPowerPlan
    Write-Status INFO ("Using power plan GUID: {0}" -f $planGuid)

    Set-WindowsPowerConfiguration
    Disable-NicEnergySaving
    Set-ManufacturerFirmwarePower

    # Re-apply the selected plan one final time after all changes.
    Invoke-PowerCfg -Arguments @('/setactive', $planGuid) -Description "Confirmed '$PlanName' as active power plan" -Required | Out-Null

    Write-FinalSummary

    if ($Restart) {
        Write-Status WARN 'Restart requested; scheduling Windows restart in 60 seconds.'
        shutdown.exe /r /t 60 /c "Always On Workstation configuration complete" | Out-Null
    }
    elseif ($script:RebootRecommended) {
        Write-Status INFO 'No automatic restart requested. Reboot manually when convenient.'
    }

    if ($script:Failures -gt 0) { exit 1 }
    exit 0
}
catch {
    try {
        if (-not (Test-Path -LiteralPath $LogDirectory)) {
            New-Item -Path $LogDirectory -ItemType Directory -Force | Out-Null
        }
    }
    catch { }

    Write-Status FAIL $_.Exception.Message
    Write-FinalSummary
    exit 1
}
