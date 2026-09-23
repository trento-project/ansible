This example portrays a configuration where only Trento components,
server and agents, are deployed with configuration pointing to
external services outside of the scope of this playbook. In this
deployment:

 - `vitellone` is the hostname where Trento server gets deployed
 - `hana01` and `hana02` are hosts where Trento agents get installed

To prevent Trento from provisioning internal services, the following flags can be configured (they default to `true`):

```yaml
provision_postgres: false
provision_rabbitmq: false
provision_prometheus: false
provision_proxy: false
```
