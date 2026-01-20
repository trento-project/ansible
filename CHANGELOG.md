# Changelog

## [1.0.1](https://github.com/trento-project/ansible/tree/1.0.1) (2024-06-10)

[Full Changelog](https://github.com/trento-project/ansible/compare/1.0.0...1.0.1)

**Closed issues:**

- Remove RUNNER_URL [#1](https://github.com/trento-project/ansible/issues/1)

**Merged pull requests:**

- Rename `TRENTO_DOMAIN` to `TRENTO_WEB_ORIGIN` [#37](https://github.com/trento-project/ansible/pull/37) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Make use of the new TRENTO_DOMAIN env var required for WSS [#36](https://github.com/trento-project/ansible/pull/36) ([rtorrero](https://github.com/rtorrero))

## [1.0.0](https://github.com/trento-project/ansible/tree/1.0.0) (2024-05-13)

**Implemented enhancements:**

- Add RPM installation [#30](https://github.com/trento-project/ansible/pull/30) ([rtorrero](https://github.com/rtorrero))
- Add checks v3 path to proxy redirection [#29](https://github.com/trento-project/ansible/pull/29) ([arbulu89](https://github.com/arbulu89))
- Add Apache license [#26](https://github.com/trento-project/ansible/pull/26) ([EMaksy](https://github.com/EMaksy))
- Improve log message for verify alerting env's step [#25](https://github.com/trento-project/ansible/pull/25) ([EMaksy](https://github.com/EMaksy))
- Enable alerting [#24](https://github.com/trento-project/ansible/pull/24) ([EMaksy](https://github.com/EMaksy))
- Upload current code tarball to releases [#13](https://github.com/trento-project/ansible/pull/13) ([arbulu89](https://github.com/arbulu89))
- Bring ansible installation on par with manual installation [#12](https://github.com/trento-project/ansible/pull/12) ([rtorrero](https://github.com/rtorrero))
- Enable wanda v2 apis [#11](https://github.com/trento-project/ansible/pull/11) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Agent installation [#2](https://github.com/trento-project/ansible/pull/2) ([arbulu89](https://github.com/arbulu89))

**Fixed bugs:**

- Fix container secrets random generation [#28](https://github.com/trento-project/ansible/pull/28) ([arbulu89](https://github.com/arbulu89))
- Fix nginx_vhost_filename and rabbitmq_vhost usage [#27](https://github.com/trento-project/ansible/pull/27) ([arbulu89](https://github.com/arbulu89))
- Fix default secret key rendering [#23](https://github.com/trento-project/ansible/pull/23) ([arbulu89](https://github.com/arbulu89))

**Merged pull requests:**

- Add RPM tests for SP3, SP4, SP5 [#33](https://github.com/trento-project/ansible/pull/33) ([rtorrero](https://github.com/rtorrero))
- Workaround to allow installation with newer ncurses [#32](https://github.com/trento-project/ansible/pull/32) ([rtorrero](https://github.com/rtorrero))
- Improve general docs [#31](https://github.com/trento-project/ansible/pull/31) ([rtorrero](https://github.com/rtorrero))
- Temporary HTTPS Fix  [#22](https://github.com/trento-project/ansible/pull/22) ([CDimonaco](https://github.com/CDimonaco))
- Update playbook usage and docs [#21](https://github.com/trento-project/ansible/pull/21) ([CDimonaco](https://github.com/CDimonaco))
- Support for ssl key/cert as base64 string [#20](https://github.com/trento-project/ansible/pull/20) ([CDimonaco](https://github.com/CDimonaco))
- Add prometheus config step [#19](https://github.com/trento-project/ansible/pull/19) ([rtorrero](https://github.com/rtorrero))
- Only apply firewalld exceptions when firewalld is running [#18](https://github.com/trento-project/ansible/pull/18) ([rtorrero](https://github.com/rtorrero))
- Allow charts to be optional when deploying trento-web [#17](https://github.com/trento-project/ansible/pull/17) ([rtorrero](https://github.com/rtorrero))
- Add indent rule yamllint [#16](https://github.com/trento-project/ansible/pull/16) ([rtorrero](https://github.com/rtorrero))
- Add distribution detection logic [#15](https://github.com/trento-project/ansible/pull/15) ([rtorrero](https://github.com/rtorrero))
- Remove grafana installation and configuration [#14](https://github.com/trento-project/ansible/pull/14) ([arbulu89](https://github.com/arbulu89))
- Add nginx custom upstream name with a default [#10](https://github.com/trento-project/ansible/pull/10) ([CDimonaco](https://github.com/CDimonaco))
- Remove container images optionally during cleanup [#9](https://github.com/trento-project/ansible/pull/9) ([arbulu89](https://github.com/arbulu89))
- Nginx listen port configurable [#8](https://github.com/trento-project/ansible/pull/8) ([CDimonaco](https://github.com/CDimonaco))
- Containers role update [#7](https://github.com/trento-project/ansible/pull/7) ([CDimonaco](https://github.com/CDimonaco))
- Cleanup rabbitmq [#6](https://github.com/trento-project/ansible/pull/6) ([arbulu89](https://github.com/arbulu89))
- Cleanup postgres/nginx [#5](https://github.com/trento-project/ansible/pull/5) ([arbulu89](https://github.com/arbulu89))
- Cleanup trento containers [#4](https://github.com/trento-project/ansible/pull/4) ([arbulu89](https://github.com/arbulu89))
- Improve doc [#3](https://github.com/trento-project/ansible/pull/3) ([nelsonkopliku](https://github.com/nelsonkopliku))

* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
