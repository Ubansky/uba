
#!/bin/bash

# Update package lists
sudo apt update

# Install dependencies
sudo apt install -y build-essential curl libpam0g-dev

# Download Dante source code
curl -O https://www.inet.no/dante/files/dante-1.4.2.tar.gz

# Extract the downloaded archive
tar xzf dante-*.tar.gz

# Navigate into the extracted directory
cd dante-*

# Configure the build process with UDP support and username/password authentication
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-client --enable-socks5 --enable-socksify --enable-udpserver --enable-socks-passwd

# Build the software
make

# Install Dante
sudo make install

# Install udprelay from the dante-server package
sudo apt install -y dante-server

# Configure Dante
cat << EOF | sudo tee /etc/sockd.conf
internal: eth0 port = 1080
external: eth0

clientmethod: none
socksmethod: username

user.privileged: root
user.notprivileged: nobody

logoutput: stderr

# Define the username and password
socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    command: bind connect udpassociate
    log: error # connect disconnect iooperation
    username: "popo"
    password: "popo"
}

EOF

# Start Dante service
sudo systemctl start sockd

# Enable Dante to start automatically on system boot
sudo systemctl enable sockd

echo "Dante SOCKS5 proxy server with UDP support and username/password authentication has been installed and configured."
echo "Please update your client applications to use the Dante SOCKS5 server at <server_ip>:1080 with the configured username and password."
