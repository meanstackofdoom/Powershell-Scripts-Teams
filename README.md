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

<p>Check out the Teams enrolled intune script on GitHub:</p>

<a href="https://github.com/meanstackofdoom/Powershell-Scripts-Teams/blob/main/intune_check_enrolled.ps1">Device Enrollment</a>

This script is designed to monitor Intune-managed devices and send notifications to a Microsoft Teams channel when new devices are enrolled within the last 6 hours. It continues to run indefinitely<br><br>

The script performs the following tasks:<br>
1. Checks for the presence of the "Microsoft.Graph.Intune" PowerShell module and installs it if missing.<br>
2. Establishes a connection to Microsoft Graph.<br>
3. Updates the Microsoft Graph environment schema to the beta version.<br>
4. Calculates a time threshold to determine if any devices were enrolled within a specified time frame (default is 6 hours).<br>
5. Queries Intune-managed devices that meet the enrollment criteria.<br>
6. Sends a message to a Microsoft Teams channel with details of the enrolled devices, if any.<br>
7. Repeats the monitoring process at regular intervals.<br>


.NOTES<br>
- You should replace the webhook URLs with your actual Microsoft Teams webhook URLs.<br>
- Customize the script as needed for your environment.<br>
- Ensure that the "Run-IntuneCheck" function, which is referenced but not defined in this script, is defined elsewhere in your environment.<br>

---

## check_sync.ps1

<p>Check out the Teams enrolled intune script on GitHub:</p>

<a href="https://github.com/meanstackofdoom/Powershell-Scripts-Teams/blob/main/intune_check_sync.ps1">Device Sync</a>

This PowerShell script periodically checks the status of Microsoft Intune-managed devices to identify those that haven't synced in a specified timeframe. It then sends a detailed report to a Microsoft Teams channel using a webhook, allowing for proactive device management and monitoring

---

