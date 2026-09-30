# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

ARG OS_VER=15.7
FROM registry.suse.com/bci/bci-base:${OS_VER}
ARG OS_VER
ARG VERSION=dev
# Ansible Core 2.18 matches Ansible 11, see https://docs.ansible.com/projects/ansible/latest/reference_appendices/release_and_maintenance.html#ansible-community-changelogs
ARG ANSIBLE_CORE_VERSION=2.18
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
LABEL org.opencontainers.image.base.name="registry.suse.com/bci/bci-base:${OS_VER}"
LABEL org.opencontainers.image.base.digest="latest"
LABEL io.artifacthub.package.logo-url="https://www.trento-project.io/images/trento-icon.svg"
LABEL io.artifacthub.package.readme-url="https://raw.githubusercontent.com/trento-project/ansible/refs/heads/main/README.adoc"

WORKDIR /lib/trento-ansible

# Add the project roles and collections directories to Ansible's default paths.
ENV ANSIBLE_ROLES_PATH=/lib/trento-ansible/roles:/usr/share/ansible/roles
ENV ANSIBLE_COLLECTIONS_PATH=/usr/share/ansible/collections

# Install necessary packages
RUN set -euo pipefail; \
    zypper refresh && \
    zypper install --no-recommends -y python311 python311-pip git openssh-clients shadow && \
    zypper -n clean -a

# Create the non-root runtime user
RUN set -euo pipefail; \
    groupadd --gid 1001 trento && \
    useradd --uid 1001 --gid trento --create-home --home-dir /home/trento --shell /bin/bash trento

# Install Ansible roles and collections
COPY requirements.yml .
RUN set -euo pipefail; \
    python3.11 -m pip install --disable-pip-version-check --no-cache-dir pipx && \
    pipx install --global --force "ansible-core~=${ANSIBLE_CORE_VERSION}.0" && \
    ansible-galaxy install -r requirements.yml

# Copy entrypoint script and Ansible roles, vars, and playbook
COPY --chown=trento:trento --chmod=0555 docker/entrypoint.sh .
COPY --chown=trento:trento roles ./roles
COPY --chown=trento:trento vars ./vars
COPY --chown=trento:trento site.yml playbook.yml
COPY --chown=trento:trento server.yml agent.yml ./

# Switch to the trento user
USER trento

ENTRYPOINT ["/lib/trento-ansible/entrypoint.sh"]
