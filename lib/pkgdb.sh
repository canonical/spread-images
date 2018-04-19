#!/bin/bash

distro_install_google_sdk() {
    case "$SPREAD_SYSTEM" in
        ubuntu-*|debian-*)
            CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
            export CLOUD_SDK_REPO
            echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
            curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
            sudo apt-get update && sudo apt-get install -y google-cloud-sdk
            ;;
        fedora-*)
            if ! [ -f /etc/yum.repos.d/google-cloud.repo ]; then
                cat >> /etc/yum.repos.d/google-cloud.repo <<-EOF
[google-cloud-compute]
name=Google Cloud Compute
baseurl=https://packages.cloud.google.com/yum/repos/google-cloud-compute-el7-x86_64
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
            zypper install -y google-cloud-sdk
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
        amazon-*)
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
            apt-get remove -y --purge -y "$@"
            ;;
        fedora-*)
            dnf -y remove "$@"
            dnf clean all
            ;;
        opensuse-*)
            zypper remove -y "$@"
            ;;
        arch-*)
            pacman -Rnsc --noconfirm "$@"
            ;;
        amazon-*)
            yum -y remove "$@"
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
            dnf clean all
            dnf makecache
            ;;
        opensuse-*)
            zypper --gpg-auto-import-keys refresh
            ;;
        arch-*)
            pacman -Syq
            ;;
        amazon-*)
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
            echo "so far not needed"
            ;;
        fedora-*)
            echo "so far not needed"
            ;;
        opensuse-*)
            echo "so far not needed"
            ;;
        arch-*)
            pacman --needed --noconfirm -Syu
            ;;
        amazon-*)
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
        amazon-*)
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
        amazon-*)
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
        jq
        qemu-utils
        unzip
        "
}

pkg_dependencies_fedora(){
    echo "
        jq
        wget
        "
}

pkg_dependencies_opensuse(){
    echo "
        jq
        "
}

pkg_dependencies_arch(){
    echo "
        jq
        python2
        unzip
        wget
        "
}

pkg_dependencies_amazon(){
    echo "
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
        *)
            ;;
    esac
}

install_pkg_dependencies(){
    pkgs=$(pkg_dependencies)
    distro_install_package "$pkgs"
    distro_install_google_sdk
}
