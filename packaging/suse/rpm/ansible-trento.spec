#
# spec file for package ansible-trento
#
# Copyright (c) 2025 SUSE LLC
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via https://bugs.opensuse.org/\


%define collection_ns suse
%define collection_name trento

Name:           ansible-trento
Version:        0.0.0
Release:        0
Summary:        Collection of Ansible roles and playbooks for setting up Trento
Group:          Development/Tools/Other
License:        Apache-2.0
URL:            https://github.com/trento-project/ansible

Source0:        %{name}-%{version}.tar.gz
Source1:        galaxy.yml
Source2:        README.adoc

BuildArch:      noarch

BuildRequires:  ansible-core >= 2.16
BuildRequires:  ansible >= 9
# Needed by ansible-galaxy for manifest.in directives handling (used
# in galaxy.yml)
BuildRequires:  %{modern_python}-distlib

Requires:       ansible-core >= 2.16
Requires:       ansible >= 9

%description
Collection of Ansible roles and playbooks for deploying and managing
Trento.

%prep
%setup

# Copy `galaxy.yml` to the root of the collection
cp %{SOURCE1} .
sed -i '/^version:/s/".*"/"%{version}"/' ./galaxy.yml

mkdir ./playbooks/
mv site.yml server.yml agent.yml cleanup.yml group_vars ./playbooks/

# Move out developer docs, won't be packaged
mkdir ./docs_unused/
mv ./docs/* ./docs_unused

# Move playbooks README into `docs/`
mv ./README.adoc ./docs/README-trento.adoc

# Move in the newly written collection README
cp %{SOURCE2} .

%build
ansible-galaxy collection build

%install
mkdir -p %{buildroot}%{_datadir}/ansible/collections
ansible-galaxy collection install %{collection_ns}-%{collection_name}-%{version}.tar.gz \
  --no-deps --collections-path %{buildroot}%{_datadir}/ansible/collections

%files
%{_datadir}/ansible/collections

%changelog
