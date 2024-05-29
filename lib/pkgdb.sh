#!/bin/bash

distro_install_google_sdk() {
    case "$SPREAD_SYSTEM" in
        ubuntu-*|debian-*)
            if ! command -v gcloud; then
                echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
                curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
                apt update && apt install -y google-cloud-sdk
            fi            
            ;;
        fedora-*)
            rm -rf /etc/yum.repos.d/google-cloud*.repo
            tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
            if [ -z "${CLOUDSDK_PYTHON:-}" ]; then
                CURR_PYTHON="$(readlink $(which python3))"
                # TODO: remove this when python3.10 works with gcloud command
                # + gcloud auth activate-service-account --key-file=/root/spread/sa.json
                # ERROR: gcloud failed to load: module 'collections' has no attribute 'Mapping'
                if [ "$CURR_PYTHON" = "python3.10" ]; then
                    dnf install -y python3.9
                    echo "CLOUDSDK_PYTHON=python3.9" >> /etc/environment
                    export CLOUDSDK_PYTHON="python3.9"
                else
                    echo "CLOUDSDK_PYTHON=$CURR_PYTHON" >> /etc/environment
                    export CLOUDSDK_PYTHON="$CURR_PYTHON"
                fi
                
            fi
            dnf makecache
            dnf install -y google-cloud-cli
            rm -f /etc/yum.repos.d/google-cloud-sdk.repo
            ;;
        opensuse-*)
            if [ ! -d /usr/share/google ]; then
                zypper remove -y google-cloud-sdk || true
                mkdir -p /usr/share/google
                wget https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.zip
                unzip google-cloud-sdk.zip -d /usr/share/google
                rm -f google-cloud-sdk.zip
                echo "export y=/usr/bin/python3" >> /etc/bash.bashrc
                /usr/share/google/google-cloud-sdk/install.sh --usage-reporting false --bash-completion true --disable-installation-options --rc-path /etc/bash.bashrc --path-update true
                ln -s /usr/share/google/google-cloud-sdk/bin/gcloud /usr/bin/gcloud
                ln -s /usr/share/google/google-cloud-sdk/bin/gcutil /usr/bin/gcutil
                ln -s /usr/share/google/google-cloud-sdk/bin/gsutil /usr/bin/gsutil
            fi
            ;;
        arch-*|amazon-*)
            if ! [ -d /usr/share/google/google-cloud-sdk ]; then
                curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-472.0.0-linux-x86_64.tar.gz
                tar -xf google-cloud-cli-472.0.0-linux-x86_64.tar.gz
                ./google-cloud-sdk/install.sh -q
            fi
            ;;
        centos-*)
            rm -rf /etc/yum.repos.d/google-cloud*.repo
            tee /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
            yum -y install google-cloud-sdk
            rm -f /etc/yum.repos.d/google-cloud-sdk.repo
            ;;
        *)
            echo "ERROR: Unsupported distribution $SPREAD_SYSTEM"
            exit 1
            ;;
    esac
}

distro_remove_google_sdk() {
    case "$SPREAD_SYSTEM" in
        ubuntu-*|debian-*)
            distro_purge_package google-cloud-sdk
            ;;
        fedora-*)
            distro_purge_package google-cloud-sdk
            ;;
        opensuse-*)
            echo "Not required yet"
            ;;
        arch-*|amazon-*)
            echo "Not required yet"
            ;;
        centos-*)
            distro_purge_package google-cloud-sdk
            ;;
        *)
            echo "ERROR: Unsupported distribution $SPREAD_SYSTEM"
            exit 1
            ;;
    esac
}

distro_reinstall_google_sdk() {
    distro_remove_google_sdk
    # Clean repository
    case "$SPREAD_SYSTEM" in
        ubuntu-*|debian-*)
            rm -f /etc/apt/sources.list.d/google-cloud*.list
            ;;
        fedora-*)
            rm -f /etc/yum.repos.d/google-cloud*.repo
            ;;
        opensuse-*)
            rm -rf /usr/share/google
            ;;
        arch-*|amazon-*)
            rm -rf /usr/share/google/google-cloud-sdk
            ;;
        centos-*)
            rm -f /etc/yum.repos.d/google-cloud*.repo
            ;;
        *)
            echo "ERROR: Unsupported distribution $SPREAD_SYSTEM"
            exit 1
            ;;
    esac
    distro_install_package google-cloud-sdk
    gcloud auth activate-service-account --key-file="$PROJECT_PATH/sa.json"
}

clean_google_services() {
    echo "Cleaning google services already running in the system"
    services="$(ls /usr/lib/systemd/system/google-*.service)" || return
    for service in $services; do
        systemctl stop "$service" || true
        systemctl disable "$service" || true
        rm -f "/etc/systemd/system/$service"
        systemctl daemon-reload
    done
}

distro_install_google_compute_engine() {
    case "$SPREAD_SYSTEM" in
        ubuntu-*|debian-*)
            distro_install_package google-compute-engine
            ;;
        fedora-*)
            distro_install_package google-compute-engine
            ;;
        opensuse-*)
            echo "Not required yet"
            ;;
        arch-*)
            clean_google_services

            distro_purge_package gce-compute-image-packages

            if ! id user >/dev/null 2>&1; then
                useradd -m user
            fi
            su -c 'cd /tmp && curl https://aur.archlinux.org/cgit/aur.git/snapshot/google-compute-engine.tar.gz | tar zxvf - && cd google-compute-engine && makepkg --syncdeps --noconfirm' - user
            pkgfiles=$(find /tmp/google-compute-engine -name '*.pkg.tar.xz')
            for pkg in $pkgfiles; do
                pacman -U --noconfirm "$pkg"
            done
            rm -rf /tmp/google-compute-engine

            services="$(ls /usr/lib/systemd/system/google-*.service)"
            for service in $services; do
                systemctl enable "$service"
            done
            ;;
        amazon-*|centos-*)
            echo "Not required yet"
            ;;
        *)
            echo "ERROR: Unsupported distribution $SPREAD_SYSTEM"
            exit 1
            ;;
    esac
}

distro_clean_old_packages() {
    # Clean all the packages but the newest one
    local pkg_filter=$1
    local pkgs pkgs_array
    case "$SPREAD_SYSTEM" in
        ubuntu-*|debian-*)
            echo "Not implemented for ubuntu/debian yet"
            exit 1
            ;;
        fedora-*|opensuse-*|arch-*|amazon-*|centos-*)
            pkgs=$(rpm -qa "$pkg_filter" --last | awk '{print $1}')
            ;;
    esac

    if [ "$(echo "$pkgs" | wc -w)" -gt 1 ]; then
        pkgs_list=$(echo $pkgs | cut -d' ' -f2-)
        for pkg in $pkgs_list; do
            distro_purge_package "$pkg"
        done
    fi
}

distro_install_package() {
    # Parse additional arguments; once we find the first unknown
    # part we break argument parsing and process all further
    # arguments as package names.
    APT_FLAGS=
    DNF_FLAGS=
    ZYPPER_FLAGS=
    while [ -n "$1" ]; do
        case "$1" in
            --no-install-recommends)
                APT_FLAGS="$APT_FLAGS --no-install-recommends"
                DNF_FLAGS="$DNF_FLAGS --setopt=install_weak_deps=False"
                ZYPPER_FLAGS="$ZYPPER_FLAGS --no-recommends"
                shift
                ;;
            *)
                break
                ;;
        esac
    done

    pkg_names=($(
        for pkg in "$@" ; do
            echo "$pkg"
        done
    ))

    case "$SPREAD_SYSTEM" in
        ubuntu-*|debian-*)
            # shellcheck disable=SC2086
            apt install $APT_FLAGS -y "${pkg_names[@]}"
            ;;
        fedora-*)
            # shellcheck disable=SC2086
            dnf -y --refresh --nogpgcheck install $DNF_FLAGS "${pkg_names[@]}"
            ;;
        opensuse-*)
            # shellcheck disable=SC2086
            zypper --gpg-auto-import-keys install -y --force-resolution $ZYPPER_FLAGS "${pkg_names[@]}"
            ;;
        arch-*)
            # shellcheck disable=SC2086
            pacman -S --needed --noconfirm "${pkg_names[@]}"
            ;;
        amazon-*|centos-*)
            # shellcheck disable=SC2086
            yum -y --nogpgcheck install $DNF_FLAGS "${pkg_names[@]}"
            ;;
        *)
            echo "ERROR: Unsupported distribution $SPREAD_SYSTEM"
            exit 1
            ;;
    esac
}

distro_purge_package() {
    case "$SPREAD_SYSTEM" in
        ubuntu-*|debian-*)
            apt remove -y --purge "$@" || true
            ;;
        fedora-*)
            dnf -y remove "$@" || true
            dnf clean all
            ;;
        opensuse-*)
            zypper remove -y "$@" || true
            ;;
        arch-*)
            pacman -Rnsc --noconfirm "$@" || true
            ;;
        amazon-*|centos-*)
            yum -y remove "$@" || true
            yum clean all
            ;;
        *)
            echo "ERROR: Unsupported distribution $SPREAD_SYSTEM"
            exit 1
            ;;
    esac
}

distro_update_package_db() {
    case "$SPREAD_SYSTEM" in
        ubuntu-*|debian-*)
            apt update
            ;;
        fedora-*)
            # Delete google repository because it is not needed any more
            rm -f /etc/yum.repos.d/google-cloud.repo
            # Clean and update repo
            dnf clean all
            dnf makecache
            ;;
        opensuse-*)
            zypper -q clean --all
            zypper refresh
            ;;
        arch-*)
            pacman -Syy
            ;;
        amazon-*|centos-*)
            # Delete google repository because it is not needed any more
            rm -f /etc/yum.repos.d/google-cloud.repo
            yum clean all
            yum --nogpgcheck makecache
            ;;
        *)
            echo "ERROR: Unsupported distribution $SPREAD_SYSTEM"
            exit 1
            ;;
    esac
}

distro_upgrade_packages() {
    case "$SPREAD_SYSTEM" in
        ubuntu-*|debian-*)
            apt upgrade -y
            ;;
        fedora-*)
            dnf upgrade --nogpgcheck -y
            ;;
        opensuse-*)
            zypper dup -y --force-resolution --no-recommends --replacefiles
            zypper dist-upgrade -y
            ;;
        arch-*)
            pacman --needed --noconfirm -Syu
            ;;
        amazon-*|centos-*)
            yum update -y --skip-broken
            ;;
        *)
            echo "ERROR: Unsupported distribution $SPREAD_SYSTEM"
            exit 1
            ;;
    esac
}

distro_clean_package_cache() {
    case "$SPREAD_SYSTEM" in
        ubuntu-14.04*)
            apt-get clean
            ;;
        ubuntu-*|debian-*)
            apt clean
            ;;
        fedora-*)
            dnf clean all
            ;;
        opensuse-*)
            zypper -q clean --all
            ;;
        arch-*)
            pacman -Sccq --noconfirm
            ;;
        amazon-*|centos-*)
            yum clean all
            ;;
        *)
            echo "ERROR: Unsupported distribution $SPREAD_SYSTEM"
            exit 1
            ;;
    esac
}

distro_auto_remove_packages() {
    case "$SPREAD_SYSTEM" in
        ubuntu-14.04*)
            apt-get -y autoremove
            ;;
        ubuntu-*|debian-*)
            apt -y autoremove
            ;;
        amazon-*|centos-7-*)
            yum -y autoremove
            ;;
        fedora-*|centos-*)
            dnf -y autoremove
            ;;
        opensuse-*)
            ;;
        arch-*)            
            if pacman -Qdtq; then
                pacman -Rnsc --noconfirm $(pacman -Qdtq | tr '\n' ' ')
            fi
            ;;
        *)
            echo "ERROR: Unsupported distribution '$SPREAD_SYSTEM'"
            exit 1
            ;;
    esac
}

pkg_dependencies_ubuntu(){
    echo "
        git
        jq
        unzip
        "
    case "$SPREAD_SYSTEM" in
        ubuntu-16.04-64*)
            echo "
                qemu-utils
                "
            ;;
    esac
}

pkg_dependencies_fedora(){
    echo "
        git
        jq
        xdelta
        wget
        "
}

pkg_dependencies_opensuse(){
    echo "
        git
        jq
        rpm-build
        unzip
        "
}

pkg_dependencies_arch(){
    echo "
        xdelta3
        "
}

pkg_dependencies_amazon(){
    echo "
        dbus
        git
        jq
        wget
        "
}

pkg_dependencies_centos(){
    echo "
        git
        jq
        libffi-devel
        wget
        "
}

pkg_dependencies(){
    case "$SPREAD_SYSTEM" in
        ubuntu-*|debian-*)
            pkg_dependencies_ubuntu
            ;;
        fedora-*)
            pkg_dependencies_fedora
            ;;
        opensuse-*)
            pkg_dependencies_opensuse
            ;;
        arch-*)
            pkg_dependencies_arch
            ;;
        amazon-*)
            pkg_dependencies_amazon
            ;;
        centos-*)
            pkg_dependencies_centos
            ;;
        *)
            ;;
    esac
}

pkg_blacklist(){
    case "$SPREAD_SYSTEM" in
        ubuntu-*|debian-*)
            echo "
                lxd
            "
            ;;
        fedora-*)
            ;;
        opensuse-*)
            ;;
        arch-*)
            ;;
        amazon-*)
            ;;
        centos-*)
            ;;
        *)
            ;;
    esac
}

distro_initial_repo_setup(){
    case "$SPREAD_SYSTEM" in
        ubuntu-*|debian-*)
            ;;
        fedora-*)
            ;;
        opensuse-*)
            zypper mr -d repo-debug-update || true
            zypper mr -d repo-sle-update || true
            zypper mr -d Cloud_Tools || true

            ;;
        arch-*)
            # Delete the key wich is failing checking packages integrity
            # pacman-key --list-keys levente@leventepolyak.net
            # pacman-key --delete E240B57E2C4630BA768E2F26FC1B547C8D8172C8
            ;;
        amazon-*)
            ;;
        centos-*)
            rm -rf /etc/yum.repos.d/google-cloud*.repo
            ;;
        *)
            ;;
    esac
}

install_pkg_dependencies(){
    pkgs=$(pkg_dependencies)
    if [ ! -z "$pkgs" ]; then
        distro_install_package "$pkgs"
    fi
    if [ "$SPREAD_BACKEND" = google ]; then
        if ! command -v gcloud >/dev/null; then
            distro_install_google_sdk
        fi
    fi
}

install_test_dependencies(){
    local TARGET="$1"
    git clone https://github.com/snapcore/snapd.git snapd-master
    cp -r snapd-master/tests/lib/external/snapd-testing-tools/tools/* snapd-master/tests/lib/tools/
    (
        export TESTSLIB="$(pwd)"/snapd-master/tests/lib
        export PATH=$PATH:"$(pwd)"/snapd-master/tests/bin
        export SPREAD_SYSTEM="$TARGET"

        . snapd-master/tests/lib/pkgdb.sh
        install_pkg_dependencies
    )
    rm -rf snapd-master
}

remove_pkg_blacklist(){
    pkgs=$(pkg_blacklist)
    if [ ! -z "$pkgs" ]; then
        distro_purge_package "$pkgs"
    fi
}
