#!/usr/bin/env bash

##############################################################################
#*++*+++***+**++*+++*                                    *+++*++**+***+++*++*#
#++*+++***+**++*+++*                                      *+++*++**+***+++*++#
#+*+++***+**++*+++*               Next Steps               *+++*++**+***+++*+#
#++*+++***+**++*+++*                                      *+++*++**+***+++*++#
#*++*+++***+**++*+++*                                    *+++*++**+***+++*++*#
##############################################################################

git clone git://github.com/edchainio/attribution-engine.git

cd attribution-engine

virtualenv -p python3 --no-site-packages venv

source venv/bin/activate

pip3 install -r requirements.txt

# TODO Add systemd unit file

nohup python3 run/wsgi.py &