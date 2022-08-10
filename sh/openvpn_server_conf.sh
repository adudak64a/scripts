#!/bin/bash
#встановлюємо openvpn i easy-rsa

apt-get update
apt-get install openvpn easy-rsa

mkdir ~/openvpn
mkdir ~/openvpn/orig_conf


make-cadir ~/openvpn/openvpn-ca
cd ~/openvpn/openvpn-ca/
cp vars ~/openvpn/orig_conf/vars
rm vars
exec 6>&1
exec > vars
echo "export EASY_RSA=\"\`pwd\`\""
echo "export OPENSSL=\"openssl\""
echo "export PKCS11TOOL=\"pkcs11-tool\""
echo "export GREP=\"grep\""
echo "export KEY_CONFIG=\`\$EASY_RSA/whichopensslcnf \$EASY_RSA\`"
echo "export KEY_DIR=\"\$EASY_RSA/keys\""
echo "echo NOTE: If you run ./clean-all, I will be doing a rm -rf on \$KEY_DIR"
echo "export PKCS11_MODULE_PATH=\"dummy\""
echo "export PKCS11_PIN=\"dummy\""
echo export KEY_SIZE=2048
echo export CA_EXPIRE=3650
echo export KEY_EXPIRE=3650
echo "export KEY_COUNTRY=\"UA\""
echo "export KEY_PROVINCE=\"CA\""
echo "export KEY_CITY=\"Chmelnitskyi\""
echo "export KEY_ORG=\"Zarichna\""
echo "export KEY_EMAIL=\"niko@example.com\""
echo "export KEY_OU=\"Eror505rorE\""
echo "export KEY_NAME=\"server\""

exec 1>&6- 6>&-

source vars

sed -i '12,15 s/openssl.cnf/openssl-1.0.0.cnf/g' ~/openvpn/openvpn-ca/whichopensslcnf 

./clean-all
./build-ca
./build-key-server server
./build-dh
openvpn --genkey --secret keys/ta.key

source vars
./build-key nite1

cd ~/openvpn/openvpn-ca/keys
cp ca.crt ca.key server.crt server.key ta.key dh2048.pem /etc/openvpn
gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz | sudo tee /etc/openvpn/server.conf

cp /etc/openvpn/server.conf ~/openvpn/orig_conf/server.conf
rm /etc/openvpn/server.conf

exec 6>&1
exec > /etc/openvpn/server.conf
echo port 1194
echo proto udp
echo dev tun
echo ca ca.crt
echo cert server.crt
echo key server.key  # This file should be kept secret
echo dh dh2048.pem
echo server 10.8.0.0 255.255.255.0
echo ifconfig-pool-persist ipp.txt
echo "push \"redirect-gateway def1 bypass-dhcp\""
echo "push \"dhcp-option DNS 208.67.222.222\""
echo "push \"dhcp-option DNS 208.67.220.220\""
echo keepalive 10 120
echo tls-auth ta.key 0 # This file is secret
echo key-direction 0
echo cipher AES-128-CBC   # AES
echo auth SHA256
echo comp-lzo
echo user nobody
echo group nogroup
echo persist-key
echo persist-tun
echo status openvpn-status.log
echo verb 3

exec 1>&6- 6>&-


sed -i s/\#net.ipv4.ip_forward/net.ipv4.ip_forward/ /etc/sysctl.conf

sysctl -p

echo "# START OPENVPN RULES" >> /etc/ufw/before.rules
echo "*nat" >> /etc/ufw/before.rules
echo ":POSTROUTING ACCEPT [0:0]" >> /etc/ufw/before.rules
echo "-A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE" >> /etc/ufw/before.rules
echo "COMMIT" >> /etc/ufw/before.rules

sed -i '10,30 s/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/g' /etc/default/ufw
ufw allow 1194/udp
ufw allow OpenSSH
ufw disable
ufw enable

systemctl restart openvpn@server
ip addr show tun0
systemctl enable openvpn@server

mkdir -p ~/openvpn/client-configs/files
chmod 700 ~/openvpn/client-configs/files
cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf ~/openvpn/client-configs/base.conf

cp ~/openvpn/client-configs/base.conf ~/openvpn/orig_conf/base.conf
rm ~/openvpn/client-configs/base.conf

exec 6>&1
exec >~/openvpn/client-configs/base.conf
echo client
echo dev tun
echo proto udp
echo remote 185.86.76.49 1194
echo resolv-retry infinite
echo nobind
echo user nobody
echo group nogroup
echo persist-key
echo persist-tun
echo remote-cert-tls server
echo cipher AES-128-CBC
echo auth SHA256
echo key-direction 1
echo comp-lzo
echo verb 3
exec 1>&6- 6>&-

exec 6>&1
exec >~/openvpn/client-configs/make_config.sh
echo "#!/bin/bash"
echo "# First argument: Client identifier"
echo "KEY_DIR=~/openvpn-ca/keys"
echo "OUTPUT_DIR=~/client-configs/files"
echo "BASE_CONFIG=~/client-configs/base.conf"
echo 
echo "cat \${BASE_CONFIG} \ "
echo  "   <(echo -e '<ca>') \ "
echo  "   \${KEY_DIR}/ca.crt \ "
echo  "  <(echo -e '</ca>\n<cert>') \ "
echo  "   \${KEY_DIR}/\${1}.crt \ "
echo  "  <(echo -e '</cert>\n<key>') \ "
echo  "   \${KEY_DIR}/\${1}.key \ "
echo  "   <(echo -e '</key>\n<tls-auth>') \ "
echo  "   \${KEY_DIR}/ta.key \ "
echo  "   <(echo -e '</tls-auth>') \ "
echo  "   > \${OUTPUT_DIR}/\${1}.ovpn"
exec 1>&6- 6>&-

chmod 700 ~/openvpn/client-configs/make_config.sh

cd ~/openvpn/client-configs
./make_config.sh nite1
