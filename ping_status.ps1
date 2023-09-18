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

# Weather API URL for 3-day forecast and alerts
$forecastAndAlertsApiUrl = ""

# Astronomy API URL
$astronomyApiUrl = ""

# Teams webhook URL
$teamsWebhookUrl = ""

# Initialize variables to store max and min temperatures and precipitation
$dayMaxTemp = $null
$dayMinTemp = $null

# Function to fetch and report the highest and lowest temperatures between 5 PM and 5 PM next day
function GetHighestAndLowestTemperaturesBetween5PM {
    $currentHour = Get-Date -Format "HH"

    # Check if the current hour is 17 (5 PM)
    if ($currentHour -eq "17") {
        # Calculate the date for 5 PM today
        $currentDate = Get-Date
        $today5PM = Get-Date -Year $currentDate.Year -Month $currentDate.Month -Day $currentDate.Day -Hour 17 -Minute 0 -Second 0

        # Calculate the date for 5 PM next day
        $nextDay5PM = $today5PM.AddDays(1)

        # Fetch weather data for the specified time frame
        $response = Invoke-RestMethod -Uri $forecastAndAlertsApiUrl -Method Get

        # Check for errors in the API response
        if ($response.error) {
            Write-Host "Error fetching weather data: $($response.error.message)"
            return
        }

        # Extract relevant weather information for the specified time frame
        $forecast = $response.forecast.forecastday[0].hour

        # Initialize variables for the highest and lowest temperatures
        $highestTemp = $null
        $lowestTemp = $null

        # Find the highest and lowest temperatures between 5 PM and 5 PM next day
        foreach ($hourData in $forecast) {
            $hour = [datetime]::ParseExact($hourData.time, "yyyy-MM-dd HH:mm", $null)

            if ($hour -ge $today5PM -and $hour -lt $nextDay5PM) {
                $tempCelsius = $hourData.temp_c

                # Check for the highest temperature
                if ($highestTemp -eq $null -or $tempCelsius -gt $highestTemp) {
                    $highestTemp = $tempCelsius
                }

                # Check for the lowest temperature
                if ($lowestTemp -eq $null -or $tempCelsius -lt $lowestTemp) {
                    $lowestTemp = $tempCelsius
                }
            }
        }

        # Create a message for the highest and lowest temperatures
        $tempReportMessage = @{
            "@type" = "MessageCard"
            "@context" = "http://schema.org/extensions"
            "themeColor" = "0072C6"
            "summary" = "Highest and Lowest Temperature Report (5pm-to-5pm)"
            "sections" = @(
                @{
                    "activityTitle" = "Temperature Report (5pm-to-5pm)"
                    "facts" = @(
                        @{
                            "name" = "Date Range"
                            "value" = "$($today5PM.ToString('yyyy-MM-dd HH:mm')) to $($nextDay5PM.ToString('yyyy-MM-dd HH:mm'))"
                        },
                        @{
                            "name" = "Highest Temperature"
                            "value" = "$highestTemp°C"
                        },
                        @{
                            "name" = "Lowest Temperature"
                            "value" = "$lowestTemp°C"
                        }
                    )
                }
            )
        }

        # Post the highest and lowest temperature report to Teams
        $jsonTempReport = $tempReportMessage | ConvertTo-Json -Depth 5
        Invoke-RestMethod -Uri $teamsWebhookUrl -Method Post -Body $jsonTempReport -ContentType "application/json"
    }
}






# Create an infinite loop to update weather every hour
while ($true) {
    # Fetch weather data for the hourly report (with 3-day forecast and alerts)
    $response = Invoke-RestMethod -Uri $forecastAndAlertsApiUrl -Method Get

    # Check for errors in the API response
    if ($response.error) {
        Write-Host "Error fetching weather data: $($response.error.message)"
        Start-Sleep -Seconds 3600  # Retry after 1 hour
        continue
    }

    # Extract relevant weather information
    $location = $response.location
    $current = $response.current

    # Fetch astronomy data
    $astronomyResponse = Invoke-RestMethod -Uri $astronomyApiUrl -Method Get
    $astronomy = $astronomyResponse.astronomy.astro

    # Create a message to post in Teams for the hourly report
    $message = @{
        "@type" = "MessageCard"
        "@context" = "http://schema.org/extensions"
        "themeColor" = "0072C6"
        "summary" = "  Weather Update"
        "sections" = @(
            @{
                "activityTitle" = "40min  Weather Updates"
                "facts" = @(
                    @{
                        "name" = "Location"
                        "value" = "$($location.name), $($location.region), $($location.country)"
                    },
                    @{
                        "name" = "Weather Condition"
                        "value" = "$($current.condition.text)"
                    },
                    @{
                        "name" = "Local Time"
                        "value" = (Get-Date -Date ([System.DateTimeOffset]::FromUnixTimeMilliseconds($location.localtime_epoch * 1000)).LocalDateTime).ToString('yyyy-MM-dd HH:mm')
                    },
                    @{
                        "name" = "Temperature (Feels Like)"
                        "value" = "$($current.feelslike_c)°C"
                    },
                    @{
                        "name" = "Wind"
                        "value" = "$($current.wind_kph) km/h at $($current.wind_degree)°"
                    },
                    @{
                        "name" = "Precipitation"
                        "value" = "$($current.precip_mm) mm"
                    },
                    @{
                        "name" = "UV Index"
                        "value" = "$($current.uv) $($current.uv_description)"
                    },
                    @{
                        "name" = "Wind Gust"
                        "value" = "$($current.gust_kph) km/h"
                    },
                    @{
                        "name" = "Air Quality (CarbonMonoxide)"
                        "value" = "$($current.air_quality.co) μg/m³"
                    },
                    @{
                        "name" = "Air Quality (Ozone)"
                        "value" = "$($current.air_quality.o3) μg/m³"
                    },
                    @{
                        "name" = "Air Quality (NitrogenDioxide)"
                        "value" = "$($current.air_quality.no2) μg/m³"
                    },
                    @{
                        "name" = "Air Quality (SulphurD)"
                        "value" = "$($current.air_quality.so2) μg/m³"
                    },
                    @{
                        "name" = "Air Quality (ParticulateM2.5)"
                        "value" = "$($current.air_quality.pm2_5) μg/m³"
                    },
                    @{
                        "name" = "Air Quality (ParticulateM10)"
                        "value" = "$($current.air_quality.pm10) μg/m³"
                    },
                    @{
                        "name" = "Visibility"
                        "value" = "$($current.vis_km) km"
                    },
                    @{
                        "name" = "Sunrise"
                        "value" = $astronomy.sunrise
                    },
                    @{
                        "name" = "Sunset"
                        "value" = $astronomy.sunset
                    },
                    @{
                        "name" = "Moonrise"
                        "value" = $astronomy.moonrise
                    },
                    @{
                        "name" = "Moonset"
                        "value" = $astronomy.moonset
                    },
                    @{
                        "name" = "Moon Phase"
                        "value" = $astronomy.moon_phase
                    },
                    @{
                        "name" = "Moon Illumination"
                        "value" = $astronomy.moon_illumination
                    }
                )
            }
        )
    }

    # Check if "will_it_rain" and "chance_of_rain" are available in the API response
    if ($current.PSObject.Properties['will_it_rain'] -ne $null -and $current.PSObject.Properties['chance_of_rain'] -ne $null) {
        $message["sections"] += @{
            "activityTitle" = "Hourly Weather Update"
            "facts" = @(
                @{
                    "name" = "Chance of Rain"
                    "value" = "$($current.chance_of_rain)%"
                },
                @{
                    "name" = "Will it Rain?"
                    "value" = "$($current.will_it_rain)"
                }
            )
        }
    }

    $alertDetails = @{
    "name" = "Alert"
    "value" = "Headline: $($alert.headline)`r`nSeverity: $($alert.severity)`r`nUrgency: $($alert.urgency)`r`nCategory: $($alert.category)`r`nCertainty: $($alert.certainty)`r`nEvent: $($alert.event)`r`nNote: $($alert.note)`r`nEffective: $($alert.effective)`r`nExpires: $($alert.expires)`r`nDescription: $($alert.desc)`r`nInstruction: $($alert.instruction)"
}

if ($alerts) {
    $alertsSection = @{
        "activityTitle" = "Weather Alerts"
        "facts" = @($alertDetails)
    }

    $message["sections"] += $alertsSection
} else {
    # If no alerts are available, add a "No Alerts" section
    $message["sections"] += @{
        "activityTitle" = "Weather Alerts"
        "facts" = @(
            @{
                "name" = "Alert"
                "value" = "No Severe Weather alerts for "
            }
        )
    }
}

    # Get the 3-day forecast
    $forecast = $response.forecast.forecastday
    $forecastSection = @{
        "activityTitle" = "3-Day Forecast for"
        "facts" = @()
    }

    foreach ($day in $forecast) {
        $forecastDetails = @{
            "name" = $day.date
            "value" = "Max Temp: $($day.day.maxtemp_c)°C ($($day.day.maxtemp_f)°F)`r`nMin Temp: $($day.day.mintemp_c)°C ($($day.day.mintemp_f)°F)`r`nCondition: $($day.day.condition.text)"
        }
        $forecastSection["facts"] += $forecastDetails
    }

    $message["sections"] += $forecastSection

  



    # Post the message to Teams
    $jsonMessage = $message | ConvertTo-Json -Depth 5
    Invoke-RestMethod -Uri $teamsWebhookUrl -Method Post -Body $jsonMessage -ContentType "application/json"

    # Calculate the time until the next update (41 minutes and 39 seconds)
$secondsUntilNextUpdate = 41 * 60 + 39  # 41 minutes and 39 seconds

# Loop to continuously update the countdown
while ($secondsUntilNextUpdate -gt 0) {
    $minutes = [math]::floor($secondsUntilNextUpdate / 60)
    $seconds = $secondsUntilNextUpdate % 60

    # Display the countdown in the console, overwriting the previous line
    Write-Host -NoNewline -ForegroundColor Yellow " Weather Script : Next update in $minutes minutes and $seconds seconds..."

    # Sleep for 1 second
    Start-Sleep -Seconds 1

    # Decrement the remaining time
    $secondsUntilNextUpdate--

    # Move to a new line
    Write-Host ""
}

# Print a message on a new line when the countdown reaches 0
Write-Host ""  # Blank line
Write-Host -ForegroundColor Green " Update in progress..."
}
