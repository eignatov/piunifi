![UNiFiPi Terminal Screenshot](/terminal.png)  

## unifipi-setup.sh
Bash shell script to automate the setup and configuration of a Raspberry Pi for use as a UniFi Controller for Ubiquiti network devices.

**Tested October 2020 Raspberry Pi 3 & 4 Raspberry Pi OS (previously called Raspbian)**
- Raspberry Pi OS (32-bit) Lite minimal image based on Debian Buster - August 2020 (Kernel 5.4)    

## Usage
**Method 1:** Clone and run locally. You can edit and modify script to suit using this method.

`git clone https://github.com/piscripts/unifipi.git`

`sudo bash unifipi/unifipi-setup.sh`

**Method 2:** Just use the curl or wget command lines shown below for a one-step install.

`sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/piscripts/unifipi/main/unifipi-setup.sh)"`

`sudo bash -c "$(wget -O- https://raw.githubusercontent.com/piscripts/unifipi/main/unifipi-setup.sh)"`

## Known issues

You will need to ignore the SSL certificate error when accessing UniFi controller web interface for the controller. The controller will function fine, however if you want to access securely from an external network you can install a valid SSL certificate there are a number of existing articles and Youtube videos on how to do this try google "unifi controller ssl certificate".
