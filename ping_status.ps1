<#
Script Name: Teams Ping Status Script
Description: This PowerShell script periodically pings a list of servers, reports their status, and posts updates to a Teams channel via a webhook. It runs in an infinite loop, with configurable ping intervals.
Author: Matthew Wicks
Date: 10/09/2023

# Usage Instructions:

1. Configure the $pingWebhookUrl variable with your Teams webhook URL.
2. Customize the list of servers and their details in the $ipAddresses array.
3. Adjust the $pingIntervalSeconds and $batchSize variables to control the script's behavior.
4. Save this script and run it to start monitoring and reporting server status.

Note: This script uses Test-Connection to ping servers and posts HTML-formatted updates to Teams.

# Configuration Variables:

$pingWebhookUrl - Teams webhook URL for posting updates.

$ipAddresses - An array containing server details, including Name, Address, and Site.

$pingIntervalSeconds - The interval (in seconds) at which the script checks server status.

$batchSize - The number of servers to ping in each batch.

$offlineStatus - A hashtable to track offline status and calculate downtime.

$logFilePath - Path to the log file for recording server status updates.

# Output:

The script periodically sends server status updates to the specified Teams channel using a webhook.
Server status information is also logged to the specified log file.

# Important:

Make sure to secure and protect sensitive information, such as webhook URLs.

#>

$pingWebhookUrl = ""

$ipAddresses = @(
    @{ Name = "service"; Address = "ip"; Site = "local" },
    
)

$pingIntervalSeconds = 600
$batchSize = 8

$offlineStatus = @{}
$logFilePath = "ping_status_log.txt"

# Initialize $sites dynamically from $ipAddresses
$sites = $ipAddresses.Site | Sort-Object -Unique

while ($true) {
    $pingMessages = @()  

    $currentDateTime = Get-Date  

    $formattedMessage = @"
<!DOCTYPE html>
<html>
<head>
<style>
    body {
        font-family: Arial, sans-serif;
    }
    h2 {
        text-align: center;
    }
    p {
        margin: 5px;
    }
    h3 {
        margin-top: 15px;
        margin-bottom: 5px;
    }
</style>
</head>
<body>
<h2> Ping Server Status Report</h2>
<Br>
<p>Date: $($currentDateTime.ToString("yyyy-MM-dd HH:mm:ss"))</p>
<Br>
"@

    foreach ($site in $sites) {
        $pingMessages += "<h3>$site</h3>"

        foreach ($device in ($ipAddresses | Where-Object { $_.Site -eq $site })) {
            $pingResult = Test-Connection -ComputerName $device.Address -Count 1 -ErrorAction SilentlyContinue
            $status = if ($pingResult) { "Online" } else { "Offline" }
            $pingMessage = "Device: $($device.Name) | IP: $($device.Address) | Status: $status"

            if ($status -eq "Offline") {
                # Calculate offline duration
                if (-not $offlineStatus.ContainsKey($device.Name)) {
                    $offlineStatus[$device.Name] = Get-Date
                }
                $offlineDuration = (Get-Date) - $offlineStatus[$device.Name]
                $pingMessage += " | Offline Duration: $($offlineDuration.ToString())"
            } else {
                $offlineStatus.Remove($device.Name)
                $responseTime = if ($pingResult) { $pingResult.ResponseTime } else { "N/A" }
                $packetLoss = if ($pingResult -and $pingResult.PacketLoss) { $pingResult.PacketLoss } else { "0%" }
                $pingMessage += " | Response Time: $responseTime ms | Packet Loss: $packetLoss"
            }

            $pingMessages += "<p>$pingMessage</p>"

            # Save to the log file as a plain text line
            $logLine = "$site,$($device.Name),$($device.Address),$status,$($offlineDuration.TotalSeconds),$responseTime,$packetLoss"
            $logLine | Out-File -Append -FilePath $logFilePath
        }

        $pingMessages += "<br />"  # Add a <br> under each site instead of <hr>
    }

    $formattedMessage += "$($pingMessages -join '')</body></html>"

    Write-Host $formattedMessage

    $messageBody = @{
        "text" = $formattedMessage
        "contentType" = "html"
    }

    # Invoke the Teams webhook
    Invoke-RestMethod -Uri $pingWebhookUrl -Method Post -Headers @{
        "Content-Type" = "application/json"
    } -Body ($messageBody | ConvertTo-Json)

    $countdown = $pingIntervalSeconds
    while ($countdown -gt 0) {
        Write-Host "Next ping update in $countdown seconds..."
        Start-Sleep -Seconds 1
        $countdown--
    }
}
