node.set['nginx']['config']['ssl']['example.com'] = {
  "ssl_certificate" => "/etc/ssl/certs/ssl-cert-snakeoil.pem",
  "ssl_certificate_key" => "/etc/ssl/private/ssl-cert-snakeoil.key",
  "ssl_protocols" => "TLSv1 TLSv1.1 TLSv1.2",
  "ssl_ciphers" => "RC4:HIGH:!aNULL:!MD5",
  "ssl_prefer_server_ciphers" => "on"
}


nginxssl "instance" do
  action :install
end

nginxssl "instance" do
  action :configure
end

mods = {
  "rewrite to https" => {
    "query" => '$http_host = "example.com"',
    "options" => 'rewrite ^/(.*)$ https://www.example.com/$1'
  }
}

# Site disable default
locs = {
  "shop" => {
    "base" => "/shop",
    "options" => {
      "proxy_pass" => "http://123.123.123.123:80",
      "proxy_set_header" => {
        "Host" => "$host",
        "x-forwarded-for" => "$remote_addr"
      }
    }
  },
  "default" => {
    "base" => "/",
    "options" => {
      "proxy_pass" => "http://123.123.123.123:80",
      "proxy_set_header" => {
        "Host" => "$host",
        "x-forwarded-for" => "$remote_addr"
      }
    }
  }
}
nginxssl_site "www" do
  action :enable
  servername ["www.example.com","example.com"]
  domain "example.com"
  locations locs
  modifiers mods
  notifies :reload, "nginxssl[instance]"
end

nginxssl_site "totally-not-example.com" do
  action :enable
  subdomain "www"
  domain "example.com"
  onlyrewrite true
  notifies :reload, "nginxssl[instance]"
end

