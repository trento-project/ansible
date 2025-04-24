This example portrays a single-node configuration, where all nodes are deployed on the same machine. In this deployment:
 - `vitellone` is the hostname where `trento_server` gets deployed

Agent nodes are *not* deployed with this configuration.

Two variants are available:
 - vars-with-alerting.json: In this example, we set up alerting and set the SMTP configuration. Alerts should arrive at the
   provided email.
 - vars.json: No alerting enabled.