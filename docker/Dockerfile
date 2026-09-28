# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

ARG OS_VER=16.0
FROM registry.opensuse.org/opensuse/leap:${OS_VER}
ARG OS_VER
ARG VERSION=dev
# Define labels according to https://en.opensuse.org/Building_derived_containers
# labelprefix=com.suse.trento
LABEL org.opencontainers.image.authors="https://github.com/trento-project/ansible/graphs/contributors"
LABEL org.opencontainers.image.title="Trento Ansible"
LABEL org.opencontainers.image.description="Ansible playbook for Trento infrastructure deployment"
LABEL org.opencontainers.image.documentation="https://www.trento-project.io/docs/ansible/README.html"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.url="https://github.com/trento-project/ansible"
# LABEL org.opencontainers.image.created="" # Set by GHA, no need to set here
LABEL org.opencontainers.image.vendor="SUSE LLC"
LABEL org.opencontainers.image.source="https://github.com/trento-project/ansible"
LABEL org.opencontainers.image.ref.name="${OS_VER}-${VERSION}"
LABEL org.opensuse.reference="registry.opensuse.org/opensuse/leap:${OS_VER}"
LABEL org.openbuildservice.disturl="https://github.com/trento-project/ansible/pkgs/container/ansible"
# endlabelprefix
LABEL org.opencontainers.image.base.name="registry.opensuse.org/opensuse/leap:${OS_VER}"
LABEL org.opencontainers.image.base.digest="latest"
LABEL io.artifacthub.package.logo-url="https://www.trento-project.io/images/trento-icon.svg"
LABEL io.artifacthub.package.readme-url="https://raw.githubusercontent.com/trento-project/ansible/refs/heads/main/packaging/suse/container/README.md"

WORKDIR /lib/trento-ansible

COPY roles .
COPY requirements.yml .
COPY playbook.yml .
COPY docker/entrypoint.sh .

RUN set -euo pipefail; zypper refresh && \
    zypper install -y ansible ansible-linux-system-roles openssh-clients && \
    ansible-galaxy collection install -r requirements.yml

RUN set -euo pipefail; zypper -n clean -a; \
    rm -rf {/target,}/var/log/{alternatives.log,lastlog,tallylog,zypper.log,zypp/history,YaST2}; \
    rm -rf {/target,}/run/*; \
    rm -f {/target,}/etc/{shadow-,group-,passwd-,.pwd.lock}; \
    rm -f {/target,}/usr/lib/sysimage/rpm/.rpm.lock; \
    rm -f {/target,}/var/lib/zypp/AnonymousUniqueId; \
    rm -f {/target,}/var/lib/zypp/AutoInstalled; \
    rm -f {/target,}/var/cache/ldconfig/aux-cache

RUN set -euo pipefail; sed -i 's/^\([^:]*:[^:]*:\)[^:]*\(:.*\)$/\1\2/' /etc/shadow

ENTRYPOINT ["/lib/trento-ansible/entrypoint.sh"]
