# Trento Ansible

**THIS IS NOT PRODUCTION READY, HIGHLY WIP, USE AT OWN RISK**

**THE PLAYBOOK ASSUMES YOU ARE ON AN OPENSUSE LEAP 15.3 OR SUSE LINUX ENTERPRISE 15 SP4**

This playbook aims to install Trento components and the belonging third parties.

## Components

- [web](https://github.com/trento-project/web)
- [wanda](https://github.com/trento-project/wanda)
- [agent](https://github.com/trento-project/agent)
- postgresql
- rabbitmq
- grafana
- prometheus (WIP)
- nginx

The third parties are installed using `zypper` packages and configured with dedicated roles.

`web` and `wanda` components are installed using containers with the rolling images.

The `agent` is installed from the configured obs repository using `zypper`.

The nginx configuration acts as a reverse proxy for all the components.

### SUSE LINUX ENTERPRISE USERS

This playbook assumes you have an activated license of `Suse Linux Enterprise 15 SP4`, with these modules

- Basesystem Module 15 SP4 x86_64 - `SUSEConnect -p sle-module-basesystem/15.4/x86_64`
- SUSE Package Hub 15 SP4 x86_64 - ` SUSEConnect -p PackageHub/15.4/x86_64`
- Containers Module 15 SP4 x86_64 - `SUSEConnect -p sle-module-containers/15.4/x86_64`

## Usage

You can clone this repository and use them as a normal ansible playbook, making all the updates you need to make to injected variables, embedding other tasks and so on.

We provide two examples to run the playbook as-is without further modifications.

### With local ansible

- Obtain the playbook, like git cloning this repository
- Create an [ansible inventory file](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html)
- Create a json file containing the variables for the playbook or pass them via cli
- Run provision command

**Example inventory to install the trento-server**

```yaml
all:
  trento-server:
    vitellone:
      ansible_host: "your-host.com"
      ansible_user: root
```

**Example json variables file to install trento-server**

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
    "server_url:": "http://localhost",
    "rabbitmq_host": "localhost",
    "api_key": "api-key-obtained-from-server"
}
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
        ghcr.io/cdimonaco/trento-ansible:rolling /playbook/inventory.yml /playbook/extra-vars.json
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

### Required Variables to install trento agents

| Name         | Description    |
|--------------|-----------|
| api_key | API key to connect to the trento-server |
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
| web_postgres_db | Name of the postgres database of the web application | webdb |
| web_postgres_event_store | Name of the postgres event store database of web application | event_store |
| web_postgres_user | Name of the postgres user used by web application | web |
| install_postgres | Install postgresql in the postgres provisioning phase | "true" |
| wanda_postgres_user | Name of the postgres user used by wanda project | wanda |
| wanda_postgres_db | Name of the postgres database of wanda application | wanda |
| web_postgres_host | Postgres host of web project container | host.docker.internal |
| wanda_postgres_host | Postgres host of wanda project container | host.docker.internal |
| rabbitmq_username | Username of rabbitmq user, this will be created by the rabbitmq role | trento |
| rabbitmq_node_name | The name of rabbitmq node | rabbit@localhost | host.docker.internal |
| rabbitmq_host | The rabbitmq host, used by web and wanda containers. It could include the service port |
| grafana_public_url | Base url of grafana application | /grafana |
| secret_key_base | The secret of phoenix application | Generated by playbook |
| access_token_secret | The secret used for access tokens jwt signature | Generated by playbook |
| refresh_token_secret | The secret used for refresh tokens jwt signature | Generated by playbook |
| web_admin_username | Username of the admin user in web application | admin |
| enable_alerting | Enable the alerting mechanism on web project | false |
| grafana_sub_path | The subpath of the grafana application | /grafana |
| grafana_api_url | Base API endpoint of grafana, used for dashboard and datasources provision, the defaults assumes you are installing grafana on the same host of the docker container, using the defaults of this playbook | http://host.docker.internal:3000/api |
| install_nginx | Install nginx | true |
| override_nginx_default_conf | Override the default nginx configuration, this will delete the default nginx page and put a configuration that will use the vhosts according to an opinionated directory structure | true |
| enable_api_key | Enable/Disable API key usage. Mostly for testing purposes | true |

**trento agents**

| Name         | Description    | Default |
|--------------|-----------| --------- |
| server_url   | Trento server url | http://localhost:4000 |
| trento_repository | OBS repository from where trento agent is installed | https://download.opensuse.org/repositories/devel:sap:trento:factory/SLE_15_SP3/ |
| rabbitmq_username | Username of rabbitmq user, this will be created by the rabbitmq role | trento |
| rabbitmq_host | The rabbitmq host, used by web and wanda containers. It could include the service port |

## Usage with vagrant

You can test the playbook using vagrant, the default configuration in this repository assumes that you have VirtualBox, change it to what matches your setup.

The `Vagrantfile` contains sane defaults for running the playbook, you can find the application running on `localhost:8080` or `trento.local:8080` if you have `trento.local` as `localhost` alias in your `/etc/hosts`.

Start the vagrant box

```bash
$ vagrant up
```

This will spawn a vagrant box with `Opensuse Leap 15.3` as base box. The provisioning will be automatic after the box starts.

Force provision the vagrant box

```bash
$ vagrant provision
```

Use this command when you want to reprovision (re-run the ansible playbook) the vagrant box, you could use this to rerun the playbook if you are in the development process or you want to change some variables.

## TODO

- [ ] Roles with more granular options
- [ ] Task tagging
- [ ] More examples
- [ ] Add prometheus
- [ ] Proper configure the alerting
- [ ] Pipeline
- More..