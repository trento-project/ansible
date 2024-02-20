# Trento Ansible

**THIS IS NOT PRODUCTION READY, HIGHLY WIP, USE AT OWN RISK**

**THE PLAYBOOK ASSUMES YOU ARE ON AN OPENSUSE LEAP 15.5 OR SUSE LINUX ENTERPRISE 15 SP5**

This playbook aims to install Trento components and the belonging third parties.

## Components

- [web](https://github.com/trento-project/web)
- [wanda](https://github.com/trento-project/wanda)
- [agent](https://github.com/trento-project/agent)
- postgresql
- rabbitmq
- prometheus
- nginx

The third parties are installed using `zypper` packages and configured with dedicated roles.

`web` and `wanda` components are installed using containers with the rolling images.

The `agent` is installed from the configured obs repository using `zypper`.

The nginx configuration acts as a reverse proxy for all the components.

### SUSE LINUX ENTERPRISE USERS

This playbook assumes you have an activated license of `Suse Linux Enterprise 15 SP5`, with these modules

- Basesystem Module 15 SP5 x86_64 - `SUSEConnect -p sle-module-basesystem/15.5/x86_64`
- SUSE Package Hub 15 SP5 x86_64 - ` SUSEConnect -p PackageHub/15.5/x86_64`
- Containers Module 15 SP5 x86_64 - `SUSEConnect -p sle-module-containers/15.5/x86_64`

## Usage

You can clone this repository and use them as a normal ansible playbook, making all the updates you need to make to injected variables, embedding other tasks and so on.

We provide two examples to run the playbook as-is without further modifications.

### With local ansible

- Obtain the playbook, like git cloning this repository
- Create an [ansible inventory file](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html)
- Create a json file containing the variables for the playbook or pass them via cli
- Run provision command

**Example inventory to install the trento-server and provision postgres, rabbitmq and prometheus all on the same host**

```yaml
all:
  children:
    trento-server:
      hosts:
        vitellone:
          ansible_host: "your-host"
          ansible_user: "your-user"
    postgres-hosts:
      hosts:
        vitellone:
          ansible_host: "your-host"
          ansible_user: "your-user"
    rabbitmq-hosts:
      hosts:
        vitellone:
          ansible_host: "your-host"
          ansible_user: "your-user"
    prometheus-hosts:
      hosts:
        vitellone:
          ansible_host: "your-host"
          ansible_user: "your-user"
```

**Example json variables file to install trento-server with the all in one node configuration**

```json
{
    "web_postgres_password": "pass",
    "wanda_postgres_password": "wanda",
    "rabbitmq_password": "trento",
    "prometheus_url": "http://localhost",
    "web_admin_password": "adminpassword",
    "trento_server_name": "your-server-name"
}
```

**Example json variables to install trento-server with the all in one node configuration and enable alerting**
```json
{
    "web_postgres_password": "pass",
    "wanda_postgres_password": "wanda",
    "rabbitmq_password": "trento",
    "prometheus_url": "http://localhost",
    "web_admin_password": "adminpassword",
    "trento_server_name": "your-server-name",
    "enable_alerting": "true",
    "alert_sender": "alert-sender-mail",
    "alert_recipient": "alert-receiver-mail",
    "smtp_server": "smtp-server-adress",
    "smtp_port": "smpt-port",
    "smtp_user": "smtp-user",
    "smtp_password": "smtp-password"
}
```

---

**Example inventory to install trento-server, provision postgres, rabbitmq and prometheus each component on dedicated node**

```yaml
all:
  children:
    trento-server:
      hosts:
        vitellone:
          ansible_host: "your-host"
          ansible_user: "your-user"
    postgres-hosts:
      hosts:
        vitellone-pg:
          ansible_host: "your-host"
          ansible_user: "your-user"
    rabbitmq-hosts:
      hosts:
        vitellone-mq:
          ansible_host: "your-host"
          ansible_user: "your-user"
    prometheus-hosts:
      hosts:
        vitellone-metrics:
          ansible_host: "your-host"
          ansible_user: "your-user"
```

**Example json variables files to install trento-server, provision postgres, prometheus and rabbitmq, each component on dedicated node**

```json
{
    "web_postgres_host": "vitellone-pg",
    "wanda_postgres_host": "vitellone-pg",
    "rabbitmq_host": "vitellone-mq:5671",
    "web_postgres_password": "pass",
    "wanda_postgres_password": "wanda",
    "rabbitmq_password": "trento",
    "prometheus_url": "http://localhost",
    "web_admin_password": "adminpassword",
    "trento_server_name": "yourserver.com",
}
```

---

**Example inventory to install trento-server with external postgres and rabbitmq**

```yaml
all:
  children:
    trento-server:
      hosts:
        vitellone:
          ansible_host: "your-host"
          ansible_user: "your-user"
```

**Examle json variables file to install trento-server with external postgres and rabbitmq**

```json
{
    "web_postgres_password": "trentoansible1",
    "wanda_postgres_password": "trentoansible1",
    "web_postgres_host": "yourexternalpg.com",
    "wanda_postgres_host": "yourexternalpg.com",
    "rabbitmq_host": "yourexternalrabbit.com:5671",
    "rabbitmq_password": "trentoansible1",
    "web_postgres_user": "postgres",
    "wanda_postgres_user": "postgres",
    "rabbitmq_username": "trentoansible",
    "prometheus_url": "http://localhost",
    "web_admin_password": "adminpassword",
    "trento_server_name": "your-servername.com",
    "nginx_ssl_cert": "-----BEGIN CERTIFICATE-----\nMIIEKTCCAxGgAwIBAgIUbIzbLpJrkKk8vs1oLzFDpPL...",
    "nginx_ssl_key": "-----BEGIN CERTIFICATE-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDNdvcVnqJAY32h..."
}
```
---
**Example inventory to install the trento agents**

```yaml
all:
  agents:
    hana01:
      ansible_host: "your-hana01-host"
      ansible_user: root
    hana02:
      ansible_host: "your-hana02-host"
      ansible_user: root
```

**Example json variables file to install trento agents**

```json
{
    "trento_server_url:": "http://localhost",
    "rabbitmq_host": "localhost",
    "trento_api_key": "api-key-obtained-from-server"
}
```

> **Note**: <br />
> to have a fully functional deployment make sure to use either an **external IP** or an **internal IP** for `rabbitmq_host` based on the infra network configuration. <br />
> Additionally, retrieving the actual api-key from the server is not supported yet, so use `"enable_api_key": "false"` in extra vars as any value in `trento_api_key` would be ineffective.

Both trento-server and agent inventory and variables file can be combined to deploy both at the same ansible execution.

Having an inventory file called `inventory.yml` and a vars file called `extra-vars.json`, you could run the playbook

```bash
$ ansible-playbook -i inventory.yml --extra-vars @extra-vars.json playbook.yml
```

**This is just an example you can use all the options of `ansible-playbook` with your inventory and other methods of variables injection.**

### With docker container

You can use the docker image `a`, to run this playbook, the image contains the playbook files ready to be provisioned.
The docker image assumes you mount an `inventory` file and an `extra-vars` file.

Mounting your ssh socket will enable you to access the remote machines like in your local environment.

Assuming you have in the current folder a file called `inventory.yml` and `extra-vars.json`

```bash
    docker run \
        -e "SSH_AUTH_SOCK=/ssh-agent" \
        -v $(pwd)/inventory.yml:/playbook/inventory.yml \
        -v $(pwd)/extra-vars.json:/playbook/extra-vars.json \
        -v $SSH_AUTH_SOCK:/ssh-agent \
        ghcr.io/trento-project/ansible:rolling /playbook/inventory.yml /playbook/extra-vars.json
```

## Playbook variables

### Required Variables to install trento-server

| Name         | Description    |
|--------------|-----------|
| web_postgres_password | Password of the postgres user used in web project |
| wanda_postgres_password      | Password of the postgres user used in wanda project |
| rabbitmq_password | Password of the rabbitmq user configured for the trento projects |
| prometheus_url | Base url of prometheus database |
| web_admin_password | Password of the admin user of the web application |
| trento_server_name | Server name of the trento web application, used by nginx |
| nginx_ssl_cert | String with the content of the .crt file to be used by nginx for https |
| nginx_ssl_key | String with the content of the .key file used to generate the certificate |

### Required Variables to install trento agents

| Name         | Description    |
|--------------|-----------|
| trento_api_key | API key to connect to the trento-server |
| rabbitmq_password | Password of the rabbitmq user configured for the trento projects |

### Optional variables
These variables are the defaults of our roles, if you want to override the proper roles variables, feel free to inspect them in the playbook code, under the vars folder in each role.

**We recommend to not change** them unless you are sure of what are you doing in your setup.

**trento-server**

| Name         | Description    | Default |
|--------------|-----------| --------- |
| provision_postgres | Run the postgres provisioning contained into postgres role, set to false if you provide an external postgres to the services | "true" |
| provision_rabbitmq | Run the rabbitmq provisioning contained into rabbitmq role, set to false if you provide an external rabbitmq to the services | "true" |
| provision_proxy | Run the nginx provisioning for exposing all the services, se to false if you don't want to expose the services or you have already in place a reverse proxy infrastructure | "true" |
| provision_prometheus | Run the prometheus provisioning used by trento to store metrics send by agents | "true" |
| docker_network_name | Name of the docker network interface | trentonet |
| web_container_image | Name of the Web container image to use to create the container | ghcr.io/trento-project/trento-web:rolling |
| web_container_name | Name of the Web container | trento_web |
| web_container_port | Port where the Web container is exposed | 4000 |
| wanda_container_image | Name of the Wanda container image to use to create the container | ghcr.io/trento-project/trento-wanda:rolling |
| wanda_container_name | Name of the Wanda container | trento_wanda |
| wanda_container_port | Port where the Wanda container is exposed | 4001 |
| force_pull_images | Force pull the container images for trento components | false |
| force_recreate_web_container | Recreate the web container | false |
| force_recreate_wanda_container | Recreate the wanda container | false |
| remove_web_container_image | Remove Web container image in cleanup task | true |
| remove_wanda_container_image | Remove Wanda container image in cleanup task | true |
| web_postgres_db | Name of the postgres database of the web application | webdb |
| web_postgres_event_store | Name of the postgres event store database of web application | event_store |
| web_postgres_user | Name of the postgres user used by web application | web |
| install_postgres | Install postgresql in the postgres provisioning phase | "true" |
| wanda_postgres_user | Name of the postgres user used by wanda project | wanda |
| wanda_postgres_db | Name of the postgres database of wanda application | wanda |
| web_postgres_host | Postgres host of web project container | host.docker.internal |
| wanda_postgres_host | Postgres host of wanda project container | host.docker.internal |
| rabbitmq_vhost | The rabbitmq vhost used for the current deployment | trento |
| rabbitmq_username | Username of rabbitmq user, this will be created by the rabbitmq role | trento |
| rabbitmq_node_name | The name of rabbitmq node | rabbit@localhost | host.docker.internal |
| rabbitmq_host | The rabbitmq host, used by web and wanda containers. It could include the service port |
| secret_key_base | The secret of phoenix application | Generated by playbook |
| access_token_secret | The secret used for access tokens jwt signature | Generated by playbook |
| refresh_token_secret | The secret used for refresh tokens jwt signature | Generated by playbook |
| web_admin_username | Username of the admin user in web application | admin |
| enable_alerting | Enable the alerting mechanism on web project | false |
| alert_sender | Email address used as the "from" address in alerts | |
| alert_recipient | Email address to receive alert notifications | |
| smtp_server | IP address of the SMTP server | |
| smtp_port | Port number of SMTP server | |
| smtp_user | Username for SMTP authentication | |
| smtp_password | Password for SMTP authentication | |
| install_nginx | Install nginx | true |
| nginx_ssl_cert_as_base64 | Nginx ssl certificate provided as base64 string | false |
| nginx_ssl_key_as_base64 | Nginx ssl key provided as base64 string | false |
| override_nginx_default_conf | Override the default nginx configuration, this will delete the default nginx page and put a configuration that will use the vhosts according to an opinionated directory structure | true |
| nginx_conf_filename | Nginx vhost filename. "conf" suffix is added to the given name | trento |
| nginx_vhost_http_listen_port | Configure the http listen port for trento (redirects to https by default) | 80 |
| nginx_vhost_https_listen_port | Configure the https listen port for trento | 443 |
| enable_api_key | Enable/Disable API key usage. Mostly for testing purposes | true |
| enable_charts | Enable/Disable charts display based on Prometheus metrics | true |
| web_upstream_name | Web nginx upstream name | web |
| wanda_upstream_name | Wanda nginx upstream name | wanda |
| amqp_protocol | Change the amqp protocol type | amqp |
| prometheus_url | Prometheus server url | http://host.docker.internal:9090 |

**trento agents**

| Name         | Description    | Default |
|--------------|-----------| --------- |
| trento_server_url   | Trento server url | http://localhost:4000 |
| trento_repository | OBS repository from where trento agent is installed | https://download.opensuse.org/repositories/devel:sap:trento:factory/SLE_15_SP3/ |
| rabbitmq_username | Username of rabbitmq user, this will be created by the rabbitmq role | trento |
| rabbitmq_host | The rabbitmq host, used by web and wanda containers. It could include the service port |

## Clean up

In order to clean up most of the applied changes and created resources, the `playbook.cleanup` playbook could be used. It uses the same inventory and variables file than the main playbook.

These are the cleaned resources:
- Web and Wanda containers/images
- Docker network
- Postgresql database and users
- Nginx vhost configuration file
- RabbitMQ vhost

Run the playbook with:

```bash
$ ansible-playbook -i inventory.yml --extra-vars @extra-vars.json playbook.cleanup.yml
```

**Disclaimer: The installed packages are not removed as most of the times they are of general usage, and this could have impact in many other services.**

## Usage with vagrant

You can test the playbook using vagrant, the default configuration in this repository assumes that you have VirtualBox, change it to what matches your setup.

The `Vagrantfile` contains sane defaults for running the playbook, it assumes that you have `trento.local` as `localhost` alias in your `/etc/hosts`.

You can reach the trento application using `https://trento.local:8443`.

The Vagrantfile contains a self signed certificate for `trento.local` domain, make sure you accept the exception when prompted by your browser.

Start the vagrant box

```bash
$ vagrant up
```

This will spawn a vagrant box with `Opensuse Leap 15.4` as base box. The provisioning will be automatic after the box starts.

Force provision the vagrant box

```bash
$ vagrant provision
```

Use this command when you want to reprovision (re-run the ansible playbook) the vagrant box, you could use this to rerun the playbook if you are in the development process or you want to change some variables.

## TODO

- [ ] Roles with more granular options
- [ ] Task tagging
- [ ] More examples
- [ ] Proper configure the alerting
- [ ] Pipeline
- More..

# License

Copyright 2023-2024 SUSE LLC

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at

https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.
