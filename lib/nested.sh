#!/bin/bash

# shellcheck source=tests/lib/systemd.sh
. "$TESTSLIB"/systemd.sh

WORK_DIR=/home/ubuntu/work-dir
SSH_PORT=8022
MON_PORT=8888

wait_for_ssh(){
    retry=150
    while ! execute_remote true; do
        retry=$(( retry - 1 ))
        if [ $retry -le 0 ]; then
            echo "Timed out waiting for ssh. Aborting!"
            return 1
        fi
        sleep 1
    done
}

get_qemu_for_nested_vm(){
    case "$NESTED_ARCH" in
    amd64)
        command -v qemu-system-x86_64
        ;;
    i386)
        command -v qemu-system-i386
        ;;
    *)
        echo "unsupported architecture"
        exit 1
        ;;
    esac
}

get_image_url_for_nested_vm(){
    case "$NESTED_SYSTEM" in
    xenial|trusty)
        echo "https://cloud-images.ubuntu.com/${NESTED_SYSTEM}/current/${NESTED_SYSTEM}-server-cloudimg-${NESTED_ARCH}-disk1.img"
        ;;
    bionic)
        echo "https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-${NESTED_ARCH}.img"
        ;;
    *)
        echo "unsupported system"
        exit 1
        ;;
    esac
}

create_nested_classic_vm(){
    mkdir -p "$WORK_DIR"

    # Get the cloud image
    local IMAGE_URL=$(get_image_url_for_nested_vm)
    wget -P "$WORK_DIR" "$IMAGE_URL"
    local IMAGE=$(ls $WORK_DIR/*.img)
    test "$(echo "$IMAGE" | wc -l)" = "1"

    # Prepare the cloud-init configuration
    cat <<EOF > "$WORK_DIR/seed"
#cloud-config
  ssh_pwauth: True
  users:
   - name: user1
     sudo: ALL=(ALL) NOPASSWD:ALL
     shell: /bin/bash
  chpasswd:
   list: |
    user1:ubuntu
   expire: False
EOF
    cloud-localds -H "$(hostname)" "$WORK_DIR/seed.img" "$WORK_DIR/seed"

    # Start the vm
    start_nested_classic_vm "$IMAGE"
}

start_nested_classic_vm(){
    local IMAGE=$1
    local QEMU=$(get_qemu_for_nested_vm)

    systemd_create_and_start_unit nested-vm "${QEMU} -m 2048 -nographic \
        -net nic,model=virtio -net user,hostfwd=tcp::$SSH_PORT-:22 \
        -drive file=$IMAGE,if=virtio \
        -drive file=$WORK_DIR/seed.img,if=virtio \
        -monitor tcp:127.0.0.1:$MON_PORT,server,nowait -usb \
        -machine accel=kvm"
    wait_for_ssh
}

destroy_nested_vm(){
    systemd_stop_and_destroy_unit nested-vm
    rm -rf "$WORK_DIR"
}

execute_remote(){
    sshpass -p ubuntu ssh -p "$SSH_PORT" -o ConnectTimeout=10 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no user1@localhost "$*"
}
