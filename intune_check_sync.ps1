# Define a function to post messages to Teams
function Send-TeamsMessage {
    param (
        [string]$WebhookUrl,
        [string]$Summary,
        [string]$Text
    )

    $Headers = @{
        "Content-Type" = "application/json"
    }

    $Body = @{
        summary = $Summary
        text = $Text
    } | ConvertTo-Json

    Invoke-RestMethod -Uri $WebhookUrl -Method Post -Headers $Headers -Body $Body
}

# Set your Teams webhook URL
$TeamsWebhookUrl = ""

# Function to check and send Intune device status
function Check-IntuneDeviceStatus {
    param (
        [int]$days
    )

    $daysago = "{0:s}" -f (Get-Date).AddDays(-$days) + "Z"

    $CurrentTime = [System.DateTimeOffset]::Now

    $result = @()  # Initialize an empty array to store results

    Write-Host
    Write-Host "Checking to see if there are devices that haven't synced in the last $days days..." -f Yellow
    Write-Host

    # Filter devices not synced in the past $days days
    $Devices = Get-IntuneManagedDevice -Filter "lastSyncDateTime le $daysago" | Sort-Object deviceName

    $Devices = $Devices | Where-Object { $_.managementAgent -ne "eas" }

    # If there are devices not synced in the past $days days, loop through and gather details
    if ($Devices) {
        $DeviceCount = $Devices.Count

        Write-Host "There are $DeviceCount devices that have not synced in the last $days days..." -ForegroundColor Red
        Write-Host

        # Loop through the devices and gather details
        foreach ($Device in $Devices) {
            Write-Host "------------------------------------------------------------------"
            Write-Host

            $DeviceDetails = @"

 Devices which have not been Synced in the last $days days,  these will be needing to be synced in the near future.
<hr>

**Device Name :**
$($Device.deviceName)

**Management State :**
$($Device.managementState)

**Operating System :**
$($Device.operatingSystem)

**Device Type :**
$($Device.deviceType)

**Last Sync Date Time :**
$($Device.lastSyncDateTime)

**Enrolled Date Time :**
$($Device.enrolledDateTime)

**Jail Broken :**
$($Device.jailBroken)

**Compliance State :**
$($Device.complianceState)

**AAD Registered :**
$($Device.aadRegistered)

**Management Agent :**
$($Device.managementAgent)

**Days Since Last Sync :**
$([string]($CurrentTime - $Device.lastSyncDateTime).Days)

"@

            # Add the device details to the result array
            $result += $DeviceDetails
        }

        # Join the device details with line breaks to separate the results
        $resultText = $result -join "`n`n"

        # Post the result to Teams with a summary
        Send-TeamsMessage -WebhookUrl $TeamsWebhookUrl -Summary "Intune Check Result" -Text $resultText
    } else {
        Write-Host "------------------------------------------------------------------"
        Write-Host
        Write-Host "No devices not checked in the last $days days found..." -f green
        Write-Host

        # Post a message to Teams indicating no devices found
        $noDevicesMessage = @{
            "Message" = "No devices not checked in the last $days days found..."
        } | ConvertTo-Json

        # Post the message to Teams
        Send-TeamsMessage -WebhookUrl $TeamsWebhookUrl -Summary "Intune Check Result" -Text $noDevicesMessage
    }
}

# Define the interval in seconds (6 hours)
$IntervalInSeconds = 6 * 60 * 60

# Loop indefinitely with a 6-hour interval
while ($true) {
    Write-Host "Running Intune check..." -ForegroundColor Yellow
    Check-IntuneDeviceStatus -days 30  # Call the function to check and send Intune device status

    Write-Host "Update complete. Sleeping for 6 hours..." -ForegroundColor Green
    Start-Sleep -Seconds $IntervalInSeconds
}
