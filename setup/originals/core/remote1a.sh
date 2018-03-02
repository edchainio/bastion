

##############################################################################
#*++*+++***+**++*+++*                                    *+++*++**+***+++*++*#
#++*+++***+**++*+++*                                      *+++*++**+***+++*++#
#+*+++***+**++*+++*              Installation              *+++*++**+***+++*+#
#++*+++***+**++*+++*                                      *+++*++**+***+++*++#
#*++*+++***+**++*+++*                                    *+++*++**+***+++*++*#
##############################################################################

add-apt-repository -y ppa:certbot/certbot

add-apt-repository -y ppa:webupd8team/java

echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections

echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections

wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -

echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list

echo "deb http://packages.elastic.co/kibana/4.5/debian stable main" | tee -a /etc/apt/sources.list.d/kibana-4.5.x.list

echo 'deb http://packages.elastic.co/logstash/2.2/debian stable main' | tee /etc/apt/sources.list.d/logstash-2.2.x.list

curl -L -O https://download.elastic.co/beats/dashboards/beats-dashboards-1.1.0.zip

curl -O https://gist.githubusercontent.com/thisismitch/3429023e8438cc25b86c/raw/d8c479e2a1adcea8b1fe86570e42abab0f10f364/filebeat-index-template.json

apt-get -y update

apt-get -y install oracle-java8-installer elasticsearch kibana nginx apache2-utils logstash unzip firewalld fail2ban git nginx gzip ntp python-certbot-nginx tree

##############################################################################
#*++*+++***+**++*+++*                                    *+++*++**+***+++*++*#
#++*+++***+**++*+++*                                      *+++*++**+***+++*++#
#+*+++***+**++*+++*              Configuration             *+++*++**+***+++*+#
#++*+++***+**++*+++*                                      *+++*++**+***+++*++#
#*++*+++***+**++*+++*                                    *+++*++**+***+++*++*#
##############################################################################

#   Set-up Elastic Search   # # # # # # # # # # # # # # # # # # # # # # # # ##

sed -i -e '/^# network.host/s/^.*$/network.host: localhost/' /etc/elasticsearch/elasticsearch.yml

service elasticsearch restart

update-rc.d elasticsearch defaults 95 10

#   Set-up Kibana   # # # # # # # # # # # # # # # # # # # # # # # # # # # # ##

sed -i -e '/^# server.host/s/^.*$/server.host: "localhost"/' /opt/kibana/config/kibana.yml

update-rc.d kibana defaults 96 9

service kibana start

#   Set-up Nginx   # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

cat /home/<remote_username>/.htpasswd-credentials | htpasswd -i -c /etc/nginx/htpasswd.users <remote_username>

rm /home/<remote_username>/.htpasswd-credentials

sed -i '/^\s*server_name/a auth_basic_user_file \/etc\/nginx\/htpasswd\.users;' /etc/nginx/sites-available/default

sed -i '/^\s*server_name/a auth_basic "Restricted Access";' /etc/nginx/sites-available/default

sed -i '/^\s*server_name/a \

' /etc/nginx/sites-available/default

sed -i 's/auth_basic_user_file \/etc\/nginx\/htpasswd\.users;/    auth_basic_user_file \/etc\/nginx\/htpasswd\.users;/' /etc/nginx/sites-available/default

sed -i 's/auth_basic "Restricted Access";/    auth_basic "Restricted Access";/' /etc/nginx/sites-available/default

sed -i -e '/^\s*server_name/s/^.*$/    server_name <core_server_public_ip_address>;/' /etc/nginx/sites-available/default

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

#   Set-up Logstash: Part 1   # # # # # # # # # # # # # # # # # # # # # # # ##

mkdir -p /etc/pki/tls/certs

mkdir -p /etc/pki/tls/private

sed -i '/\[ v3_ca \]/a subjectAltName = IP: <core_server_private_ip_address>' /etc/ssl/openssl.cnf

cd /etc/pki/tls && openssl req -config /etc/ssl/openssl.cnf -x509 -days 3650 -batch -nodes -newkey rsa:2048 -keyout private/logstash-forwarder.key -out certs/logstash-forwarder.crt && cd

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

#   Set-up sample Kibana dashboard   # # # # # # # # # # # # # # # # # # # # #

unzip beats-dashboards-*.zip

cd beats-dashboards-* && ./load.sh && cd