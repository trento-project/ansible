# Changelog

## 1.0.1 - 2026-09-10

### What's Changed

* Fix typos (#130) @antgamdia
* Make Prometheus port configurable (#122) @vicenteqa
* Add SLES16 CI target (#124) @vicenteqa
* Cancel stale CI runs (#123) @vicenteqa, @Copilot
* Remove constraints so supportutils can be installed on 15.4 too (#120) @vicenteqa
* Remove SLES15 SP3 checks from the CI (#121) @vicenteqa
* [TRNT-4358] Add license headers (#118) @antgamdia
* [TRNT-4358] Update LICENSE to match Apache-2.0 verbatim text (#117) @antgamdia
* Switch CI to common workflows (#114) @skrech
* [TRNT-4330] Add Dependabot configuration (#108) @antgamdia
* [TRNT-4317] Pin GHA to SHA instead of tags (#107) @antgamdia
* Rename 'Usage with Vagrant' to 'Local Development Environment' (#104) @EMaksy
* Add basic auth to prometheus web write endpoint (#102) @balanza, Emanuele De Cupis
* Add missing python3 module doc (#95) @nelsonkopliku
* Add missing directory mode (#94) @nelsonkopliku

#### Features

* Use fallback Prometheus port in SLES 16 (#134) @antgamdia
* Add Web and Wanda LOG_LEVEL usage (#135) @arbulu89
* Add support plugin for trento server (#106) @EMaksy
* CI releases use signed commits (#103) @skrech
* variable prometheus upstream in reverse proxy (#101) @nelsonkopliku
* Prometheus ssl termination (#99) @nelsonkopliku, @arbulu89
* Configure Alloy (#97) @nelsonkopliku
* Provide server CA certs to agents (#96) @nelsonkopliku
* Install monitoring dependencies on agents (#93) @nelsonkopliku
* Allow Enabling/Disabling prometheus remote write receiver (#92) @nelsonkopliku, @Copilot

#### Bug Fixes

* Create Prometheus tmpfiles before service startup (#127) @vicenteqa

#### Maintenance

* Enable backport (#137) @skrech
* Use "trento-checks" img (#133) @antgamdia
* Allow hotfix releases in the pipeline (#100) @skrech

#### Dependencies

<details>
<summary>7 changes</summary>
* Bump the common-workflows group with 3 updates (#138) [@dependabot[bot]](https://github.com/apps/dependabot)
* Bump ansible/ansible-lint from 26.4.0 to 26.6.0 (#128) [@dependabot[bot]](https://github.com/apps/dependabot)
* Bump actions/checkout from 6.0.3 to 7.0.1 (#129) [@dependabot[bot]](https://github.com/apps/dependabot)
* Bump actions/checkout from 6.0.2 to 6.0.3 (#125) [@dependabot[bot]](https://github.com/apps/dependabot)
* Bump dawidd6/action-ansible-playbook from 2.8.0 to 9 (#110) [@dependabot[bot]](https://github.com/apps/dependabot)
* Bump ansible/ansible-lint from 25.12.2 to 26.4.0 (#115) [@dependabot[bot]](https://github.com/apps/dependabot)
* Bump the common-workflows group across 1 directory with 3 updates (#119) [@dependabot[bot]](https://github.com/apps/dependabot)

</details>
**Full Changelog**: https://github.com/trento-project/ansible/compare/1.0.0...1.0.1

## 1.0.0 - 2026-01-30

### What's Changed

* Initial release (#91) @skrech

**Full Changelog**: https://github.com/trento-project/ansible/compare/0.9.9...1.0.0
