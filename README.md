# PowerShell Scripts

A collection of scripts which are currently active and working that I have designed over the years,  currently uploading, feel free to use.


<a href="https://github.com/meanstackofdoom/Powershell-Scripts/blob/main/README.md" target="_blank">Powershell Read me</a><br>
<a href="https://github.com/meanstackofdoom/Powershell-Scripts/blob/main/SECURITY.md" target="_blank">Powershell Security</a><Br>
<a href="https://github.com/meanstackofdoom/Powershell-Scripts/blob/main/CODE_OF_CONDUCT.md" target="_blank">Powershell Scripts Code Of Conduct</a><br>
<a href="https://github.com/meanstackofdoom/Powershell-Scripts/blob/main/CONTRIBUTING_TO_Powershell-Scripts.md" target="_blank">Contribution to Powershell Scripts Repository</a><Br>


---

## Ping_status.ps1

<p>Check out the Device Teams Ping script on GitHub:</p>

<a href="https://github.com/meanstackofdoom/Powershell-Scripts-Teams/blob/main/ping_status.ps1">Ping Status Script</a>

Script written in PowerShell to post to Teams using the Teams webhook.

### Ping Server Status Report

Date: 2023-09-10 15:36:55

**Office1**
- Device: SERVER1 | IP: 192.168.1.1 | Status: Online | Response Time: 21 ms | Packet Loss: 0%
- Device: SERVER2 | IP: 192.168.1.2 | Status: Online | Response Time: 23 ms | Packet Loss: 0%

**Office2**
- Device: SERVER3 | IP: 192.168.1.3 | Status: Online | Response Time: 1 ms | Packet Loss: 0%
- Device: SERVER4 | IP: 192.168.1.4 | Status: Online | Response Time: 1 ms | Packet Loss: 0%

---

## weather_status.ps1

<p>Check out the Teams Weather script on GitHub:</p>

<a href="https://github.com/meanstackofdoom/Powershell-Scripts/blob/main/weather_status.ps1">Teams Weather Status</a>

Script written to update the weather from weatherapi.com to a dedicated Teams channel.

### Weather Update for Canberra, Australia

- Location : Canberra, ACT, Australia<br>
- Weather Condition<br>
- Local Time: 2023-09-10 16:09<br>
- Temperature (Feels Like): 17.0°C<br>
- Wind: ESE 19.1 km/h at 120°<br>
- Precipitation: 4.0 mm<br>
- UV Index: 5.0<br>
- Wind Gust: 16.6 km/h<br>
- Sunrise: 06:04 AM<br>
- Sunset: 05:40 PM<br>
- Moonrise: 12:35 AM<br>
- Moonset: 10:27 AM<br>
- Moon Phase: Waning Crescent<br>
- Moon Illumination: 49<br>
- Last Hour Weather Condition: Partly cloudy

#### 3-Day Forecast for Canberra, Australia
- 2023-09-10 Max Temp: 16.0°C (60.8°F) Min Temp: 8.1°C (46.6°F)  Condition: Sunny<br>
- 2023-09-11 Max Temp: 16.9°C (62.4°F) Min Temp: 9.1°C (48.4°F)  Condition: Sunny<br>
- 2023-09-12 Max Temp: 18.7°C (65.7°F) Min Temp: 12.4°C (54.3°F) Condition: Patchy rain possible

---

## check_enrolment.ps1

<p>Check out the Teams Weather script on GitHub:</p>

<a href="https://github.com/meanstackofdoom/Powershell-Scripts-Teams/blob/main/intune_check_enrolled.ps1">Device Enrollment</a>

Script written to update the devices within intune to teams to monitor newly attached devices to tenant.

This script is designed to monitor Intune-managed devices and send notifications to a Microsoft Teams channel when new devices are enrolled within the last 6 hours. It continues to run indefinitely

Module Check:<Br>
It first checks if the "Microsoft.Graph.Intune" PowerShell module is installed. If not, it displays a message and exits.
<Br><Br>
Microsoft Graph Connection:<Br>
It checks if a connection to Microsoft Graph has been established. If not, it attempts to establish a connection.
<Br><Br>
Update Microsoft Graph Environment:<Br>
It updates the Microsoft Graph environment schema to the beta version.
<Br><Br>
Time Calculation:<Br>
It calculates the current time and time X minutes ago (where X is set to 360 minutes or 6 hours) in a specific format.
<Br><Br>
Device Query:<Br>
It queries Intune managed devices where the "enrolledDateTime" (the date and time the device was enrolled) is greater than or equal to the calculated time X minutes ago. It then filters out devices with the "managementAgent" value equal to "eas."
<Br><Br>
Device Count Check:<Br>
It checks if there are any devices that meet the criteria from the previous step. If there are such devices, it creates a message containing details of these devices.
<Br><Br>
Teams Webhook Integration:<Br>
It sends this message to a Microsoft Teams channel using a webhook URL. The URL is provided in the script.
<Br><Br>
No Devices Found:<Br>
If no devices meet the criteria, it sends a message indicating that no devices have been found.
<Br><Br>
Continuous Loop:<Br>
It then enters a continuous loop with a specified interval (6 hours). In this loop, it repeatedly prints messages about when the next update check will occur, waits for the specified interval, and then runs an "Intune check" function (which is not defined in the provided script).

---
