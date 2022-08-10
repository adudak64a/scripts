#!/bin/bash
#встановлюємо ftp-сервіс
apt-get install vsftpd -y

#копіюємо оригіальний файл конфігурації
#створюємо користувача і папки
cp /etc/vsftpd.conf /etc/vsftpd.conf.orig
rm /etc/vsftpd.conf
mkdir /etc/vsftpd_users
mkdir /home/ftpconnection
mkdir /home/ftpconnection/ftpuser
mkdir /home/ftpconnection/anon
useradd ftpuser -d /home/ftpconnection/ftpuser -s /usr/bin/false

#задаємо пароль користувачу і права на папку
passwd ftpuser << EOF
Au32Ldt
Au32Ldt
EOF
chown -R ftpuser:ftp /home/ftpconnection/ftpuser
chmod -R 755 /home/ftpconnection/ftpuser

#конфіжим основний файл конфігурації
exec 1>/etc/vsftpd.conf
echo listen=NO 
echo listen_ipv6=YES
echo anonymous_enable=YES	# анонімне підключення - так
echo no_anon_password=YES
echo anon_root=/home/ftpconnection/anon/
echo max_per_ip=6	# число максимальних підключень
echo local_enable=YES 	# підключення локальних користувачів
echo user_config_dir=/etc/vsftpd_users	# папка з налаштуваннями користувач
echo write_enable=YES 	# запис - так
echo chroot_local_user=YES	  #для локальних користувачів буде виконано chroot в їх домашніх дерикторіях
echo chroot_list_enable=YES 	#список для лок.користувачів де буде виконуватися chroot
echo chroot_list_file=/etc/vsftpd.listic 	#назва файла користувачів для списка лок.корисувачів
echo dirmessage_enable=YES
echo use_localtime=YES 		#час в локальній часовій зоні
echo xferlog_enable=YES 	#логування
echo xferlog_std_format=YES  	#логування в стилі wu-ftpd
echo secure_chroot_dir=/var/run/vsftpd/empty 	#безпечний каталог для chroot
echo pam_service_name=ftp
#echo rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
#echo rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
echo ssl_enable=NO 		#SSL-сертифікат


#записуємо доступних користувачів
echo ftpuser >>/etc/vsftpd.listic
echo root >>/etc/vsftpd.listic

#файл конфігурації самого корисутвача
exec 1>/etc/vsftpd_users/ftpuser 	
echo local_root=/home/ftpconnection/ftpuser 	#папка куди попадем
echo anon_other_write_enable=YES 	#запис
echo max_per_ip=1 		#кількість можливих підключень

service vsftpd restart 		#перезавантажуєм службу ftp
