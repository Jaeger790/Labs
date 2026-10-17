# Always On Workstation

Configures Windows 10/11 power settings for an always-on workstation. Creates or reuses the `Always On Workstation` power plan, disables sleep and display/disk timeouts on AC, and sets those timeouts to 30 minutes on battery. Disables hibernation and Fast Startup, USB selective suspend and PCIe link-state power saving.

Checks physical network adapters for supported energy-saving properties. On Dell and HP systems, attempts supported firmware deep-sleep changes. Unsupported settings are logged and skipped or reported as warnings.

## Run

Use Windows PowerShell 5.1 or newer. Open PowerShell as Administrator, then run:

```powershell
.\Always-On-Workstation.ps1
```

For an already elevated deployment session:

```powershell
.\Always-On-Workstation.ps1 -NoSelfElevation
```

To request a restart in 60 seconds after configuration:

```powershell
.\Always-On-Workstation.ps1 -Restart
```

The default run does not restart the computer. Logs are written to `C:\ProgramData\AlwaysOnWorkstation\AlwaysOnWorkstation.log`. Check the summary for warnings and failures. Exit code 1 indicates a recorded failure or an unhandled error; warnings can still return 0.

## Notes

The script changes power and supported firmware settings. It does not install updates or enable PowerShell remoting. BIOS passwords and driver differences can prevent some changes. Hibernation is disabled globally, including on battery. Hardware behavior still needs validation on the target Windows workstation; this upload was not executed on a Windows machine.
