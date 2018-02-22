# #!/usr/bin/env bash


# # Aftermath

# # Downloaded the edChain logo from the website and make it into an SVG before doing the following

# scp -P 6699 ~/Downloads/edchain-logo.svg kensotrabing@159.65.171.118:/tmp

# ssh -p 6699 kensotrabing@159.65.171.118

# cd /tmp

# sudo cp edchain-logo.svg /opt/kibana/src/ui/public/images

# cd /opt/kibana/src/ui/public/images

# sudo cp kibana.svg kibana.svg.bak

# sudo cp edchain-logo.svg kibana.svg

# # above is actually wrong

# # maybe the below is a workaround
# sudo cp edchain-logo.svg ../../../../optimize/bundles/src/ui/public/images/kibana.svg

# scp -P 6699 ~/Downloads/edchain-logo.png kensotrabing@159.65.171.118:/tmp

# sudo cp /tmp/edchain-logo.png .



# #######
# # things are starting to make sense
# sudo vi /opt/kibana/optimize/bundles/kibana.bundle.js

# # change this
#         module.exports = __webpack_require__.p + "src/ui/public/images/kibana.png"
# # to this
#         module.exports = __webpack_require__.p + "src/ui/public/images/edchain-logo.png"



# sudo vi /opt/kibana/optimize/bundles/webpack.records
# # change this
# "node_modules/file-loader/index.js?name=[path][name].[ext]!/home/kbn-build/kibana/build/kibana/src/ui/public/images/kibana.svg"
# # to this
# "node_modules/file-loader/index.js?name=[path][name].[ext]!/home/kbn-build/kibana/build/kibana/src/ui/public/images/edchain-logo.png"


# sudo vi /opt/kibana/src/plugins/kibana/public/kibana.js
# # change this
# const kibanaLogoUrl = require('ui/images/kibana.svg');
# # to this
# const kibanaLogoUrl = require('ui/images/edchain-logo.png');

# cd /opt/kibana

# # installing an arbitrary plugin to try to get kibana to rebundle the dashboard with the edchain logo
# sudo bin/kibana plugin --install elastic/sense
# # it worked

# # resizing the logo locally
# convert Downloads/edchain-logo.png -resize x45 Downloads/edchain-logo-45x113.png

# convert Downloads/edchain-logo-45x113.png -background none -gravity center -extent 252 Downloads/edchain-logo-45x252.png

# scp -P 6699 ~/Downloads/edchain-logo-45x252.png kensotrabing@159.65.171.118:/tmp

# ssh -p 6699 kensotrabing@159.65.171.118

# sudo cp /tmp/edchain-logo-45x252.png ../../../../optimize/bundles/src/ui/public/images/edchain-logo.png

# # reinstalling plugin to force bundling
# sudo bin/kibana plugin --remove elastic/sense

# sudo bin/kibana plugin --install elastic/sense
