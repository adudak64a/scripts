    #/bin/bash
    # настройка vpn-сервера для ubuntu 18.04 strongswan IKEv2
    # всі налаштування робити з під root і на чисту систему. Можуть виникнути проблеми із файлом /etc/ufw/before.rules
    #Встановлюємо пакети необхідня для роботи
    apt update
    apt install strongswan strongswan-pki -y
    #Свторюємо тимчасово потрібні каталоги
    mkdir -p ~/ikev2/pki/{cacerts,certs,private}
    chmod 700 ~/ikev2/pki
    #Вводимо параметри необхідні для скрипта
    ifconfig
    echo "Обережно з пробілами і регістром"
    echo  -n "Введіть IP-адресу: "
    read Zip
    echo -n "Введіть інтерфейс: "
    read Zin
    echo  -n "Введіть логін: "
    read Zus
    echo -n "Введіть пароль: "
    read Zpa
    # генерація сертифікатиційної частини
    #
    ipsec pki --gen --type rsa --size 4096 --outform pem > ~/ikev2/pki/private/ca-key.pem
    #
    ipsec pki --self --ca --lifetime 3650 --in ~/ikev2/pki/private/ca-key.pem \
    --type rsa --dn "CN=VPN root CA" --outform pem > ~/ikev2/pki/cacerts/ca-cert.pem
    #
    ipsec pki --gen --type rsa --size 4096 --outform pem > ~/ikev2/pki/private/server-key.pem
    #
    ipsec pki --pub --in ~/ikev2/pki/private/server-key.pem --type rsa \
    | ipsec pki --issue --lifetime 1825 \
    --cacert ~/ikev2/pki/cacerts/ca-cert.pem \
    --cakey ~/ikev2/pki/private/ca-key.pem \
    --dn "CN=$Zip" --san "$Zip" \
    --flag serverAuth --flag ikeIntermediate --outform pem \
    >  ~/ikev2/pki/certs/server-cert.pem
    #Переносимо згенеровані ключі у потрібні директорії
    cp -r ~/ikev2/pki/* /etc/ipsec.d/
    mv /etc/ipsec.conf{,.original}
    rm -R  ~/ikev2/pki/
    # Конфігуруємо основний файл IPsec
    exec 6>&1
    exec > /etc/ipsec.conf
    echo config setup
    echo "   charondebug=\"ike 1, knl 1, cfg 0\""
    # Підключення кількох клієнтів по одному сертифікату
    echo "   uniqueids=no"
    echo conn ikev2-vpn
    echo "   auto=add"
    echo "   compress=no"
    echo "   type=tunnel"
    echo "   keyexchange=ikev2"
    echo "   fragmentation=yes"
    echo "   forceencaps=yes"
    # Виключаєм клієнта якщо він довго не відкликався
    echo "   dpdaction=clear"
    # Затримка пере спрацюванням
    # dpddelay=35s
    # Таймаут перед виключенням
    echo "   dpddelay=300s"
     # виключення ініціації зміни ключів зі сторони сервера. Windows це не любить.
    echo "   rekey=no"
    # left i right сторони підключення. Лівий - сервер, правий - клієнт
    echo "   left=%any"
    echo "   leftid=$Zip"
    echo "   leftcert=server-cert.pem"
    echo "   leftsendcert=always"
    echo "   leftsubnet=0.0.0.0/0"
    echo "   right=%any"
    echo "   rightid=%any"
    echo "   rightauth=eap-mschapv2"
    echo "   rightsourceip=10.10.10.0/24"
    echo "   rightdns=8.8.8.8,8.8.4.4"
    echo "   rightsendcert=never"
    echo "   eap_identity=%identity"
    exec 1>&6- 6>&-
    # Конфігуруємо файл авторизації IPsec
    exec 6>&1
    exec > /etc/ipsec.secrets
    echo ": RSA \"server-key.pem\""
    echo "$Zus : EAP \"$Zpa\""
    exec 1>&6- 6>&-

    service restart strongswan
    # Налаштовуємо всі необхідні права в фаєрволі сервера iptables - ufw
    ufw allow OpenSSH
    ufw enable
    ufw allow 500,4500/udp
    #
    exec 6>&1
    exec > /etc/ufw/before.rules1
    echo *nat
    echo "-A POSTROUTING -s 10.10.10.0/24 -o eth0 -m policy --pol ipsec --dir out -j ACCEPT"
    echo "-A POSTROUTING -s 10.10.10.0/24 -o eth0 -j MASQUERADE"
    echo "COMMIT"
    echo "*mangle"
    echo "-A FORWARD --match policy --pol ipsec --dir in -s 10.10.10.0/24 -o eth0 -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1536 -j TCPMSS --set-mss 1360"
    echo "COMMIT"
    exec 1>&6- 6>&-

    # В файлі /etc/ufw/before.rules.origin оригінальні налаштування ufw
    cat /etc/ufw/before.rules >> /etc/ufw/before.rules1
    mv /etc/ufw/before.rules /etc/ufw/before.rules.origin
    mv /etc/ufw/before.rules1 /etc/ufw/before.rules
    sed -i '/# End required lines/ a\-A ufw-before-forward --match policy --pol ipsec --dir out --proto esp -s 10.10.10.0/24 -j ACCEPT' /etc/ufw/before.rules
    sed -i '/# End required lines/ a\-A ufw-before-forward --match policy --pol ipsec --dir in --proto esp -s 10.10.10.0/24 -j ACCEPT' /etc/ufw/before.rules
   
    # Правим /etc/ufw/sysctl.conf
    echo "net/ipv4/ip_forward=1" >> /etc/ufw/sysctl.conf
    echo "net/ipv4/conf/all/accept_redirects=0" >> /etc/ufw/sysctl.conf
    echo "net/ipv4/conf/all/send_redirects=0" >> /etc/ufw/sysctl.conf
    echo "net/ipv4/ip_no_pmtu_disc=1" >> /etc/ufw/sysctl.conf

    ufw disable
    ufw enable 

# nano /etc/ipsec.d/cacerts/ca-cert.pem - Ключ який треба помістити в віндовс через Win+R -> mmc.exe -> Import -> <ключ має містити розширення .pem>
# В разі складностей можна видалити з адапретів IKEv2 i IP а потім відновити, це інколи рішає
#або через реєстр, додавши ключ DWORD HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Rasman\Parameters\NegotiateDH2048_AES256. Встановіть його так, щоб 1   