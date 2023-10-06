<#
.SYNOPSIS
This PowerShell script monitors Microsoft Intune-managed devices and reports newly enrolled devices.

.DESCRIPTION
The script performs the following tasks:
1. Checks for the presence of the "Microsoft.Graph.Intune" PowerShell module and installs it if missing.
2. Establishes a connection to Microsoft Graph.
3. Updates the Microsoft Graph environment schema to the beta version.
4. Queries Intune-managed devices that meet the enrollment criteria.
5. Sends a message to a Microsoft Teams channel with details of the enrolled devices, if any.
6. Repeats the monitoring process at regular intervals.

.NOTES
- You should replace the webhook URLs with your actual Microsoft Teams webhook URLs.
- Customize the script as needed for your environment.
- Ensure that the "Run-IntuneCheck" function, which is referenced but not defined in this script, is defined elsewhere in your environment.

.AUTHOR
Matthew Wicks

.COPYRIGHT
Copyright (c) Your Organization. All rights reserved. Licensed under the MIT license.
See LICENSE in the project root for license information.

#>

do {
    <#
    .COPYRIGHT
    Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.
    See LICENSE in the project root for license information.
    #>
    ####################################################
    $IntuneModule = Get-Module -Name "Microsoft.Graph.Intune" -ListAvailable

    if (!$IntuneModule) {
        Write-Host "Microsoft.Graph.Intune Powershell module not installed..." -f Red
        Write-Host "Install by running 'Install-Module Microsoft.Graph.Intune' from an elevated PowerShell prompt" -f Yellow
        Write-Host "Script can't continue..." -f Red
        Write-Host
        exit
    }

    ####################################################

    if (!(Connect-MSGraph)) {
        Connect-MSGraph
    }

    ####################################################

    Update-MSGraphEnvironment -SchemaVersion beta -Quiet

    ####################################################

    # Filter for the minimum number of minutes when the device enrolled into the Intune Service

    # 360 = 6 hours
    $minutes = 360

    $minutesago = "{0:s}" -f (get-date).addminutes(0-$minutes) + "Z"

    $CurrentTime = [System.DateTimeOffset]::Now

    Write-Host
    write-host "Checking if any Intune Managed Device Enrolled Date is within or equal to $minutes minutes..." -f Yellow
    Write-Host
    write-host "Minutes Ago:" $minutesago -f Magenta
    Write-Host

    ####################################################

    $Devices = Get-IntuneManagedDevice -Filter "enrolledDateTime ge $minutesago" | sort deviceName

    $Devices = $Devices | ? { $_.managementAgent -ne "eas" }


    if ($Devices) {
        $DeviceCount = @($Devices).count

        # Create the message content
        $Message = @"
        **Devices Enrolled in the Past $minutes Minutes:**
        Total Devices: $DeviceCount

"@

        # Add device details to the message
        foreach ($Device in $Devices) {
            $Message += @"
            **Device Name:** $($Device.deviceName)
            **Management State:** $($Device.managementState)
            **Operating System:** $($Device.operatingSystem)
            **Device Type:** $($Device.deviceType)
            **Last Sync Date Time:** $($Device.lastSyncDateTime)
            **Enrolled Date Time:** $($Device.enrolledDateTime)
            **Jail Broken:** $($Device.jailBroken)
            **Compliance State:** $($Device.complianceState)
            **AAD Registered:** $($Device.aadRegistered)
            **Management Agent:** $($Device.managementAgent)
            **Date Time difference is:** $TotalMinutes minutes from the current date time
"@
        }

        # Replace this with your actual Teams webhook URL
        $WebhookUrl = ""

        # Send the message to Teams using the webhook
        $Headers = @{
            "Content-Type" = "application/json"
        }

        $Body = @{
            text = $Message
        } | ConvertTo-JSon

        Invoke-RestMethod -Uri $WebhookUrl -Method Post -Headers $Headers -Body $Body
    } else {
        # If no devices enrolled in the past $minutes minutes, create a message
        $Message = "There have been no devices enrolled or checked into business in the last $minutes minutes found,  when I find a device I will print out details here."

        # Replace this with your actual Teams webhook URL
        $WebhookUrl = ""

        # Send the message to Teams using the webhook
        $Headers = @{
            "Content-Type" = "application/json"
        }

        $Body = @{
            text = $Message
        } | ConvertTo-Json

        Invoke-RestMethod -Uri $WebhookUrl -Method Post -Headers $Headers -Body $Body
    }

    # Define the interval in seconds (6 hours)
    $IntervalInSeconds = 6 * 60 * 60

    # Sleep for the defined interval
    Write-Host "Update complete. Sleeping for 6 hours..." -ForegroundColor Green
    Start-Sleep -Seconds $IntervalInSeconds
} while ($true)
