# Trento Ansible

**THIS IS NOT PRODUCTION READY, HIGHLY WIP, USE AT OWN RISK**

**THE PLAYBOOK ASSUMES YOU ARE ON AN OPENSUSE LEAP 15.3 OR SUSE LINUX ENTERPRISE 15 SP4**

This playbook aims to install Trento components and the belonging third parties.

## Components

- [web](https://github.com/trento-project/web)
- [wanda](https://github.com/trento-project/wanda)
- postgresql
- rabbitmq
- grafana
- prometheus (WIP)
- nginx



The third parties are installed using `zypper` packages and configured with dedicated roles.

`web` and `wanda` components are installed using containers with the rolling images.

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

**Example inventory**

```yaml
all:
  hosts:
    vitellone:
      ansible_host: "your-host.com"
      ansible_user: root
```

**Example json variables file**

```json
{
    "web_postgres_password": "pass",
    "wanda_postgres_password": "wanda",
    "rabbitmq_password": "trento",
    "runner_url": "http://localhost",
    "prometheus_url": "http://localhost",
    "web_admin_password": "adminpassword",
    "trento_server_name": "your-server-name"
}
```

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

### Required Variables

| Name         | Description    |
|--------------|-----------|
| web_postgres_password | Password of the postgres user used in web project |
| wanda_postgres_password      | Password of the postgres user used in wanda project |
| rabbitmq_password | Password of the rabbitmq user configured for the trento projects |
| prometheus_url | Base url of prometheus database |
| web_admin_password | Password of the admin user of the web application |
| trento_server_name | Server name of the trento web application, used by nginx |

### Optional variables
These variables are the defaults of our roles, if you want to override the proper roles variables, feel free to inspect them in the playbook code, under the vars folder in each role.

**We recommend to not change** them unless you are sure of what are you doing in your setup.

| Name         | Description    | Default |
|--------------|-----------| --------- |
| web_postgres_db | Name of the postgres database of the web application | webdb |
| web_postgres_event_store | Name of the postgres event store database of web application | event_store |
| web_postgres_user | Name of the postgres user used by web application | web |
| wanda_postgres_user | Name of the postgres user used by wanda project | wanda |
| wanda_postgres_db | Name of the postgres database of wanda application | wanda |
| web_postgres_host | Postgres host of web project container | host.docker.internal |
| wanda_postgres_host | Postgres host of wanda project container | host.docker.internal |
| rabbitmq_username | Username of rabbitmq user, this will be created by the rabbitmq role | trento |
| rabbitmq_node_name | The name of rabbitmq node | rabbit@localhost | host.docker.internal |
| rabbitmq_host | The rabbitmq host, used by web and wanda containers | 
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