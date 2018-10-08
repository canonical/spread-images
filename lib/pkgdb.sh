#!/bin/bash

distro_install_google_sdk() {
    case "$SPREAD_SYSTEM" in
        ubuntu-*|debian-*)
            if [ $(find /etc/apt/sources.list.d/google-cloud*.list | wc -l) -eq 0 ]; then
                CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
                export CLOUD_SDK_REPO
                echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
                curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
                apt-get update && apt-get install -y google-cloud-sdk
            fi
            ;;
        fedora-*)
            if [ $(find /etc/yum.repos.d/google-cloud*.repo | wc -l) -eq 0 ]; then
                cat >> /etc/yum.repos.d/google-cloud-sdk.repo <<-EOF
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
            fi
            dnf makecache
            dnf install -y google-cloud-sdk
            ;;
        opensuse-*)
            zypper remove -y google-cloud-sdk
            mkdir -p /usr/share/google
            wget https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.zip
            unzip google-cloud-sdk.zip -d /usr/share/google
            rm -f google-cloud-sdk.zip
            echo "export CLOUDSDK_PYTHON=/usr/bin/python2" >> /etc/bash.bashrc
            /usr/share/google/google-cloud-sdk/install.sh --usage-reporting false --bash-completion true --disable-installation-options --rc-path /etc/bash.bashrc --path-update true
            ln -s /usr/share/google/google-cloud-sdk/bin/gcloud /usr/bin/gcloud
            ln -s /usr/share/google/google-cloud-sdk/bin/gcutil /usr/bin/gcutil
            ln -s /usr/share/google/google-cloud-sdk/bin/gsutil /usr/bin/gsutil
            ;;
        arch-*|amazon-*)
            if ! [ -d /usr/share/google/google-cloud-sdk ]; then
                mkdir -p /usr/share/google
                wget https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.zip
                unzip google-cloud-sdk.zip -d /usr/share/google
                rm -f google-cloud-sdk.zip
                echo "export CLOUDSDK_PYTHON=/usr/bin/python2" >> /etc/bash.bashrc
                /usr/share/google/google-cloud-sdk/install.sh --usage-reporting false --bash-completion true --disable-installation-options --rc-path /etc/bash.bashrc --path-update true
                ln -s /usr/share/google/google-cloud-sdk/bin/gcloud /usr/bin/gcloud
                ln -s /usr/share/google/google-cloud-sdk/bin/gcutil /usr/bin/gcutil
                ln -s /usr/share/google/google-cloud-sdk/bin/gsutil /usr/bin/gsutil
            fi
            ;;
        centos-*)
            if [ $(find /etc/yum.repos.d/google-cloud*.repo | wc -l) -eq 0 ]; then
                sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
                yum -y install google-cloud-sdk
            fi
            ;;
        *)
            echo "ERROR: Unsupported distribution $SPREAD_SYSTEM"
            exit 1
            ;;
    esac
}

clean_google_service_units() {
    echo "Cleaning google service units already running in the system"
    units="$(cd /usr/lib/systemd/system && ls google-*.service)" || return
    for unit in $units; do
        clean_service_unit "$unit"
    done
}

clean_service_unit(){
    local unit=$1
    systemctl stop "$unit" || true
    systemctl disable "$unit" || true
    rm -f "/etc/systemd/system/$unit"
    rm -f "/usr/lib/systemd/system/$unit"
    systemctl daemon-reload
}

distro_install_google_compute_engine() {
    case "$SPREAD_SYSTEM" in
        ubuntu-*|debian-*)
            distro_install_package google-compute-engine
            ;;
        fedora-*)
            echo "Not required yet"
            ;;
        opensuse-*)
            echo "Not required yet"
            ;;
        arch-*)
            clean_google_service_units
            git clone https://github.com/GoogleCloudPlatform/compute-image-packages.git
            ( cd compute-image-packages && python setup.py install )
            mkdir -p /usr/lib/systemd/system
            for unit in compute-image-packages/google_compute_engine_init/systemd/*.service; do
                install -m644 "$unit" /usr/lib/systemd/system/
            done
            units="$(cd /usr/lib/systemd/system && ls google-*.service)" || return
            for unit in $units; do
                systemctl enable "$unit"
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
            apt-get install $APT_FLAGS -y "${pkg_names[@]}"
            ;;
        fedora-*)
            # shellcheck disable=SC2086
            dnf -y --refresh install $DNF_FLAGS "${pkg_names[@]}"
            ;;
        opensuse-*)
            # shellcheck disable=SC2086
            zypper --gpg-auto-import-keys install -y $ZYPPER_FLAGS "${pkg_names[@]}"
            ;;
        arch-*)
            # shellcheck disable=SC2086
            pacman -Suq --needed --noconfirm "${pkg_names[@]}"
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
    # shellcheck disable=SC2046
    set -- $(
        for pkg in "$@" ; do
            package_name=$(distro_name_package "$pkg")
            # When we could not find a different package name for the distribution
            # we're running on we try the package name given as last attempt
            if [ -z "$package_name" ]; then
                package_name="$pkg"
            fi
            echo "$package_name"
        done
        )

    case "$SPREAD_SYSTEM" in
        ubuntu-*|debian-*)
            apt-get remove -y --purge "$@" || true
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
            apt-get update
            ;;
        fedora-*)
            # Delete google repository because it is not needed any more
            rm -f /etc/yum.repos.d/google-cloud.repo
            # Clean and update repo
            dnf clean all
            dnf makecache
            ;;
        opensuse-*)
            zypper --gpg-auto-import-keys refresh
            ;;
        arch-*)
            pacman -Syq
            ;;
        amazon-*|centos-*)
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
            apt-get upgrade -y
            apt-get dist-upgrade -y
            ;;
        fedora-*)
            dnf upgrade -y
            ;;
        opensuse-*)
            echo "so far not needed"
            ;;
        arch-*)
            pacman --needed --noconfirm -Syu
            ;;
        amazon-*|centos-*)
            yum -y update
            ;;
        *)
            echo "ERROR: Unsupported distribution $SPREAD_SYSTEM"
            exit 1
            ;;
    esac
}

distro_clean_package_cache() {
    case "$SPREAD_SYSTEM" in
        ubuntu-*|debian-*)
            apt-get clean
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
        ubuntu-*|debian-*)
            apt-get -y autoremove
            ;;
        fedora-*)
            dnf -y autoremove
            ;;
        opensuse-*)
            ;;
        arch-*)
            pacman -Rnsc --noconfirm "$(pacman -Qdtq)"
            ;;
        amazon-*|centos-*)
            yum -y autoremove
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
    if [[ "$SPREAD_SYSTEM" == ubuntu-16.04-64 ]]; then
        echo "
            qemu-utils
            "
    fi
}

pkg_dependencies_fedora(){
    echo "
        git
        jq
        wget
        "
}

pkg_dependencies_opensuse(){
    echo "
        git
        jq
        "
}

pkg_dependencies_arch(){
    echo "
        git
        jq
        python2
        unzip
        wget
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

install_pkg_dependencies(){
    pkgs=$(pkg_dependencies)
    if [ ! -z "$pkgs" ]; then
        distro_install_package "$pkgs"
    fi
    distro_install_google_sdk
}

install_test_dependencies(){
    local TARGET="$1"
    git clone https://github.com/snapcore/snapd.git snapd-master
    TESTSLIB=./snapd-master/tests/lib . snapd-master/tests/lib/pkgdb.sh
    TESTSLIB=./snapd-master/tests/lib SPREAD_SYSTEM="$TARGET" install_pkg_dependencies
    rm -rf snapd-master
}

remove_pkg_blacklist(){
    pkgs=$(pkg_blacklist)
    if [ ! -z "$pkgs" ]; then
        distro_purge_package "$pkgs"
    fi
}
