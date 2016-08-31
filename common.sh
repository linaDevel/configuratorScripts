#!/bin/bash
# Error trapping first
#---------------------
set -o errexit

trap 'trap_handler ${?} ${LINENO} ${0}' ERR
trap 'exit_handler ${?}' EXIT
#---------------------

# Enable debug output
#--------------------
PS4='+ [$(date --rfc-3339=seconds)] '
set -o xtrace
#--------------------

# Constants
RUBY_TARBALL="https://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.9.tar.gz"

# Functions

function apt_wrapper() {
  sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" "$@"
}

function install_packages() {
  apt_wrapper install "$@"
}

function setup_dependencies() {
  apt_wrapper update
  install_packages python-pip python-dev python-virtualenv git libvirt-bin virt-manager qemu-system \
    python-compizconfig compizconfig-settings-manager compiz-plugins compiz-plugins-main
}

function setup_unity() {
  gsettings set org.gnome.desktop.background draw-background false
  gsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ panel-opacity 0.3
}

function install_ruby() {
  RUBY_BUILDDIR=$(mktemp -d)
  pushd ${RUBY_BUILDDIR}
  wget -O ruby.tar.gz "${RUBY_TARBALL}"
  tar xzf ruby.tar.fz

  mkdir -p /develop/ruby
  pushd $(basename $(find . -maxdepth 1 -type d -name 'ruby-*'))
  ./configure --prefix=/develop/ruby
  make
  make install
  popd

  echo 'export RUBY_PATH="/develop/ruby/bin"' >> ~/.profile
  popd
  rm -rf ${RUBY_BUILDDIR}
}

function setup_dev_environment() {
  sudo mkdir -p /develop
  sudo addgroup developer

  sudo adduser ${USER} developer
  sudo adduser root developer

  sudo chmod 775 -R /develop
  sudo chown -R ${USER}:developer

  mkdir /develop/git
  mkdir /develop/bin
  mkdir /develop/venvs

  git clone https://github.com/linaDevel/usefullScripts /develop/scripts

  ln -s /develop/scripts/tmpdir /develop/bin/tmpdir
  ln -s /develop/scripts/tmpclone /develop/bin/tmpclone
  ln -s /develop/scripts/compiz_helper.py /develop/bin/compiz_helper
  ln -s /develop/scripts/viewport_monitor.py /develop/bin/viewport_monitor

  chmod +x /develop/bin/*
  echo "PATH=${PATH}:/develop/bin" > /etc/environment

  virtualenv /develop/venvs/downburst
  /develop/venvs/downburst/bin/pip install git+https://github.com/linaDevel/downburst
  ln -s /develop/venvs/downburst/bin/downburst /develop/bin/downburst

  install_ruby
}

function setup_zsh() {
  install_packages zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}
