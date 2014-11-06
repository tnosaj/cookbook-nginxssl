name             'rtnginx-ssl'
maintainer       'Runtastic GmbH'
maintainer_email 'ops@runtastic.com'
license          'Apache 2.0'
description      "Installs/Configures nginx"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version "0.1.1"
depends          "firewall"
depends          "ssl-certs"
