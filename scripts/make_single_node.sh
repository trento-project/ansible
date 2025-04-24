#!/bin/bash

set -euo pipefail

create_x509() {
  machine_ip=${1?:required argument}
  dir=${2:-"."}
  openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 \
      -nodes -keyout "$dir/$machine_ip".key -out "$dir/$machine_ip".crt -subj "/CN=$machine_ip" \
      -addext "subjectAltName=IP:$machine_ip"
}

join_lines(){
  file=${1?:required argument}
  cat "$file" | awk '{printf "%s\\n", $0}'
}

machine_ip=${1?:required argument}
machine_fqdn=${2:-$machine_ip}
data_dir=${3:-"data"}
user=${4:-"ec2-user"}

mkdir -p "$data_dir"
create_x509 "$machine_ip" "$data_dir"
# create a base64 string of the x509 certificate
base64_crt=$(join_lines "$data_dir/$machine_ip.crt")
# create a base64 string of the x509 key
base64_key=$(join_lines "$data_dir/$machine_ip.key")
 

vars=$(cat <<EOF
{
    "provision_prometheus": "true",
    "provision_proxy": "true",
    "web_postgres_password": "postgres",
    "wanda_postgres_password": "postgres",
    "rabbitmq_password": "guest",
    "web_admin_password": "adminpassword",
    "trento_server_name": "$machine_fqdn",
    "nginx_ssl_cert": "$base64_crt",
    "nginx_ssl_key": "$base64_key",
    "prometheus_url": "http://localhost:9090"
}
EOF
)

# create a json file with the variables
echo "$vars" > "$data_dir/vars.$machine_ip.json" 


inventory=$(cat <<EOF
all:
  children:
    trento_server:
      hosts:
        vitellone:
          ansible_user: "$user"
          ansible_host: "$machine_ip"
    postgres_hosts:
      hosts:
        vitellone:
          ansible_user: "$user"
          ansible_host: "$machine_ip"
    rabbitmq_hosts:
      hosts:
        vitellone:
          ansible_user: "$user"
          ansible_host: "$machine_ip"
    prometheus_hosts:
      hosts:
        vitellone:
          ansible_user: "$user"
          ansible_host: "$machine_ip"
EOF
)

# create a yaml file with the variables
echo "$inventory" > "$data_dir/inventory.$machine_ip.yml"

printf "Created vars.$machine_ip.json and inventory.$machine_ip.yml into $data_dir folder\n"
printf "\n\n"
printf "To run the playbook, use the following command:\n\n"
printf "ansible-playbook -i $data_dir/inventory.$machine_ip.yml -e @$data_dir/vars.$machine_ip.json playbook.yml \n"