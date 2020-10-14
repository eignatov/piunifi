![UNiFiPi Terminal Screenshot](/terminal.png)  

## unifipi-setup.sh
Bash shell script to automate the setup and configuration of a Raspberry Pi for use as a UniFi Controller for Ubiquiti network devices.

**Tested October 2020 Raspberry Pi 3 & 4 Raspberry Pi OS (previously called Raspbian)**
- Raspberry Pi OS (32-bit) Lite minimal image based on Debian Buster - August 2020 (Kernel 5.4)    

## Usage
**Method 1:** Clone and run locally. You can edit and modify script to suit using this method.

`git clone https://github.com/piscripts/unifipi.git`

`sudo bash unifipi/unifipi-setup.sh`

**Method 2: (Quick easy setup)** Just use the curl or wget command lines shown below for a one-step install.

`sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/piscripts/unifipi/main/unifipi-setup.sh)"`

`sudo bash -c "$(wget -O- https://raw.githubusercontent.com/piscripts/unifipi/main/unifipi-setup.sh)"`

## Known issues

You will need to ignore the browser SSL certificate error when accessing UniFi controller web interface. On a private/internal network this should not be a significant issue and will function fine (some browsers will allow you to add the address as an exception). If you want to access the controller securely from an external/public network, you should install a valid SSL certificate. There are a number of existing articles and Youtube videos on how to do this try searching "unifi controller ssl certificate".

## Troubleshooting

Give the unifi service a few minutes to start upon reboot. 

If you still cannot access the web interface try checking the status of the service with the following command:  
`sudo systemctl status unifi`

Check for errors in the status output.  
If should read `Starting unifi...`  
and eventually `Started unifi.`  
