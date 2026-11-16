#!/bin/bash

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
            dnf distro-sync --nogpgcheck -y
            ;;
        opensuse-*)
            # --gpg-auto-import-keys picks up rotated signing keys from repo-update
            # before packages are verified, otherwise a stale image cannot upgrade.
            zypper --gpg-auto-import-keys dup -y --force-resolution --no-recommends --replacefiles
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

# openSUSE repository base, https://mirrors.opensuse.org. Defaults to the
# canonical server; override with a mirror when the infrastructure can only
# reach one. The mirror must also serve current signing keys, otherwise an
# image older than a key rotation cannot be upgraded.
TUMBLEWEED_MIRROR="${TUMBLEWEED_MIRROR:-http://download.opensuse.org}"

_tumbleweed_set_repo() {
    local repo="$1" url="$2"
    zypper -q rr "$repo" 2>/dev/null || true
    zypper -q ar -f "$url" "$repo"
}

distro_tumbleweed_update() {
    local snapshot
    snapshot="$(curl --fail --silent -L "$TUMBLEWEED_MIRROR/history/latest" || true)"
    if [ -z "$snapshot" ]; then
        echo "ERROR: cannot determine latest Tumbleweed snapshot from $TUMBLEWEED_MIRROR"
        exit 1
    fi
    echo "Pinning Tumbleweed repos to snapshot $snapshot from $TUMBLEWEED_MIRROR"

    # libzypp expands $snapshotVersion from this drop-in, so stepping the
    # snapshot is a single write and the repo URLs never change.
    mkdir -p /etc/zypp/vars.d
    printf '%s\n' "$snapshot" > /etc/zypp/vars.d/snapshotVersion

    # Only the main repos are archived per snapshot.
    _tumbleweed_set_repo repo-oss \
        "$TUMBLEWEED_MIRROR/history/\$snapshotVersion/tumbleweed/repo/oss/"
    _tumbleweed_set_repo repo-non-oss \
        "$TUMBLEWEED_MIRROR/history/\$snapshotVersion/tumbleweed/repo/non-oss/"
    # The update repo has no snapshot history and carries the signing key
    # rotations, so it stays on the mirror's floating path.
    _tumbleweed_set_repo repo-update "$TUMBLEWEED_MIRROR/update/tumbleweed/"
    # Not mirrored and not needed by the tests.
    zypper -q mr -d repo-openh264 2>/dev/null || true

    zypper -q clean --all
    # Pick up rotated signing keys from the update repo before upgrading.
    zypper --gpg-auto-import-keys refresh || true
    distro_upgrade_packages
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
        xdelta3
        "
    case "$SPREAD_SYSTEM" in
        ubuntu-16.04-64*)
            echo "
                qemu-utils
                "
            ;;
        debian-*)
            echo "
                eatmydata
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
    case "$SPREAD_SYSTEM" in
        opensuse-15*)
            echo "
                python311
                "
            ;;
    esac
}

pkg_dependencies_arch(){
    echo "
        git
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
                retry
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
