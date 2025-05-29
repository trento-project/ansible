#!/bin/bash

# This script creates the necessary files to run the Ansible playbook
# for a single node installation of Trento.
# It generates a self-signed certificate and creates the inventory and
# variables files in JSON format.
# The script takes the following arguments:
# 1. The IP address of the machine where Trento will be installed.
# 2. The FQDN of the machine (optional, defaults to the IP address).
# 3. The directory where the files will be created (optional, defaults to "data").
# 4. The user to connect to the machine (optional, defaults to "ec2-user").
# The script creates the following files:
# - vars.<machine_ip>.json: JSON file with the variables for the playbook.
# - inventory.<machine_ip>.yml: YAML inventory file for the playbook.
# - inventory.<machine_ip>.ini: INI inventory file for the playbook (include variables).
# - <machine_ip>.crt: self-signed certificate for the machine.
# - <machine_ip>.key: private key for the machine.
# The script also prints the command to run the playbook with the generated files.
# Usage: ./make_single_node.sh <machine_ip> [<machine_fqdn>] [<data_dir>] [<user>]

set -euo pipefail

create_x509() {
  machine_ip=${1?:required argument}
  crt_file=${2?:required argument}
  key_file=${3?:required argument}
  openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 \
      -nodes -keyout "$key_file" -out "$crt_file" -subj "/CN=$machine_ip" \
      -addext "subjectAltName=IP:$machine_ip" > /dev/null 2>&1
}

join_lines(){
  file=${1?:required argument}
  cat "$file" | awk '{printf "%s\\n", $0}'
}

# read arguments
machine_ip=${1?:required argument}
machine_fqdn=${2:-$machine_ip}
data_dir=${3:-"data"}
user=${4:-"ec2-user"}

# setup data directory, if not exists
mkdir -p "$data_dir"

# files to be created
vars_json_file="vars.$machine_ip.json"
inventory_yml_file="inventory.$machine_ip.yml"
inventory_ini_file="inventory.$machine_ip.ini"
crt_file="$machine_ip.crt"
key_file="$machine_ip.key"

# set the destination directory as the current directory
pushd "$data_dir" > /dev/null

# create the files
create_x509 "$machine_ip" "$crt_file" "$key_file"
crt=$(join_lines "$crt_file")
key=$(join_lines "$key_file")

cat <<EOF > "$vars_json_file"
{
    "provision_prometheus": "true",
    "provision_proxy": "true",
    "web_postgres_password": "postgres",
    "wanda_postgres_password": "postgres",
    "rabbitmq_password": "guest",
    "web_admin_password": "adminpassword",
    "trento_server_name": "$machine_fqdn",
    "nginx_ssl_cert": "$crt",
    "nginx_ssl_key": "$key",
    "prometheus_url": "http://localhost:9090"
}
EOF

cat <<EOF > "$inventory_yml_file"
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

cat <<EOF > "$inventory_ini_file"
[all:vars]
provision_prometheus=true
provision_proxy=true
web_postgres_password=postgres
wanda_postgres_password=postgres
rabbitmq_password=guest
web_admin_password=adminpassword
trento_server_name="$machine_fqdn"
nginx_ssl_cert="$crt"
nginx_ssl_key="$key"
prometheus_url="http://localhost:9090"

[trento_server]
vitellone ansible_user=ec2-user ansible_host=$machine_ip

[postgres_hosts]
vitellone ansible_user=ec2-user ansible_host=$machine_ip

[rabbitmq_hosts]
vitellone ansible_user=ec2-user ansible_host=$machine_ip

[prometheus_hosts]
vitellone ansible_user=ec2-user ansible_host=$machine_ip
EOF


# pop the directory stack
popd > /dev/null

printf "\n\n"
printf "The following files have been created into '$data_dir' folder:\n"
printf " - $vars_json_file\n"
printf " - $inventory_yml_file\n"
printf " - $inventory_ini_file\n"
printf " - $crt_file\n"
printf " - $key_file\n"
printf "\n\n"
printf "To run the playbook, use the following command:\n\n"
printf "ansible-playbook -i $data_dir/inventory.$machine_ip.yml -e @$data_dir/vars.$machine_ip.json playbook.yml \n"
printf "\n"
printf "or\n\n"
printf "ansible-playbook -i $data_dir/inventory.$machine_ip.ini playbook.yml \n"
printf "\n\n"
