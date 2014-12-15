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
  subdomain "www"
  servername ["www.example.com","example.com"]
  locations locs
  modifiers mods
  notifies :reload, "nginxssl[instance]"
end

