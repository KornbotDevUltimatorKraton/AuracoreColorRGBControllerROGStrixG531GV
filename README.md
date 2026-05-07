# AuracoreColorRGBControllerROGStrixG531GV
This is the GUI software wrote in Python code to control the RGB like on the ROG RGB LED control Keyboard to support on ubuntu linux 
Installation
1.) First installation chmod +x ROGStrixG531GV.sh 
2.) Run installer with your preferred default mode:

./ROGStrixG531GV.sh install rainbow

3.) The installer now does all of this:
- installs rogauracore dependencies
- builds and installs rogauracore
- creates /etc/rogauracore-mode
- installs and enables rogauracore-persist.service (applies RGB after graphical desktop login)
- restores asus keyboard backlight brightness before applying color

4.) After finish installation bash script you can run:

python3 Auracorecontroller.py

5.) Change persistent color at any time:

./ROGStrixG531GV.sh set-mode blue

6.) Check service status:

./ROGStrixG531GV.sh status

7.) Apply current mode immediately:

./ROGStrixG531GV.sh apply-now

8.) Uninstall persistence service/helper files:

./ROGStrixG531GV.sh uninstall

This script is reusable on other Ubuntu-based ROG Strix laptops with similar Aura keyboard support.

This fixes the issue where RGB is visible during boot, then disappears after desktop opens.
