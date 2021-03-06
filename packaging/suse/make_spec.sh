#!/bin/bash

if [ -z "$1" ]; then
  cat <<EOF
usage:
  ./make_spec.sh PACKAGE [BRANCH]
EOF
  exit 1
fi

cd $(dirname $0)

YEAR=$(date +%Y)
VERSION=$(cat ../../VERSION)
REVISION=$(git rev-list HEAD | wc -l)
COMMIT=$(git rev-parse --short HEAD)
VERSION="${VERSION%+*}+git_r${REVISION}_${COMMIT}"
NAME=$1
GITREPONAME=$(basename `git rev-parse --show-toplevel`)
BRANCH=${2:-master}
SAFE_BRANCH=${BRANCH//\//-}

cat <<EOF > ${NAME}.spec
#
# spec file for package $NAME
#
# Copyright (c) $YEAR SUSE LINUX GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

%if 0%{?is_opensuse} && 0%{?suse_version} > 1500
  %define _dist kubic
%else
  %define _dist caasp
%endif

Name:           $NAME
Version:        $VERSION
Release:        0
Summary:        Branding for $NAME
License:        Apache-2.0
Group:          Applications/Internet
Url:            https://github.com/kubic-project/$GITREPONAME
Source:         ${SAFE_BRANCH}.tar.gz
Provides:       $NAME = %{version}

ExcludeArch:    %ix86

%description
%{_dist} branding themes for velum

%prep
%setup -q -n ${GITREPONAME}-${SAFE_BRANCH}

%build
%install
# Install the web content
install -d -m 0755 %{buildroot}/%{_datadir}/velum
install -d -m 0755 %{buildroot}/%{_datadir}/velum/images
# set the product name
cp %{_dist}-%{name}/PRODUCT %{buildroot}/%{_datadir}/velum
# add different logos
cp -R %{_dist}-%{name}/app/assets/images/* %{buildroot}/%{_datadir}/velum/images

%files
%defattr(-,root,root)
%dir %{_datadir}/velum
%{_datadir}/velum/PRODUCT
%dir %{_datadir}/velum/images
%{_datadir}/velum/images/*

%if 0%{?suse_version} < 1500
%doc LICENSE
%else
%license LICENSE
%endif

%changelog
EOF
