#!/bin/bash
# combustion: network

# --- Vagrant base-box setup
# Customize as Vagrant Base Box according to:
# https://developer.hashicorp.com/vagrant/docs/boxes/base

# Create 'vagrant' user and make it sudoer
useradd -m vagrant

# Set passwords for the system users
echo -e 'root:vagrant\nvagrant:vagrant' | chpasswd

# Allow the Vagrant insecure key
vagrant_ssh_dir=~vagrant/.ssh
mkdir "${vagrant_ssh_dir}"
chown vagrant:users "${vagrant_ssh_dir}"
chmod 0700 "${vagrant_ssh_dir}"

echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp\
22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9q\
gCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7Ptix\
WKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnD\
kbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jl\
qm8tehUc9c9WhQ== vagrant insecure public key" > "${vagrant_ssh_dir}/authorized_keys"
chown vagrant:users "${vagrant_ssh_dir}"/authorized_keys
chmod 0600 "${vagrant_ssh_dir}"/authorized_keys

# Add 'vagrant' user as sudoer without asking for password. It's
# Vagrant requirement according to: #
# https://developer.hashicorp.com/vagrant/docs/boxes/base
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant

# --- SLES-specific

# Set the timezone
systemd-firstboot --force --timezone=UTC

# Configure net interfaces
cat > /etc/sysconfig/network/ifcfg-eth0 <<-EOF
STARTMODE='auto'
BOOTPROTO='dhcp'
ZONE='public'
EOF

# --- Convert to SLES4SAP which will also register it

# Set some constants
ARCH=$(uname -m)
SLE_VERSION=$(sed -n 's/^VERSION_ID="\(.*\)"$/\1/p' /etc/os-release)
SLES_SAP_MODULES="SLES_SAP sle-module-basesystem \
                           sle-module-desktop-applications \
                           sle-module-server-applications \
                           sle-ha sle-module-sap-applications"

# We need to remove the sles-release package so no conflicts
# when registering SLES_SAP
rpm --erase --nodeps sles-release

register() {
    if [[ "$1" == *"module"* ]]; then
        SUSEConnect -p "$1/${SLE_VERSION}/${ARCH}"
    else
        SUSEConnect -p "$1/${SLE_VERSION}/${ARCH}" -r $TRENTO_VAGRANT_REGCODE
    fi
}

for product in $SLES_SAP_MODULES; do
    register "$product"
done

# Install SLES_SAP default packages
zypper -n install --auto-agree-with-licenses -f patterns-server-enterprise-sap_server

# --- Enable optinal SUSE modules
# Note: This section should ideally be handled in our ansible
# playbook. However, for now, we'll configure it here.
SLES_OPTIONAL_MODULES="PackageHub sle-module-containers"
if [ "$SLE_VERSION" != "15.3" ]; then
   SLES_OPTIONAL_MODULES="sle-module-python3 ${SLES_OPTIONAL_MODULES}"
fi

for  product in $SLES_OPTIONAL_MODULES; do
    register "$product"
done
