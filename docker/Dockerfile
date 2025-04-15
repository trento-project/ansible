FROM opensuse/leap:15
LABEL org.opencontainers.image.source="https://github.com/trento-project/ansible"
LABEL org.opencontainers.image.authors="Carmine Di Monaco <carmine.dimonaco@suse.com>"
LABEL org.opencontainers.image.title="Trento Ansible"
LABEL org.opencontainers.image.description="Ansible playbok for trento infrastructure deploy"
WORKDIR /lib/trento-ansible
COPY roles .
COPY requirements.yml . 
COPY playbook.yml .
COPY docker/entrypoint.sh .
RUN zypper refresh && \
    zypper install -y ansible openssh-clients && \
    ansible-galaxy collection install -r requirements.yml 
ENTRYPOINT ["/lib/trento-ansible/entrypoint.sh"]