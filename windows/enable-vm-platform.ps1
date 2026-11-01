# Enable the Virtual Machine Platform optional feature. A reboot may be required.

Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart
