sudo apt-get update 
sudo apt-get install laptop-mode-tools -y # Select all on the config 
sudo lmt-config-gui 
echo 'install Aura core'
sudo apt-get install git -y 
git clone https://github.com/wroberts/rogauracore.git
cd rogauracore
sudo apt install libusb-1.0-0 libusb-1.0-0-dev -y 
sudo apt install autoconf -y 
autoreconf -i
./configure
make
sudo make install 
# Shutdown and restart the system
# Rainbow
sudo rogauracore rainbow
