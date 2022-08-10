#/bin/bash

apt update
apt install strongswan xl2tpd iptables-persistent -y
# iptables-persistent - пакет який дозволяє зберігати правила і використовувати їх в майбутньому

echo "%any %any : PSK \"S+nct+m\"" >> /etc/ipsec.secrets

exec 6>&1
exec > /etc/ipsec.conf
echo config setup
echo "   virtual_private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12"
echo "   nat_traversal=yes"
echo "    protostack=netkey"
echo conn l2tpvpn
echo "   type=transport"
echo "   authby=secret"
echo "   pfs=no"
   # виключення ініціації зміни ключів зі сторони сервера. Windows це не любить.
echo "   rekey=no"
echo "   keyingtries=1"
echo "   forceencaps=yes"
   # Виключаєм клієнта якщо він довго не відкликався
echo "   dpdaction=clear"
   # Затримка пере спрацюванням
# dpddelay=35s
   # Таймаут перед виключенням
echo "   dpddelay=300s"
   # left i right сторони підключення. Лівий - сервер, правий - клієнт
echo "   left=%any"
echo "   leftprotoport=udp/l2tp"
echo "   leftid=@l2tpvpnserver"
echo "   right=%anys"
echo "   rightprotoport=udp/%any"
echo "   auto=add"
echo "   rightid=%any"
exec 1>&6- 6>&-

service strongswan restart

exec 6>&1
exec > /etc/xl2tpd/xl2tpd.conf
echo [global]
echo port = 1701
echo access control = no
echo ipsec saref = yes
echo force userspace = yes
echo "; Файл с логінами і паролями"
echo auth file = /etc/ppp/chap-secrets
echo [lns default]
echo "; Діапазон адрес динамічно виданих клієнту"
echo "; Ми обмежуємося підмережею  172.28.253.64/26"
echo "; Першу її частину лишимо під статичну привязку адрес"
echo "; А друга - динамічний пул"
echo ip range = 172.28.253.96-172.28.253.126
echo "; IP-адрес на стороні сервера"
echo local ip = 172.28.253.65
echo "; Це імя застосовується в ipparam для пошукі логінів і паролів в auth file"
echo name = l2tpserver
echo "; Файл с додатковими опціями для ppp"
echo pppoptfile = /etc/ppp/options
echo flow bit = yes
echo exclusive = no
echo hidden bit = no
echo length bit = yes
echo require authentication = yes
echo require chap = yes
echo refuse pap = yes
exec 1>&6- 6>&-

exec 6>&1
exec >/etc/ppp/options
echo noccp
echo auth
echo crtscts
echo mtu 1410
echo mru 1410
echo nodefaultroute
echo lock
echo noproxyarp
echo silent
echo modem
echo asyncmap 0
echo hide-password
echo require-mschap-v2
echo ms-dns 8.8.8.8
echo ms-dns 8.8.4.4
exec 1>&6- 6>&-

service xl2tpd restart

#Вводимо параметри необхідні для скрипта
ifconfig
echo "Обережно з пробілами і регістром"
echo -n "Введіть інтерфейс: "
read Zin


exec 6>&1
exec >/firewall.sh
echo "#!/bin/bash"
echo "# Внутрішній інтерфейс сервера"
echo "IF_EXT=\"$Zin\""
echo "# Внутріні інтерфейси (обслуговуючі ВПН-клієнтів)"
echo "IF_INT=\"ppp+\""
echo "# Мережа, з якої клієнти ВПН будуть отримувати адреси"
echo "NET_INT=\"172.28.253.64/26\""
echo "# Скидаєм всі правила"
echo "iptables -F"
echo "iptables -F -t nat"
echo "# Встановлюємо політики за замовчуванням"
echo "iptables -P INPUT DROP"
echo "iptables -P OUTPUT ACCEPT"
echo "iptables -P FORWARD DROP"
echo "# Дозволяєм весь трафік на вузловому(петлевому) інтерфейсі"
echo "iptables -A INPUT -i lo -j ACCEPT"
echo "# Дозволяєм все для ВПН-клієнтів"
echo "iptables -A INPUT -i \${IF_INT} -s \${NET_INT} -j ACCEPT"
echo "# Дозволаєм вхідне зєднання до L2TP"
echo "# Не тільки із шифруванням!"
echo "iptables -A INPUT -p udp -m policy --dir in --pol ipsec -m udp --dport 1701 -j ACCEPT"
echo "# Дозволяєм IPSec"
echo "iptables -A INPUT -p esp -j ACCEPT"
echo "iptables -A INPUT -p ah -j ACCEPT"
echo "iptables -A INPUT -p udp --dport 500 -j ACCEPT"
echo "iptables -A INPUT -p udp --dport 4500 -j ACCEPT"
echo "# Дозволяєм доступ до сервера по SSH"
echo "iptables -A INPUT -m tcp -p tcp --dport 22 -j ACCEPT"
echo "# Дозволяєм вхідні відповіді на вихідні запити"
echo "iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT"
echo "# NAT для локальної мережі (ВПН-клієнтів)"
echo "iptables -t nat -A POSTROUTING -s \${NET_INT} -j MASQUERADE -o \${IF_EXT}"
echo "iptables -A FORWARD -i \${IF_INT} -o \${IF_EXT} -s \${NET_INT} -j ACCEPT"
echo "iptables -A FORWARD -i \${IF_EXT} -o \${IF_INT} -d \${NET_INT} -m state --state RELATED,ESTABLISHED -j ACCEPT"
exec 1>&6- 6>&-

bash  /firewall.sh
netfilter-persistent save

sed -i s/\#net.ipv4.ip_forward/net.ipv4.ip_forward/ /etc/sysctl.conf
sysctl -p

echo "# Користувач з постійною адресою" >> /etc/ppp/chap-secrets
echo "\"kaduda\"    l2tpserver    \"assura13\"    \"172.28.253.67\"" >> /etc/ppp/chap-secrets
echo "# Користувач з постійною адресою" >> /etc/ppp/chap-secrets
echo "\"user1\"    l2tpserver    \"QwerNotS\"   *" >> /etc/ppp/chap-secrets
