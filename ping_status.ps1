$pingWebhookUrl = "YOUR TEAMS WEBHOOK"

$ipAddresses = @(
    @{ Name = "SERVER1"; Address = "192.168.1.1"; Site = "OFFICE1" },
    @{ Name = "SERVER1"; Address = "192.168.1.2"; Site = "OFFICE1" },
    @{ Name = "SERVER1"; Address = "192.168.1.3"; Site = "OFFICE2" },
    @{ Name = "SERVER1"; Address = "192.168.1.4"; Site = "OFFICE2" }
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
<h2>Ping Server Status Report</h2>
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
