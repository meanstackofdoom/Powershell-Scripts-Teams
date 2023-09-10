
#Script Name: Teams Weather Update Script
#Description: This PowerShell script fetches weather and astronomy data from weatherapi.com and posts updates to a Teams channel via a webhook. It runs in an infinite loop, #updating the weather every hour.
#Author: Matthew Wicks
#Date: 10/09/2023


# Weather API URL
$weatherApiUrl = "insert weatherapi.com api - no alerts yes"

# Astronomy API URL
$astronomyApiUrl = "insert weatherapi.com api - no alerts yes"

# Teams webhook URL
$teamsWebhookUrl = "insert teams webhook"

# Create an infinite loop to update weather every hour
while ($true) {
    # Fetch weather data
    $response = Invoke-RestMethod -Uri $weatherApiUrl -Method Get

    # Extract relevant weather information
    $location = $response.location
    $current = $response.current

    # Fetch astronomy data
    $astronomyResponse = Invoke-RestMethod -Uri $astronomyApiUrl -Method Get
    $astronomy = $astronomyResponse.astronomy.astro

    # Fetch weather data for the last hour
    $hourlyWeatherApiUrl = "http://api.weatherapi.com/restoftheapi09&q=Canberra Australia&dt=" + (Get-Date).AddHours(-1).ToString("yyyy-MM-dd HH:00")
    $hourlyWeatherResponse = Invoke-RestMethod -Uri $hourlyWeatherApiUrl -Method Get
    $hourlyWeather = $hourlyWeatherResponse.forecast.forecastday[0].hour[0]

    # Create a message to post in Teams
    $message = @{
        "@type" = "MessageCard"
        "@context" = "http://schema.org/extensions"
        "themeColor" = "0072C6"
        "summary" = "Weather Update for Canberra, Australia"
        "sections" = @(
            @{
                "activityTitle" = "Weather Update for Canberra, Australia"
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
                        "value" = "$($current.wind_dir) $($current.wind_kph) km/h at $($current.wind_degree)°"
                    },
                    @{
                        "name" = "Precipitation"
                        "value" = "$($current.precip_mm) mm"
                    },
                    @{
                        "name" = "UV Index"
                        "value" = "$($current.uv)"
                    },
                    @{
                        "name" = "Wind Gust"
                        "value" = "$($current.gust_kph) km/h "
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
                    },
                    @{
                        "name" = "Last Hour Weather Condition"
                        "value" = "$($hourlyWeather.condition.text)"
                    }
                )
            }
        )
    }

    # Get the 3-day forecast
    $forecastApiUrl = "http://api.weatherapi.com/restoftheapi09&q=Canberra Australia&days=3&aqi=no&alerts=yes"
    $forecastResponse = Invoke-RestMethod -Uri $forecastApiUrl -Method Get

    # Add the forecast information to the message
    $forecast = $forecastResponse.forecast.forecastday
    $forecastSection = @{
        "activityTitle" = "3-Day Forecast for Canberra, Australia"
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

    # Convert the message to JSON
    $jsonMessage = $message | ConvertTo-Json -Depth 5

    # Post the message to Teams
    Invoke-RestMethod -Uri $teamsWebhookUrl -Method Post -Body $jsonMessage -ContentType "application/json"

    # Display a countdown in the console for the next update (1 hour)
    Write-Host "Next update in 1 hour..."
    Start-Sleep -Seconds 3600  # Sleep for 1 hour
}
