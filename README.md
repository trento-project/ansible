# Trento Ansible

This playbook aims to install Trento components and the belonging third parties.

> **NOTE:** The playbook currently only supports the following SLES4SAP releases:

- 15 SP3[^1]
- 15 SP4
- 15 SP5
- 15 SP6

[^1]: For SP3, Prometheus installation needs to be provided manually.

## Components

- [web](https://github.com/trento-project/web)
- [wanda](https://github.com/trento-project/wanda)
- [checks](https://github.com/trento-project/checks)
- [agent](https://github.com/trento-project/agent)
- postgresql
- rabbitmq
- prometheus
- nginx

The third parties are installed using `zypper` packages and configured with dedicated roles. The
`web` and `wanda` components can be installed using either docker or zypper. The playbook checks
the `install_method` variable (either `docker` or `rpm`) to determine which method to use.

The `agent` is installed from the configured obs repository using `zypper`.

The nginx configuration acts as a reverse proxy for all the components.

### SUSE LINUX ENTERPRISE USERS

**This playbook requires that the host where you are going to install trento-server has an activated license**
for one of the supported OSs, with the following modules (Change `x` to match your current version):

- Basesystem Module 15 x86_64 - `SUSEConnect -p sle-module-basesystem/15.x/x86_64`
- SUSE Package Hub 15 x86_64 - ` SUSEConnect -p PackageHub/15.x/x86_64`
- (Optional: for `docker` installation method) Containers Module 15 x86_64 - `SUSEConnect -p sle-module-containers/15.x/x86_64`
- (15.6 only) Legacy Module 15 x86_64 - `SUSEConnect -p sle-module-legacy/15.6/x86_64`

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
[trento_server]
192.168.1.1 ansible_user=root ansible_ssh_private_key_file=/home/user/.ssh/id_rsa

[postgres_hosts]
192.168.1.1 ansible_user=root ansible_ssh_private_key_file=/home/user/.ssh/id_rsa

[rabbitmq_hosts]
192.168.1.1 ansible_user=root ansible_ssh_private_key_file=/home/user/.ssh/id_rsa

[prometheus_hosts]
192.168.1.1 ansible_user=root ansible_ssh_private_key_file=/home/user/.ssh/id_rsa

; [agents]
; 192.168.1.2 ansible_user=root ansible_ssh_private_key_file=/home/user/.ssh/id_rsa
```

Alternatively, you can use yaml syntax for this. In the following example we use a user/password instead of an SSH key:

```yaml
all:
  children:
    trento_server:
      hosts:
        vitellone:
          ansible_host: "your-host"
          ansible_user: "your-user"
    postgres_hosts:
      hosts:
        vitellone:
          ansible_host: "your-host"
          ansible_user: "your-user"
    rabbitmq_hosts:
      hosts:
        vitellone:
          ansible_host: "your-host"
          ansible_user: "your-user"
    prometheus_hosts:
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


Both trento_server and agent inventory and variables file can be combined to deploy both at the same ansible execution.

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

### Required Variables to install trento_server

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
| trento_api_key    | API key to connect to the trento_server                          |
| rabbitmq_password | Password of the rabbitmq user configured for the trento projects |

### Optional variables

These variables are the defaults of our roles, if you want to override the proper roles variables, feel free to inspect them in the playbook code, under the vars folder in each role.

**We recommend to not change** them unless you are sure of what are you doing in your setup.

**trento-server**

| Name                            | Description                                                                                                      | Default                                               |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| provision_postgres              | Provision postgres role, set to false if you provide an external postgres to the services                        | "true"                                                |
| provision_rabbitmq              | Provision rabbitmq role, set to false if you provide an external rabbitmq to the services                        | "true"                                                |
| provision_proxy                 | Provision nginx to expose the services, set to false to use an existing reverse proxy deployment                 | "true"                                                |
| provision_prometheus            | Provision prometheus used by trento to store metrics send by agents                                              | "true"                                                |
| docker_network_name             | Name of the docker network to be used by the deployment when using "docker" install_method                       | trentonet                                             |
| web_container_image             | Name of the Web container image to use to create the container                                                   | ghcr.io/trento-project/trento-web:rolling             |
| web_container_name              | Name of the Web container                                                                                        | trento_web                                            |
| web_listen_port                 | Port where the Web service is exposed                                                                            | 4000                                                  |
| wanda_container_image           | Name of the Wanda container image to use to create the container                                                 | ghcr.io/trento-project/trento-wanda:rolling           |
| wanda_container_name            | Name of the Wanda container                                                                                      | trento_wanda                                          |
| wanda_listen_port               | Port where the Wanda service is exposed                                                                          | 4001                                                  |
| force_pull_images               | Force pull the container images for trento components                                                            | false                                                 |
| force_recreate_web_container    | Recreate the web container                                                                                       | false                                                 |
| force_recreate_wanda_container  | Recreate the wanda container                                                                                     | false                                                 |
| remove_web_container_image      | Remove Web container image in cleanup task                                                                       | true                                                  |
| remove_wanda_container_image    | Remove Wanda container image in cleanup task                                                                     | true                                                  |
| checks_container_image          | Name of the Checks container image to use to create the container                                                | ghcr.io/trento-project/checks:rolling                 |
| checks_container_name           | Name of the Checks container                                                                                     | trento_checks                                         |
| force_recreate_checks_container | Recreate the checks container                                                                                    | false                                                 |
| remove_checks_container_image   | Remove checks container image in cleanup task                                                                    | true                                                  |
| web_postgres_db                 | Name of the postgres database of the web application                                                             | webdb                                                 |
| web_postgres_event_store        | Name of the postgres event store database of web application                                                     | event_store                                           |
| web_postgres_user               | Name of the postgres user used by web application                                                                | web                                                   |
| install_postgres                | Install postgresql in the postgres provisioning phase                                                            | "true"                                                |
| wanda_postgres_user             | Name of the postgres user used by wanda project                                                                  | wanda                                                 |
| wanda_postgres_db               | Name of the postgres database of wanda application                                                               | wanda                                                 |
| web_postgres_host               | Postgres host of web project container                                                                           | host.docker.internal                                  |
| wanda_postgres_host             | Postgres host of wanda project container                                                                         | host.docker.internal                                  |
| rabbitmq_vhost                  | The rabbitmq vhost used for the current deployment                                                               | trento                                                |
| rabbitmq_username               | Username of rabbitmq user, this will be created by the rabbitmq role                                             | trento                                                |
| rabbitmq_node_name              | The name of rabbitmq node                                                                                        | rabbit@localhost                                      |
| rabbitmq_host                   | The rabbitmq host, used by web and wanda containers. It could include the service port                           | host.docker.internal                                  |
| secret_key_base                 | The secret of phoenix application                                                                                | Generated by playbook                                 |
| access_token_secret             | The secret used for access tokens JWT signature                                                                  | Generated by playbook                                 |
| refresh_token_secret            | The secret used for refresh tokens JWT signature                                                                 | Generated by playbook                                 |
| web_admin_username              | Username of the admin user in web application                                                                    | admin                                                 |
| enable_alerting                 | Enable the alerting mechanism on web project                                                                     | false                                                 |
| alert_sender                    | Email address used as the "from" address in alerts                                                               |                                                       |
| alert_recipient                 | Email address to receive alert notifications                                                                     |                                                       |
| smtp_server                     | IP address of the SMTP server                                                                                    |                                                       |
| smtp_port                       | Port number of SMTP server                                                                                       |                                                       |
| smtp_user                       | Username for SMTP authentication                                                                                 |                                                       |
| smtp_password                   | Password for SMTP authentication                                                                                 |                                                       |
| enable_oidc                     | Enable OIDC integration, this disables the username/password authentication method (self exclusive SSO type)     | false                                                 |
| oidc_client_id                  | OIDC client id, required when enable_oidc is true                                                                |                                                       |
| oidc_client_secret              | OIDC client secret, required when enable_oidc is true                                                            |                                                       |
| oidc_server_base_url            | OIDC identity provider base url, required when enable_oidc is true                                               |                                                       |
| enable_oauth2                   | Enable OAUTH2 integration, this disables the username/password authentication method (self exclusive SSO type)   | false                                                 |
| oauth2_client_id                | OAUTH2 client id, required when enable_oauth2 is true                                                            |                                                       |
| oauth2_client_secret            | OAUTH2 client secret, required when enable_oauth2 is true                                                        |                                                       |
| oauth2_server_base_url          | OAUTH2 identity provider base url, required when enable_oauth2 is true                                           |                                                       |
| oauth2_authorize_url            | OAUTH2 authorize url, required when enable_oauth2 is true                                                        |                                                       |
| oauth2_token_url                | OAUTH2 token url, required when enable_oauth2 is true                                                            |                                                       |
| oauth2_user_url                 | OAUTH2 user information url, required when enable_oauth2 is true                                                 |                                                       |
| oauth2_scopes                   | OAUTH2 scopes, required when enable_oauth2 is true                                                               | "profile email"                                       |
| enable_saml                     | Enable SAML integration, this disables the username/password authentication method (self exclusive SSO type)     | false                                                 |
| saml_idp_id                     | SAML IDP id, required when enable_saml is true                                                                   |                                                       |
| saml_idp_nameid_format          | SAML IDP name id format, used to interpret the attribute name. Whole urn string must be used                     | urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified |
| saml_sp_dir                     | SAML SP directory, where SP specific required files (such as certificates and metadata file) are placed          | /etc/trento/trento-web/saml                           |
| saml_sp_id                      | SAML SP id, required when enable_saml is true                                                                    |                                                       |
| saml_sp_entity_id               | SAML SP entity id                                                                                                |                                                       |
| saml_sp_contact_name            | SAML SP contact name                                                                                             | "Trento SP Admin"                                     |
| saml_sp_contact_email           | SAML SP contact email                                                                                            | "admin@trento.suse.com"                               |
| saml_sp_org_name                | SAML SP organization name                                                                                        | "Trento SP"                                           |
| saml_sp_org_displayname         | SAML SP organization display name                                                                                | "SAML SP build with Trento"                           |
| saml_sp_org_url                 | SAML SP organization url                                                                                         | https://www.trento-project.io/                        |
| saml_username_attr_name         | SAML user profile "username" attribute field name. This attribute must exist in the IDP user                     | username                                              |
| saml_email_attr_name            | SAML user profile "email" attribute field name. This attribute must exist in the IDP user                        | email                                                 |
| saml_firstname_attr_name        | SAML user profile "first name" attribute field name. This attribute must exist in the IDP user                   | firstName                                             |
| saml_lastname_attr_name         | SAML user profile "last name" attribute field name. This attribute must exist in the IDP user                    | lastName                                              |
| saml_metadata_url               | URL to retrieve the SAML metadata xml file. One of `saml_metadata_url` or `saml_metadata_content` is required    |                                                       |
| saml_metadata_content           | One line string containing the SAML metadata xml file content (`saml_metadata_url` has precedence over this)     |                                                       |
| saml_sign_requests              | Sign SAML requests in the SP side                                                                                | true                                                  |
| saml_sign_metadata              | Sign SAML metadata documents in the SP side                                                                      | true                                                  |
| saml_signed_assertion           | Require to receive SAML assertion signed from the IDP. Set to false if the IDP doesn't sign the assertion        | true                                                  |
| saml_signed_envelopes           | Require to receive SAML envelopes signed from the IDP. Set to false if the IDP doesn't sign the envelopes        | true                                                  |
| install_nginx                   | Install nginx                                                                                                    | true                                                  |
| nginx_ssl_cert_as_base64        | Nginx SSL certificate provided as base64 string                                                                  | false                                                 |
| nginx_ssl_key_as_base64         | Nginx SSL key provided as base64 string                                                                          | false                                                 |
| override_nginx_default_conf     | Override the default nginx conf for one that will use the vhosts according to an opinionated directory structure | true                                                  |
| nginx_vhost_filename            | Nginx vhost filename. "conf" suffix is added to the given name                                                   | trento                                                |
| nginx_vhost_http_listen_port    | Configure the http listen port for trento (redirects to https by default)                                        | 80                                                    |
| nginx_vhost_https_listen_port   | Configure the https listen port for trento                                                                       | 443                                                   |
| enable_api_key                  | Enable/Disable API key usage. Mostly for testing purposes                                                        | true                                                  |
| enable_charts                   | Enable/Disable charts display based on Prometheus metrics                                                        | true                                                  |
| web_upstream_name               | Web nginx upstream name                                                                                          | web                                                   |
| wanda_upstream_name             | Wanda nginx upstream name                                                                                        | wanda                                                 |
| amqp_protocol                   | Change the amqp protocol type                                                                                    | amqp                                                  |
| prometheus_url                  | Prometheus server url                                                                                            | http://localhost:9090                                 |
| web_host                        | Host where the web instance is listening                                                                         | http://localhost                                      |
| install_method                  | Installation method for trento components, can be either `rpm` or `docker`                                       | rpm                                                   |
| generate_certs | Whether the needed certificates will be generated by the script automatically | true |
generated_certs_dir | The directory that contains the needed certificates. If `generate_certs` is true, this directory will be created and used to store generated certificates. Otherwise, it specifies where the playbook will look for pre-generated certificates on the control node | /tmp/trento-ansible-certs |

**trento agents**

| Name              | Description                                                                            | Default                                                                         |
| ----------------- | -------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| trento_server_url | Trento server url                                                                      | http://localhost:4000                                                           |
| trento_repository | OBS repository from where trento agent is installed                                    | https://download.opensuse.org/repositories/devel:sap:trento:factory/SLE_15_SP3/ |
| rabbitmq_username | Username of rabbitmq user, this will be created by the rabbitmq role                   | trento                                                                          |
| rabbitmq_host     | The rabbitmq host, used by web and wanda containers. |
| rabbitmq_port     | The port the rabbitmq server is listening to |

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

## About certificates

The playbook takes also care of cryptographic certificates and their configuration as required by the different scenarios. 
This chapter provides further details on the cryptographic features already mentioned before in this document.

### HTTPS access from the internet
Web applications are exposed to the internet through a Nginx instance acting as a reverse proxy. To enable HTTPS connections, a valid certificate and private key MUST be provided as extra variables to the playbook.

Such variables are:

| Name                            | Description                                                                                                      | Default                                               |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| nginx_ssl_cert                  | Required. String with the content of the .crt file to be used by nginx for https                                 |                                                       |
| nginx_ssl_key                   | Required. String with the content of the .key file used to generate the certificate                              |                                                       |
| nginx_ssl_cert_as_base64        | Nginx SSL certificate provided as base64 string                                                                  | false                                                 |
| nginx_ssl_key_as_base64         | Nginx SSL key provided as base64 string                                                                          | false                                                 |

The certificate should be signed by a known Certificate Authority in order to be recognized as valid by the connecting clients.

### mTLS for authentication with RabbitMQ server

Authentication of the client applications with the RabbitMQ server is enforced with mutual TLS.
In short, both the server and client applications present, on connection, a CA certificate and another certificate signed with such CA. By sharing the same CA of the server, each client is then authenticated with the server and the connection can be established (please refer to the RabbitMQ documentation for a proper explanation https://www.rabbitmq.com/docs/ssl).

The playbook takes care of distributing the certificates to the correct host and configure the connection strings accordingly.
It reads the files from a given directory on the control node on which the playbook is executed, and expects them to have a meaningful name, in order to be associated with the correct host.

| file                           | description                                                        |
| ------------------------------ | ------------------------------------------------------------------ |
| `ca.key`                       | Private key of the CA, used to sign client and server certificates |
| `ca.crt`                       | CA certificate, to be provided for authentication                  |
| `rabbitmq.key`                 | Private key for the identity of the RabbitMQ server                |
| `rabbitmq.cert`                | Signed certificate of the RabbitMQ server                          |
| `<group name>_<host name>.key` | Private key for given client                                       |
| `<group name>_<host name>.crt` | Signed certifcate for given client                                 |

As an example, supposing to have the following inventory:

```yaml
all:
  children:
    agents:
      hosts:
        vitellone:
          ansible_host: "your-host"
          ansible_user: "your-user"
        vitelltwo:
          ansible_host: "your-host"
          ansible_user: "your-user"
    trento_server:
      hosts:
        vitellone:
          ansible_host: "your-host"
          ansible_user: "your-user"
    postgres_hosts:
      hosts:
        vitellone:
          ansible_host: "your-host"
          ansible_user: "your-user"
    rabbitmq_hosts:
      hosts:
        vitellone:
          ansible_host: "your-host"
          ansible_user: "your-user"
    prometheus_hosts:
      hosts:
        vitellone:
          ansible_host: "your-host"
          ansible_user: "your-user"
```

The following files are expected:


```
ca.key
ca.crt
rabbitmq.key
rabbitmq.crt
agents_vitellone.key
agents_vitellone.crt
agents_vitelltwo.key
agents_vitelltwo.crt
trento_server_vitellone.key
trento_server_vitellone.crt
```

Furthermore, as the certificates are not meant to be used by other applications than the ones composing Trento, the playbook can generate the certificate itself, so that the user doesn't have to provide them.

The following are the variables to customize the process:

| Name                | Description                                                                                                                                       | Default                   |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------- |
| generate_certs      | If true, the playbook will generate all the needed certificates                                                                                   | true                      |
| generated_certs_dir | The directory for the certificates in the control node. It will be created if does not exist. It's unlikely that the user needs to set this value | /tmp/trento-ansible/certs |
