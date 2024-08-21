# Trento Ansible

This playbook aims to install Trento components and the belonging third parties.

> **NOTE:** The playbook currently only supports the following SLES4SAP releases:

- 15 SP3[^1]
- 15 SP4
- 15 SP5

[^1]: For SP3, Prometheus installation needs to be provided manually.

## Components

- [web](https://github.com/trento-project/web)
- [wanda](https://github.com/trento-project/wanda)
- [agent](https://github.com/trento-project/agent)
- postgresql
- rabbitmq
- prometheus
- nginx

The third parties are installed using `zypper` packages and configured with dedicated roles. The
`web` and `wanda` components can be installed using either docker or zypper. The playbook checks
the `install_method` variable (either `docker` or `rpm`) to determine which to method to use.

The `agent` is installed from the configured obs repository using `zypper`.

The nginx configuration acts as a reverse proxy for all the components.

### SUSE LINUX ENTERPRISE USERS

**This playbook requires that the host where you are going to install trento-server has an activated license**
for one of the supported OSs, with the following modules (Change `x` to match your current version):

- Basesystem Module 15 x86_64 - `SUSEConnect -p sle-module-basesystem/15.x/x86_64`
- SUSE Package Hub 15 x86_64 - ` SUSEConnect -p PackageHub/15.x/x86_64`
- (Optional: for `docker` installation method) Containers Module 15 x86_64 - `SUSEConnect -p sle-module-containers/15.x/x86_64`

## Usage

### 1. Clone the repository

`git clone https://github.com/trento-project/ansible.git`

### 2. Prepare your inventory file

Get to the `ansible` directory:
`cd ansible`

Make sure all hosts with active roles allow access from the machine that is executing the playbook:

```
ssh-copy-id root@192.168.1.1
```

Create an `inventory.yml` file, defining the IP address of the machine where each role will be deployed to. You might use the same machine for more
than one role. Use `;` to comment out any role that you might not want to cover.

Example:

```
[trento-server]
192.168.1.1 ansible_user=root ansible_ssh_private_key_file=/home/user/.ssh/id_rsa

[postgres-hosts]
192.168.1.1 ansible_user=root ansible_ssh_private_key_file=/home/user/.ssh/id_rsa

[rabbitmq-hosts]
192.168.1.1 ansible_user=root ansible_ssh_private_key_file=/home/user/.ssh/id_rsa

[prometheus-hosts]
192.168.1.1 ansible_user=root ansible_ssh_private_key_file=/home/user/.ssh/id_rsa

; [agents]
; 192.168.1.2 ansible_user=root ansible_ssh_private_key_file=/home/user/.ssh/id_rsa
```

Alternatively, you can use yaml syntax for this. In the following example we use a user/password instead of an SSH key:

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

### 3. Setup playbook variables

Create a vars.json file, following the example below:
> **Note**: <br />
> The default values for variables ending with `_host` usually point to:
>  - `host.docker.internal` when using `docker` install method
>  - `localhost` in the case of `rpm` install method.
> These work for single-host deployments but be sure to set them explicitly when pointing to manually deployed
> services either with an **external IP** or an **internal IP** based on the infra network configuration or when using multi-node deployments.

```
{
  "provision_prometheus": "true",
  "provision_proxy": "false",
  "web_postgres_password": "postgres",
  "wanda_postgres_password": "postgres",
  "rabbitmq_password": "guest",
  "web_admin_password": "adminpassword",
  "trento_server_name": "trento-deployment.example.com",
  "nginx_vhost_filename": "trento-deployment.example.com",
  "nginx_ssl_cert": "<paste your SSL certificate here in base64>",
  "nginx_ssl_key": "<paste your SSL certificate key here in base64>"
}
```
> Additionally, when deploying trento agents using the playbook, api-key auto retrieval from the server is not supported yet, so either
> use `"enable_api_key": "false"` and skip `trento_api_key` altogether or disable agent deployment for the first run, retrieve the api-key from the UI
> and set the `trento_api_key` accordingly.

### 4. Run the playbook

Prior to running the playbook, tell ansible to fetch the required modules:
```
ansible-galaxy collection install -r requirements.yml
```

> **Note**: <br />
> The `@` character in front of the `vars.json` path is mandatory. This tells `ansible-playbook` that the variables will not be specified in-line but
> as an external file instead.

Run the playbook:
```
ansible-playbook -i path/to/inventory.yml --extra-vars "@path/to/vars.json" playbook.yml
```


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

| Name                    | Description                                                               |
| ----------------------- | ------------------------------------------------------------------------- |
| web_postgres_password   | Password of the postgres user used in web project                         |
| wanda_postgres_password | Password of the postgres user used in wanda project                       |
| rabbitmq_password       | Password of the rabbitmq user configured for the trento projects          |
| prometheus_url          | Base url of prometheus database                                           |
| web_admin_password      | Password of the admin user of the web application                         |
| trento_server_name      | Server name of the trento web application, used by nginx                  |
| nginx_ssl_cert          | String with the content of the .crt file to be used by nginx for https    |
| nginx_ssl_key           | String with the content of the .key file used to generate the certificate |

### Required Variables to install trento agents

| Name              | Description                                                      |
| ----------------- | ---------------------------------------------------------------- |
| trento_api_key    | API key to connect to the trento-server                          |
| rabbitmq_password | Password of the rabbitmq user configured for the trento projects |

### Optional variables

These variables are the defaults of our roles, if you want to override the proper roles variables, feel free to inspect them in the playbook code, under the vars folder in each role.

**We recommend to not change** them unless you are sure of what are you doing in your setup.

**trento-server**

| Name                           | Description                                                                                                      | Default                                     |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------------- | ------------------------------------------- |
| provision_postgres             | Provision postgres role, set to false if you provide an external postgres to the services                        | "true"                                      |
| provision_rabbitmq             | Provision rabbitmq role, set to false if you provide an external rabbitmq to the services                        | "true"                                      |
| provision_proxy                | Provision nginx to expose the services, set to false to use an existing reverse proxy deployment                 | "true"                                      |
| provision_prometheus           | Provision prometheus used by trento to store metrics send by agents                                              | "true"                                      |
| docker_network_name            | Name of the docker network to be used by the deployment when using "docker" install_method                       | trentonet                                   |
| web_container_image            | Name of the Web container image to use to create the container                                                   | ghcr.io/trento-project/trento-web:rolling   |
| web_container_name             | Name of the Web container                                                                                        | trento_web                                  |
| web_listen_port                | Port where the Web service is exposed                                                                            | 4000                                        |
| wanda_container_image          | Name of the Wanda container image to use to create the container                                                 | ghcr.io/trento-project/trento-wanda:rolling |
| wanda_container_name           | Name of the Wanda container                                                                                      | trento_wanda                                |
| wanda_listen_port              | Port where the Wanda service is exposed                                                                          | 4001                                        |
| force_pull_images              | Force pull the container images for trento components                                                            | false                                       |
| force_recreate_web_container   | Recreate the web container                                                                                       | false                                       |
| force_recreate_wanda_container | Recreate the wanda container                                                                                     | false                                       |
| remove_web_container_image     | Remove Web container image in cleanup task                                                                       | true                                        |
| remove_wanda_container_image   | Remove Wanda container image in cleanup task                                                                     | true                                        |
| web_postgres_db                | Name of the postgres database of the web application                                                             | webdb                                       |
| web_postgres_event_store       | Name of the postgres event store database of web application                                                     | event_store                                 |
| web_postgres_user              | Name of the postgres user used by web application                                                                | web                                         |
| install_postgres               | Install postgresql in the postgres provisioning phase                                                            | "true"                                      |
| wanda_postgres_user            | Name of the postgres user used by wanda project                                                                  | wanda                                       |
| wanda_postgres_db              | Name of the postgres database of wanda application                                                               | wanda                                       |
| web_postgres_host              | Postgres host of web project container                                                                           | host.docker.internal                        |
| wanda_postgres_host            | Postgres host of wanda project container                                                                         | host.docker.internal                        |
| rabbitmq_vhost                 | The rabbitmq vhost used for the current deployment                                                               | trento                                      |
| rabbitmq_username              | Username of rabbitmq user, this will be created by the rabbitmq role                                             | trento                                      |
| rabbitmq_node_name             | The name of rabbitmq node                                                                                        | rabbit@localhost                            |
| rabbitmq_host                  | The rabbitmq host, used by web and wanda containers. It could include the service port                           | host.docker.internal                        |
| secret_key_base                | The secret of phoenix application                                                                                | Generated by playbook                       |
| access_token_secret            | The secret used for access tokens JWT signature                                                                  | Generated by playbook                       |
| refresh_token_secret           | The secret used for refresh tokens JWT signature                                                                 | Generated by playbook                       |
| web_admin_username             | Username of the admin user in web application                                                                    | admin                                       |
| enable_alerting                | Enable the alerting mechanism on web project                                                                     | false                                       |
| alert_sender                   | Email address used as the "from" address in alerts                                                               |                                             |
| alert_recipient                | Email address to receive alert notifications                                                                     |                                             |
| smtp_server                    | IP address of the SMTP server                                                                                    |                                             |
| smtp_port                      | Port number of SMTP server                                                                                       |                                             |
| smtp_user                      | Username for SMTP authentication                                                                                 |                                             |
| smtp_password                  | Password for SMTP authentication                                                                                 |                                             |
| enable_oidc                    | Enable OIDC integration, this disables the username/password authentication method                           | false                                       |
| oidc_client_id                 | OIDC client id, required when enable_oidc is true                                                                |                                             |
| oidc_client_secret             | OIDC client secret, required when enable_oidc is true                                                            |                                             |
| oidc_server_base_url           | OIDC identity provider base url, required when enable_oidc is true                                               |                                             |
| install_nginx                  | Install nginx                                                                                                    | true                                        |
| nginx_ssl_cert_as_base64       | Nginx SSL certificate provided as base64 string                                                                  | false                                       |
| nginx_ssl_key_as_base64        | Nginx SSL key provided as base64 string                                                                          | false                                       |
| override_nginx_default_conf    | Override the default nginx conf for one that will use the vhosts according to an opinionated directory structure | true                                        |
| nginx_vhost_filename           | Nginx vhost filename. "conf" suffix is added to the given name                                                   | trento                                      |
| nginx_vhost_http_listen_port   | Configure the http listen port for trento (redirects to https by default)                                        | 80                                          |
| nginx_vhost_https_listen_port  | Configure the https listen port for trento                                                                       | 443                                         |
| enable_api_key                 | Enable/Disable API key usage. Mostly for testing purposes                                                        | true                                        |
| enable_charts                  | Enable/Disable charts display based on Prometheus metrics                                                        | true                                        |
| web_upstream_name              | Web nginx upstream name                                                                                          | web                                         |
| wanda_upstream_name            | Wanda nginx upstream name                                                                                        | wanda                                       |
| amqp_protocol                  | Change the amqp protocol type                                                                                    | amqp                                        |
| prometheus_url                 | Prometheus server url                                                                                            | http://localhost:9090                       |
| web_host                       | Host where the web instance is listening                                                                         | http://localhost                            |
| install_method                 | Installation method for trento components, can be either `rpm` or `docker`                                       | rpm                                         |


**trento agents**

| Name              | Description                                                                            | Default                                                                         |
| ----------------- | -------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| trento_server_url | Trento server url                                                                      | http://localhost:4000                                                           |
| trento_repository | OBS repository from where trento agent is installed                                    | https://download.opensuse.org/repositories/devel:sap:trento:factory/SLE_15_SP3/ |
| rabbitmq_username | Username of rabbitmq user, this will be created by the rabbitmq role                   | trento                                                                          |
| rabbitmq_host     | The rabbitmq host, used by web and wanda containers. It could include the service port |

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
