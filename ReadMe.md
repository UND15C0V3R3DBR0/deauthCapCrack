This repo is to deauthenticate clients from WiFi networks and capture the wpa2 handshake and will then use John-the-ripper and Hashcat to crack the wpa2.cap file, you may also want to download Wireshark.

mkdir deauthNcap
cd deauthNcap

nano capture.sh
nano autorun.sh
nano requirements.txt

chmod +x wifi_monitor.sh auto_run.sh //Makes script executable

# //Initialize a Git Repository and Push to GitHub
git init
git add .
git commit -m "Initial commit"
git remote add origin <your-github-repo-url>
git push -u origin main

# //Running the script
sudo ./auto_run.sh
