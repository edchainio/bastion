#!/usr/bin/env bash

##############################################################################
#*++*+++***+**++*+++*                                    *+++*++**+***+++*++*#
#++*+++***+**++*+++*                                      *+++*++**+***+++*++#
#+*+++***+**++*+++*              Installation              *+++*++**+***+++*+#
#++*+++***+**++*+++*                                      *+++*++**+***+++*++#
#*++*+++***+**++*+++*                                    *+++*++**+***+++*++*#
##############################################################################

# TODO Integrate the ELK installation-and-config. with the build script.
#
#   All of the following installs need to be run on one line, after the 
#   repositories are added to the package manager.

add-apt-repository ppa:certbot/certbot

add-apt-repository -y ppa:webupd8team/java

echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections

echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections

wget -N http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz

gunzip GeoLiteCity.dat.gz

mv GeoLiteCity.dat /usr/share/GeoIP/

wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -

echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list

echo 'deb http://packages.elastic.co/logstash/2.2/debian stable main' | tee /etc/apt/sources.list.d/logstash-2.2.x.list

echo "deb http://packages.elastic.co/kibana/4.5/debian stable main" | tee -a /etc/apt/sources.list.d/kibana-4.5.x.list

apt-get -y update

apt-get -y install oracle-java8-installer elasticsearch logstash kibana gunzip unzip firewalld fail2ban git nginx-full apache2-utils geoip-database ntp python3 python3-pip python-certbot-nginx tree

pip3 install --upgrade pip


##############################################################################
#*++*+++***+**++*+++*                                    *+++*++**+***+++*++*#
#++*+++***+**++*+++*                                      *+++*++**+***+++*++#
#+*+++***+**++*+++*              Configuration             *+++*++**+***+++*+#
#++*+++***+**++*+++*                                      *+++*++**+***+++*++#
#*++*+++***+**++*+++*                                    *+++*++**+***+++*++*#
##############################################################################

sed -i -e '/^# network.host/s/^.*$/network.host: localhost/' /etc/elasticsearch/elasticsearch.yml

service elasticsearch restart

update-rc.d elasticsearch defaults 95 10

sed -i -e '/^# server.host/s/^.*$/server.host: "localhost"/' /opt/kibana/config/kibana.yml

update-rc.d kibana defaults 96 9

service kibana start

mkdir -p /etc/pki/tls/certs

mkdir -p /etc/pki/tls/private

sed -i '/\[ v3_ca \]/a subjectAltName = IP: <core_server_private_ip_address>' /etc/ssl/openssl.cnf

cd /etc/pki/tls && openssl req -config /etc/ssl/openssl.cnf -x509 -days 3650 -batch -nodes -newkey rsa:2048 -keyout private/logstash-forwarder.key -out certs/logstash-forwarder.crt

sh -c 'echo "input {" >> /etc/logstash/conf.d/02-beats-input.conf'

sh -c 'echo "  beats {" >> /etc/logstash/conf.d/02-beats-input.conf'

sh -c 'echo "    port => 5044" >> /etc/logstash/conf.d/02-beats-input.conf'

sh -c 'echo "    ssl => true" >> /etc/logstash/conf.d/02-beats-input.conf'

sh -c 'echo "    ssl_certificate => \"/etc/pki/tls/certs/logstash-forwarder.crt\"" >> /etc/logstash/conf.d/02-beats-input.conf'

sh -c 'echo "    ssl_key => \"/etc/pki/tls/private/logstash-forwarder.key\"" >> /etc/logstash/conf.d/02-beats-input.conf'

sh -c 'echo "  }" >> /etc/logstash/conf.d/02-beats-input.conf'

sh -c 'echo "}" >> /etc/logstash/conf.d/02-beats-input.conf'

sh -c 'echo "filter {" >> /etc/logstash/conf.d/10-syslog-filter.conf'

sh -c 'echo "  if [type] == \"syslog\" {" >> /etc/logstash/conf.d/10-syslog-filter.conf'

sh -c 'echo "    grok {" >> /etc/logstash/conf.d/10-syslog-filter.conf'

sh -c 'echo "      match => { \"message\" => \"%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:[%{POSINT:syslog_pid}])?: %{GREEDYDATA:syslog_message}\" }" >> /etc/logstash/conf.d/10-syslog-filter.conf'

sh -c 'echo "      add_field => [ \"received_at\", \"%{@timestamp}\" ]" >> /etc/logstash/conf.d/10-syslog-filter.conf'

sh -c 'echo "      add_field => [ \"received_from\", \"%{host}\" ]" >> /etc/logstash/conf.d/10-syslog-filter.conf'

sh -c 'echo "    }" >> /etc/logstash/conf.d/10-syslog-filter.conf'

sh -c 'echo "    syslog_pri { }" >> /etc/logstash/conf.d/10-syslog-filter.conf'

sh -c 'echo "    date {" >> /etc/logstash/conf.d/10-syslog-filter.conf'

sh -c 'echo "      match => [ \"syslog_timestamp\", \"MMM  d HH:mm:ss\", \"MMM dd HH:mm:ss\" ]" >> /etc/logstash/conf.d/10-syslog-filter.conf'

sh -c 'echo "    }" >> /etc/logstash/conf.d/10-syslog-filter.conf'

sh -c 'echo "  }" >> /etc/logstash/conf.d/10-syslog-filter.conf'

sh -c 'echo "}" >> /etc/logstash/conf.d/10-syslog-filter.conf'

sh -c 'echo "output {" >> /etc/logstash/conf.d/30-elasticsearch-output.conf'

sh -c 'echo "  elasticsearch {" >> /etc/logstash/conf.d/30-elasticsearch-output.conf'

sh -c 'echo "    hosts => [\"localhost:9200\"]" >> /etc/logstash/conf.d/30-elasticsearch-output.conf'

sh -c 'echo "    sniffing => true" >> /etc/logstash/conf.d/30-elasticsearch-output.conf'

sh -c 'echo "    manage_template => false" >> /etc/logstash/conf.d/30-elasticsearch-output.conf'

sh -c 'echo "    index => \"%{[@metadata][beat]}-%{+YYYY.MM.dd}\"" >> /etc/logstash/conf.d/30-elasticsearch-output.conf'

sh -c 'echo "    document_type => \"%{[@metadata][type]}\"" >> /etc/logstash/conf.d/30-elasticsearch-output.conf'

sh -c 'echo "  }" >> /etc/logstash/conf.d/30-elasticsearch-output.conf'

sh -c 'echo "}" >> /etc/logstash/conf.d/30-elasticsearch-output.conf'

service logstash configtest

service logstash restart

update-rc.d logstash defaults 96 9

# Note: These are sample Kibana dashboards
cd && curl -L -O https://download.elastic.co/beats/dashboards/beats-dashboards-1.1.0.zip

unzip beats-dashboards-*.zip

cd beats-dashboards-* && ./load.sh

cd && curl -O https://gist.githubusercontent.com/thisismitch/3429023e8438cc25b86c/raw/d8c479e2a1adcea8b1fe86570e42abab0f10f364/filebeat-index-template.json

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # ##
## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # ##
## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # ##

#   I feel like this part of the script is the most unstable.
#
#   SSH keys need to be non-interactively generated on the ELK server
#   to be shared with the client nodes, too.

#
# Core Server
#

ssh-keygen -t rsa -b 4096 # Core Server


#
# LOCAL 
#

# !!!!!!!!!!!!!!! 
# There's a disconnect here
# 	logically, the user copying and pasting this into their shell would have to `exit`
#
# FIXME The following command are running locally
cd crossdock # Thin Client

scp root@<core_server_public_ip_address>:/etc/pki/tls/certs/logstash-forwarder.crt . # Thin Client

scp logstash-forwarder.crt root@<client_server_public_ip_address>:/tmp # Thin Client

ssh root@<client_server_public_ip_address> # Thin Client

## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # ##
## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

#
# Core Server
#

mkdir -p /opt/logstash/patterns

chown logstash: /opt/logstash/patterns

sh -c 'echo "NGUSERNAME [a-zA-Z\\\.\\@\\-\\+_%]+" >> /opt/logstash/patterns/nginx'

sh -c 'echo "NGUSER %{NGUSERNAME}" >> /opt/logstash/patterns/nginx'

sh -c 'echo "NGINXACCESS %{IPORHOST:clientip} %{NGUSER:ident} %{NGUSER:auth} \[%{HTTPDATE:timestamp}\] \"%{WORD:verb} %{URIPATHPARAM:request} HTTP/%{NUMBER:httpversion}\" %{NUMBER:response} (?:%{NUMBER:bytes}|-) (?:\"(?:%{URI:referrer}|-)\"|%{QS:referrer}) %{QS:agent}" >> /opt/logstash/patterns/nginx'

chown logstash: /opt/logstash/patterns/nginx

sh -c 'echo "filter {" >> /etc/logstash/conf.d/11-nginx-filter.conf'

sh -c 'echo "  if [type] == \"nginx-access\" {" >> /etc/logstash/conf.d/11-nginx-filter.conf'

sh -c 'echo "    grok {" >> /etc/logstash/conf.d/11-nginx-filter.conf'

sh -c 'echo "      match => { \"message\" => \"%{NGINXACCESS}\" }" >> /etc/logstash/conf.d/11-nginx-filter.conf'

sh -c 'echo "    }" >> /etc/logstash/conf.d/11-nginx-filter.conf'

sh -c 'echo "  }" >> /etc/logstash/conf.d/11-nginx-filter.conf'

sh -c 'echo "}" >> /etc/logstash/conf.d/11-nginx-filter.conf'

service logstash restart

chown -R <remote_username>:<remote_username> /etc/ssh/<remote_username>

chmod 755 /etc/ssh/<remote_username>

chmod 644 /etc/ssh/<remote_username>/authorized_keys

sed -i -e '/^#AuthorizedKeysFile/s/^.*$/AuthorizedKeysFile \/etc\/ssh\/<remote_username>\/authorized_keys/' /etc/ssh/sshd_config

sed -i -e '/^PermitRootLogin/s/^.*$/PermitRootLogin no/' /etc/ssh/sshd_config

sed -i -e '/^PasswordAuthentication/s/^.*$/PasswordAuthentication no/' /etc/ssh/sshd_config

sh -c 'echo "" >> /etc/ssh/sshd_config'

sh -c 'echo "" >> /etc/ssh/sshd_config'

sh -c 'echo "AllowUsers <remote_username>" >> /etc/ssh/sshd_config'

systemctl reload sshd

systemctl start firewalld

firewall-cmd --reload

systemctl enable firewalld

sed -i -e '/^Port/s/^.*$/Port <defined_ssh_port>/' /etc/ssh/sshd_config

firewall-cmd --add-port <defined_ssh_port>/tcp --permanent

firewall-cmd --add-port 9200/tcp --permanent

firewall-cmd --add-port 5601/tcp --permanent

firewall-cmd --add-port 5044/tcp --permanent

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

cat /home/<remote_username>/.htpasswd-credentials | htpasswd -i -c /etc/nginx/htpasswd.users <remote_username>

rm /home/<remote_username>/.htpasswd-credentials

sh -c 'echo "geoip_country /usr/share/GeoIP/GeoIP.dat;" >> /etc/nginx/conf\.d/geoip.conf'

sh -c 'echo "geoip_city /usr/share/GeoIP/GeoLiteCity.dat;" >> /etc/nginx/conf\.d/geoip.conf'

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

sed -i '/^\s*server_name/a auth_basic_user_file \/etc\/nginx\/htpasswd\.users;' /etc/nginx/sites-available/default

sed -i '/^\s*server_name/a auth_basic "Restricted Access";' /etc/nginx/sites-available/default

sed -i '/^\s*server_name/a \

' /etc/nginx/sites-available/default

sed -i 's/auth_basic_user_file \/etc\/nginx\/htpasswd\.users;/    auth_basic_user_file \/etc\/nginx\/htpasswd\.users;/' /etc/nginx/sites-available/default

sed -i 's/auth_basic "Restricted Access";/    auth_basic "Restricted Access";/' /etc/nginx/sites-available/default

sed -i -e '/^\s*server_name/s/^.*$/    server_name <vps_public_ip_address>;/' /etc/nginx/sites-available/default

sed -i '/^\s*try_files/a proxy_cache_bypass \$http_upgrade;' /etc/nginx/sites-available/default

sed -i '/^\s*try_files/a proxy_set_header Host \$host;' /etc/nginx/sites-available/default

sed -i '/^\s*try_files/a proxy_set_header Connection 'upgrade';' /etc/nginx/sites-available/default

sed -i '/^\s*try_files/a proxy_set_header Upgrade \$http_upgrade;' /etc/nginx/sites-available/default

sed -i '/^\s*try_files/a proxy_http_version 1.1;' /etc/nginx/sites-available/default

sed -i '/^\s*try_files/a proxy_pass http:\/\/localhost:5601;' /etc/nginx/sites-available/default

sed -i 's/proxy_cache_bypass \$http_upgrade;/        proxy_cache_bypass \$http_upgrade;/' /etc/nginx/sites-available/default

sed -i 's/proxy_set_header Host \$host;/        proxy_set_header Host \$host;/' /etc/nginx/sites-available/default

sed -i 's/proxy_set_header Connection 'upgrade';/        proxy_set_header Connection 'upgrade';/' /etc/nginx/sites-available/default

sed -i 's/proxy_set_header Upgrade \$http_upgrade;/        proxy_set_header Upgrade \$http_upgrade;/' /etc/nginx/sites-available/default

sed -i 's/proxy_http_version 1.1;/        proxy_http_version 1.1;/' /etc/nginx/sites-available/default

sed -i 's/proxy_pass http:\/\/localhost:5601;/        proxy_pass http:\/\/localhost:5601;/' /etc/nginx/sites-available/default

sed -i -e 's/^\s*try_files/        # try_files \$uri \$uri\/ =404;/' /etc/nginx/sites-available/default

nginx -t

service nginx restart

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

sh -c 'echo "destemail = <email_address>" >> /etc/fail2ban/jail.local'

sh -c 'echo "sendername = security@<cluster_name>" >> /etc/fail2ban/jail.local'

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

# ##############################################################################
# #                                                                            #
# # journalctl                                                                 #
# # ~~~~~~~~~~                                                                 #
# #                                                                            #
# # TODO n: Limit journal expansion by defining the following options:         #
# #                                                                            #
# # SystemMaxUse=                                                              #
# # SystemKeepFree=                                                            #
# # SystemMaxFileSize=                                                         #
# # RuntimeMaxUse=                                                             #
# # RuntimeKeepFree=                                                           #
# # RuntimeMaxFileSize=                                                        #
# #                                                                            #
# # ...in /etc/systemd/journald.conf, which is pasted, below.                  #
# #                                                                            #
# # #  This file is part of systemd.                                           #
# # #                                                                          #
# # #  systemd is free software; you can redistribute it and/or modify it      #
# # #  under the terms of the GNU Lesser General Public License as published by#
# # #  the Free Software Foundation; either version 2.1 of the License, or     #
# # #  (at your option) any later version.                                     #
# # #                                                                          #
# # # Entries in this file show the compile time defaults.                     #
# # # You can change settings by editing this file.                            #
# # # Defaults can be restored by simply deleting this file.                   #
# # #                                                                          #
# # # See journald.conf(5) for details.                                        #
# #                                                                            #
# # [Journal]                                                                  #
# # #Storage=auto                                                              #
# # #Compress=yes                                                              #
# # #Seal=yes                                                                  #
# # #SplitMode=uid                                                             #
# # #SyncIntervalSec=5m                                                        #
# # #RateLimitInterval=30s                                                     #
# # #RateLimitBurst=1000                                                       #
# # #SystemMaxUse=                                                             #
# # #SystemKeepFree=                                                           #
# # #SystemMaxFileSize=                                                        #
# # #SystemMaxFiles=100                                                        #
# # #RuntimeMaxUse=                                                            #
# # #RuntimeKeepFree=                                                          #
# # #RuntimeMaxFileSize=                                                       #
# # #RuntimeMaxFiles=100                                                       #
# # #MaxRetentionSec=                                                          #
# # #MaxFileSec=1month                                                         #
# # #ForwardToSyslog=yes                                                       #
# # #ForwardToKMsg=no                                                          #
# # #ForwardToConsole=no                                                       #
# # #ForwardToWall=yes                                                         #
# # #TTYPath=/dev/console                                                      #
# # #MaxLevelStore=debug                                                       #
# # #MaxLevelSyslog=debug                                                      #
# # #MaxLevelKMsg=notice                                                       #
# # #MaxLevelConsole=info                                                      #
# # #MaxLevelWall=emerg                                                        #
# #                                                                            #
# #                                                                            #
# ##############################################################################

cat /home/<remote_username>/.chpasswd-credentials | chpasswd

rm /home/<remote_username>/.chpasswd-credentials