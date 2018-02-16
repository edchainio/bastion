#!/usr/bin/env bash

### 
### Installation
###

add-apt-repository ppa:certbot/certbot

apt-get -y update

apt-get -y install fail2ban firewalld nginx ntp tree python3 python3-pip python-certbot-nginx ipython3 ipython3-notebook

pip3 install --upgrade pip

pip3 install jupyter matplotlib numpy pandas

###
### Configuration
###

chown -R kensotrabing:kensotrabing /etc/ssh/kensotrabing

chmod 755 /etc/ssh/kensotrabing

chmod 644 /etc/ssh/kensotrabing/authorized_keys

sed -i -e '/^#AuthorizedKeysFile/s/^.*$/AuthorizedKeysFile \/etc\/ssh\/kensotrabing\/authorized_keys/' /etc/ssh/sshd_config

sed -i -e '/^PermitRootLogin/s/^.*$/PermitRootLogin no/' /etc/ssh/sshd_config

sed -i -e '/^PasswordAuthentication/s/^.*$/PasswordAuthentication no/' /etc/ssh/sshd_config

sh -c 'echo "" >> /etc/ssh/sshd_config'

sh -c 'echo "" >> /etc/ssh/sshd_config'

sh -c 'echo "AllowUsers kensotrabing" >> /etc/ssh/sshd_config'

systemctl reload sshd

systemctl start firewalld

firewall-cmd --reload

systemctl enable firewalld

sed -i -e '/^Port/s/^.*$/Port 6174/' /etc/ssh/sshd_config

firewall-cmd --add-port 6174/tcp --permanent

firewall-cmd --reload

systemctl reload sshd

timedatectl set-timezone America/New_York

fallocate -l 3G /swapfile

chmod 600 /swapfile

mkswap /swapfile

sh -c "echo '/swapfile none swap sw 0 0' >> /etc/fstab"

sysctl vm.swappiness=10

sh -c "echo 'vm.swappiness=10' >> /etc/sysctl.conf"

sysctl vm.vfs_cache_pressure=30

sh -c 'echo "vm.vfs_cache_pressure=30" >> /etc/sysctl.conf'

sh -c 'echo "log_format timekeeper \$remote_addr - \$remote_user [\$time_local] " >> /etc/nginx/conf.d/timekeeper-log-format.conf'

sed -i "s/\$remote_addr/\'\$remote_addr/" /etc/nginx/conf.d/timekeeper-log-format.conf

sed -i "s/_local] /_local] \'/" /etc/nginx/conf.d/timekeeper-log-format.conf

sh -c 'echo "                      \$request \$status \$body_bytes_sent " >> /etc/nginx/conf.d/timekeeper-log-format.conf'

sed -i "s/\$request/\'\"\$request\"/" /etc/nginx/conf.d/timekeeper-log-format.conf

sed -i "s/_sent /_sent \'/" /etc/nginx/conf.d/timekeeper-log-format.conf

sh -c 'echo "                      \$http_referer \$http_user_agent \$http_x_forwarded_for \$request_time;" >> /etc/nginx/conf.d/timekeeper-log-format.conf'

sed -i "s/\$http_referer/\'\"\$http_referer\"/" /etc/nginx/conf.d/timekeeper-log-format.conf

sed -i "s/\$http_user_agent/\"\$http_user_agent\"/" /etc/nginx/conf.d/timekeeper-log-format.conf

sed -i "s/\$http_x_forwarded_for/\"\$http_x_forwarded_for\"/" /etc/nginx/conf.d/timekeeper-log-format.conf

sed -i "s/_time;/_time\';/" /etc/nginx/conf.d/timekeeper-log-format.conf

sh -c 'echo "geoip_country /usr/share/GeoIP/GeoIP.dat;" >> /etc/nginx/conf\.d/geoip.conf'

sed -i '/# Default server configuration/a \}' /etc/nginx/sites-available/default

sed -i '/# Default server configuration/a US yes;' /etc/nginx/sites-available/default

sed -i '/# Default server configuration/a default no;' /etc/nginx/sites-available/default

sed -i '/# Default server configuration/a map \$geoip_country_code \$allowed_country \{' /etc/nginx/sites-available/default

sed -i '/# Default server configuration/a \

' /etc/nginx/sites-available/default

sed -i 's/US yes;/        US yes;/' /etc/nginx/sites-available/default

sed -i 's/default no;/        default no;/' /etc/nginx/sites-available/default

sed -i '/listen \[::\]:80 default_server;/a \}#tmp_id_1' /etc/nginx/sites-available/default

sed -i '/listen \[::\]:80 default_server;/a return 444;' /etc/nginx/sites-available/default

sed -i '/listen \[::\]:80 default_server;/a if (\$allowed_country = no) \{' /etc/nginx/sites-available/default

sed -i '/listen \[::\]:80 default_server;/a \

' /etc/nginx/sites-available/default

sed -i 's/\}#tmp_id_1/    \}/' /etc/nginx/sites-available/default

sed -i 's/return 444;/            return 444;/' /etc/nginx/sites-available/default

sed -i 's/if (\$allowed_country = no)/    if (\$allowed_country = no)/' /etc/nginx/sites-available/default

sed -i '/listen \[::\]:80 default_server;/a access_log \/var\/log\/nginx\/server-block-1-access\.log timekeeper gzip;' /etc/nginx/sites-available/default

sed -i 's/access_log \/var\/log\/nginx\/server-block-1-access\.log timekeeper gzip;/    access_log \/var\/log\/nginx\/server-block-1-access\.log timekeeper gzip;/' /etc/nginx/sites-available/default

sed -i '/access_log \/var\/log\/nginx\/server-block-1-access\.log timekeeper gzip;/a error_log \/var\/log\/nginx\/server-block-1-error\.log;' /etc/nginx/sites-available/default

sed -i 's/error_log \/var\/log\/nginx\/server-block-1-error\.log;/    error_log \/var\/log\/nginx\/server-block-1-error\.log;/' /etc/nginx/sites-available/default

sed -i '/listen \[::\]:80 default_server;/a \

' /etc/nginx/sites-available/default

# sed -i -e '/^#    server {/s/^.*$/    server {/' /etc/nginx/nginx.conf

# sed -i -e '/^#        listen       443 ssl http2 default_server;/s/^.*$/        listen       443 ssl http2 default_server;/' /etc/nginx/nginx.conf

# sed -i -e '/^#        listen       \[::\]:443 ssl http2 default_server;/s/^.*$/        listen       \[::\]:443 ssl http2 default_server;/' /etc/nginx/nginx.conf

# sed -i -e '/^#        server_name  _;/s/^.*$/        server_name  _;/' /etc/nginx/nginx.conf

# sed -i -e '/^#        root         \/usr\/share\/nginx\/html;/s/^.*$/        root         \/usr\/share\/nginx\/html;#tmp_id_2/' /etc/nginx/nginx.conf

# sed -i '/^        root         \/usr\/share\/nginx\/html;#tmp_id_2/a resolver 8\.8\.8\.8 8\.8\.4\.4 208\.67\.222\.222 208\.67\.220\.220 216\.146\.35\.35 216\.146\.36\.36 valid=300s;' /etc/nginx/nginx.conf

# sed -i 's/resolver 8\.8\.8\.8 8\.8\.4\.4 208\.67\.222\.222 208\.67\.220\.220 216\.146\.35\.35 216\.146\.36\.36 valid=300s;/        resolver 8\.8\.8\.8 8\.8\.4\.4 208\.67\.222\.222 208\.67\.220\.220 216\.146\.35\.35 216\.146\.36\.36 valid=300s;/' /etc/nginx/nginx.conf

# sed -i '/^        resolver 8\.8\.8\.8 8\.8\.4\.4 208\.67\.222\.222 208\.67\.220\.220 216\.146\.35\.35 216\.146\.36\.36 valid=300s;/a resolver_timeout 3s;' /etc/nginx/nginx.conf

# sed -i 's/resolver_timeout 3s;/        resolver_timeout 3s;/' /etc/nginx/nginx.conf

# sed -i '/^        root         \/usr\/share\/nginx\/html;#tmp_id_2/a \

# #' /etc/nginx/nginx.conf

# sed -i '/^        root         \/usr\/share\/nginx\/html;#tmp_id_2/a #        add_header Strict-Transport-Security \"max-age=31536000; includeSubDomains; preload\";' /etc/nginx/nginx.conf

# sed -i '/^        root         \/usr\/share\/nginx\/html;#tmp_id_2/a add_header Strict-Transport-Security \"max-age=31536000\";' /etc/nginx/nginx.conf

# sed -i 's/add_header Strict-Transport-Security \"max-age=31536000\";/        add_header Strict-Transport-Security \"max-age=31536000\";/' /etc/nginx/nginx.conf

# sed -i '/^        root         \/usr\/share\/nginx\/html;#tmp_id_2/a add_header X-Frame-Options DENY;' /etc/nginx/nginx.conf

# sed -i 's/add_header X-Frame-Options DENY;/        add_header X-Frame-Options DENY;/' /etc/nginx/nginx.conf

# sed -i '/^        root         \/usr\/share\/nginx\/html;#tmp_id_2/a add_header X-Content-Type-Options nosniff;' /etc/nginx/nginx.conf

# sed -i 's/add_header X-Content-Type-Options nosniff;/        add_header X-Content-Type-Options nosniff;/' /etc/nginx/nginx.conf

# sed -i '/^        root         \/usr\/share\/nginx\/html;#tmp_id_2/a \

# #' /etc/nginx/nginx.conf

# sed -i -e '/^#        ssl_certificate "\/etc\/pki\/nginx\/server\.crt";/s/^.*$/        ssl_certificate "\/etc\/pki\/nginx\/server\.crt";/' /etc/nginx/nginx.conf

# sed -i -e '/^#        ssl_certificate_key "\/etc\/pki\/nginx\/private\/server\.key";/s/^.*$/        ssl_certificate_key "\/etc\/pki\/nginx\/private\/server\.key";#tmp_id_6/' /etc/nginx/nginx.conf

# sed -i '/^        ssl_certificate_key \"\/etc\/pki\/nginx\/private\/server\.key\";#tmp_id_6/a ssl_protocols TLSv1 TLSv1\.1 TLSv1\.2;' /etc/nginx/nginx.conf

# sed -i 's/ssl_protocols TLSv1 TLSv1\.1 TLSv1\.2;/        ssl_protocols TLSv1 TLSv1\.1 TLSv1\.2;/' /etc/nginx/nginx.conf

# sed -i '/^        ssl_certificate_key \"\/etc\/pki\/nginx\/private\/server\.key\";#tmp_id_6/a ssl_ecdh_curve secp384r1;' /etc/nginx/nginx.conf

# sed -i 's/ssl_ecdh_curve secp384r1;/        ssl_ecdh_curve secp384r1;/' /etc/nginx/nginx.conf

# sed -i -e '/^#        ssl_session_cache shared:SSL:1m;/s/^.*$/        ssl_session_cache shared:SSL:1m;/' /etc/nginx/nginx.conf

# sed -i -e '/^#        ssl_session_timeout  10m;/s/^.*$/        ssl_session_timeout  10m;/' /etc/nginx/nginx.conf

# sed -i -e '/^#        ssl_ciphers HIGH:!aNULL:!MD5;/s/^.*$/        ssl_ciphers \"EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH\";/' /etc/nginx/nginx.conf

# sed -i -e '/^#        ssl_prefer_server_ciphers on;/s/^.*$/        ssl_prefer_server_ciphers on;/' /etc/nginx/nginx.conf

# sed -i -e '/^#        # Load configuration files for the default server block\./s/^.*$/        # Load configuration files for the default server block\./' /etc/nginx/nginx.conf

# sed -i -e '/^#        include \/etc\/nginx\/default\.d\/\*\.conf;/s/^.*$/        include \/etc\/nginx\/default\.d\/\*\.conf;#tmp_id_3/' /etc/nginx/nginx.conf

# sed -i '/^        include \/etc\/nginx\/default\.d\/\*\.conf;#tmp_id_3/a \}#tmp_id_7' /etc/nginx/nginx.conf

# sed -i 's/\}#tmp_id_7/        \}#tmp_id_7/' /etc/nginx/nginx.conf

# sed -i '/^        include \/etc\/nginx\/default\.d\/\*\.conf;#tmp_id_3/a return 444;#tmp_id_4' /etc/nginx/nginx.conf

# sed -i 's/return 444;#tmp_id_4/            return 444;#tmp_id_4/' /etc/nginx/nginx.conf

# sed -i '/^        include \/etc\/nginx\/default\.d\/\*\.conf;#tmp_id_3/a if (\$allowed_country = no) \{#tmp_id_8' /etc/nginx/nginx.conf

# sed -i 's/if (\$allowed_country = no) {#tmp_id_8/        if (\$allowed_country = no) {#tmp_id_8/' /etc/nginx/nginx.conf

# sed -i '/^        include \/etc\/nginx\/default\.d\/\*\.conf;#tmp_id_3/a \

# #' /etc/nginx/nginx.conf

# sed -i '/^        include \/etc\/nginx\/default\.d\/\*\.conf;#tmp_id_3/a access_log \/var\/log\/nginx\/server-block-1-access.log  timekeeper;#tmp_id_9' /etc/nginx/nginx.conf

# sed -i -e 's/access_log \/var\/log\/nginx\/server-block-1-access.log  timekeeper;#tmp_id_9/        access_log \/var\/log\/nginx\/server-block-1-access.log  timekeeper;#tmp_id_9/' /etc/nginx/nginx.conf

# sed -i '/access_log \/var\/log\/nginx\/server-block-1-access.log  timekeeper;#tmp_id_9/a error_log \/var\/log\/nginx\/server-block-1-error.log;#tmp_id_10' /etc/nginx/nginx.conf

# sed -i -e 's/error_log \/var\/log\/nginx\/server-block-1-error.log;#tmp_id_10/        error_log \/var\/log\/nginx\/server-block-1-error.log;#tmp_id_10/' /etc/nginx/nginx.conf

# sed -i '/^        include \/etc\/nginx\/default\.d\/\*\.conf;#tmp_id_3/a \

# #' /etc/nginx/nginx.conf

# sed -i -e '/^#        location \/ {/s/^.*$/        location \/ {/' /etc/nginx/nginx.conf

# sed -i -e '/^#        }/s/^.*$/        }/' /etc/nginx/nginx.conf

# sed -i -e '/^#        error_page 404 \/404.html;/s/^.*$/        error_page 404 \/404.html;/' /etc/nginx/nginx.conf

# sed -i -e '/^#            location = \/40x.html {/s/^.*$/            location = \/40x.html {/' /etc/nginx/nginx.conf

# sed -i -e '/^#        error_page 500 502 503 504 \/50x.html;/s/^.*$/        error_page 500 502 503 504 \/50x.html;/' /etc/nginx/nginx.conf

# sed -i -e '/^#            location = \/50x.html {/s/^.*$/            location = \/50x.html {/' /etc/nginx/nginx.conf

# sed -i -e '/^#    }/s/^.*$/    }/' /etc/nginx/nginx.conf

sh -c "echo 'gzip_vary on;' >> /etc/nginx/conf.d/gzip.conf"

sh -c "echo 'gzip_proxied any;' >> /etc/nginx/conf.d/gzip.conf"

sh -c "echo 'gzip_comp_level 6;' >> /etc/nginx/conf.d/gzip.conf"

sh -c "echo 'gzip_buffers 16 8k;' >> /etc/nginx/conf.d/gzip.conf"

sh -c "echo 'gzip_http_version 1.1;' >> /etc/nginx/conf.d/gzip.conf"

sh -c "echo 'gzip_min_length 256;' >> /etc/nginx/conf.d/gzip.conf"

sh -c "echo 'gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript application/javascript application/vnd.ms-fontobject application/x-font-ttf font/opentype image/svg+xml image/x-icon;' >> /etc/nginx/conf.d/gzip.conf"

nginx -t

systemctl start nginx

firewall-cmd --permanent --zone=public --add-service=http

firewall-cmd --permanent --zone=public --add-service=https

firewall-cmd --reload

systemctl enable nginx

systemctl enable fail2ban

sh -c 'echo "[DEFAULT]" >> /etc/fail2ban/jail.local'

sh -c 'echo "bantime = 7200" >> /etc/fail2ban/jail.local'

sh -c 'echo "findtime = 1200" >> /etc/fail2ban/jail.local'

sh -c 'echo "maxretry = 3" >> /etc/fail2ban/jail.local'

sh -c 'echo "destemail = kenso.trabing@outlook.com" >> /etc/fail2ban/jail.local'

sh -c 'echo "sendername = security@digitalocean" >> /etc/fail2ban/jail.local'

sh -c 'echo "banaction = iptables-multiport" >> /etc/fail2ban/jail.local'

sh -c 'echo "mta = sendmail" >> /etc/fail2ban/jail.local'

sh -c 'echo "action = %(banaction)s[name=%(__name__)s, bantime=\"%(bantime)s\", port=\"%(port)s\", protocol=\"%(protocol)s\", chain=\"%(chain)s\"], %(mta)s-whois-lines[name=%(__name__)s, dest=\"%(destemail)s\", logpath=%(logpath)s, chain=\"%(chain)s\"]" >> /etc/fail2ban/jail.local'

sh -c 'echo "" >> /etc/fail2ban/jail.local'

sh -c 'echo "[sshd]" >> /etc/fail2ban/jail.local'

sh -c 'echo "enabled = true" >> /etc/fail2ban/jail.local'

sh -c 'echo "" >> /etc/fail2ban/jail.local'

sh -c 'echo "" >> /etc/fail2ban/jail.local'

sh -c 'echo "[sshd-ddos]" >> /etc/fail2ban/jail.local'

sh -c 'echo "enabled = true" >> /etc/fail2ban/jail.local'

sh -c 'echo "" >> /etc/fail2ban/jail.local'

sh -c 'echo "[nginx-http-auth]" >> /etc/fail2ban/jail.local'

sh -c 'echo "enabled = true" >> /etc/fail2ban/jail.local'

systemctl restart fail2ban

cat /home/kensotrabing/.credentials | chpasswd

rm /home/kensotrabing/.credentials
