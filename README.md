# About this project

This project provides a set of tasks and scripts used to create and update images for spread.

The tasks are organized by backend, beingo google so far the most used.

This documents shows the examples to add and update all the supported images.

# Google Backend

The following sections show how to create new images and how to update them to be used to run the snapd test suite.

## Add new images

### Arch Linux

Command to update the image:

    spread google:ubuntu-16.04-64-base:tasks/google/add-arch-linux

Image metadata generated:

    IMAGE="arch-linux-64-base-v$(date +'%Y%m%d')"
    FAMILY="arch-linux-64-base"
    DESCRIPTION="Base image"

The generated image nither has not the snapd test dependencies used to run snapd tests. 

### Ubuntu

#### Ubuntu 32.04 32 bits

Command to create the image:

    spread google:ubuntu-16.04-64:tasks/google/add-ubuntu-16.04-32

Image metadata generated:

    IMAGE="ubuntu-1604-32-base-v$(date +'%Y%m%d')"
    FAMILY="ubuntu-1604-32-base"
    DESCRIPTION="Base image"

The generated image nither has the snapd test dependencies installed nor the configuration needed to run snapd tests.


### Fedora

#### Fedora 26

Command to create the image:

    spread google:fedora-27-64:tasks/google/add-fedora-26-64

Image metadata generated:

    IMAGE="fedora-26-64-v$(date +'%Y%m%d')"
    FAMILY="fedora-28-64"
    DESCRIPTION="Base Fedora 26 64 bits"

Fedora 26 has just one image, there is not base image asociated, and it has not test dependencies installed and SElinux is not configured as permissive.

#### Fedora 27

Command to create the image:

    spread google:fedora-27-64:tasks/google/add-fedora-28-64

Image metadata generated:

    IMAGE="fedora-28-64-base-v$(date +'%Y%m%d')"
    FAMILY="fedora-28-64-base"
    DESCRIPTION="Base image"

The generated image has not SElinux configured as permissive, so snapd tests will fail. The image has the snapd test dependencies installed.

#### Fedora 28

Command to create the image:

    spread google:fedora-27-64:tasks/google/add-fedora-28-64

Image metadata generated:

    IMAGE="fedora-28-64-base-v$(date +'%Y%m%d')"
    FAMILY="fedora-28-64-base"
    DESCRIPTION="Base image"

The generated image has not SElinux configured as permissive, so snapd tests will fail. The image has the snapd test dependencies installed.


## Update images

The update tasks are intended to update a base image installing test dependencies and updating and configuring the system to run the snapd test suite optimally. Some update tasks use base images which are generated on the computeengine project, and other take images from other projects such as we get ubuntu-1604-lts images from project ubuntu-os-cloud.

### Arch Linux

Command to update the image:

    spread google:arch-linux-64-base:tasks/google/update-arch-linux

Image metadata generated:

    IMAGE="arch-linux-64-v$(date +'%Y%m%d')"
    FAMILY="arch-linux-64"
    DESCRIPTION="Arch Linux 64 bits with test dependencies"

The generated image has the snapd test dependencies installed and configuration needed to run the snapd test suite.


### Debian

#### Debian 9

Command to update the image:

    spread google:debian-9-64-base:tasks/google/update-debian-9

Image metadata generated:

    IMAGE="debian-9-64-v$(date +'%Y%m%d')"
    FAMILY="debian-9-64"
    DESCRIPTION="Debian 9 64 bits"

The generated image has the snapd test dependencies installed.

#### Debian sid


### Opensuse

#### Opensuse 42.3 64 bits

Command to update the image:

    spread google:opensuse-42.3-64-base:tasks/google/update-opensuse-42-3

Image metadata generated:

    IMAGE="opensuse-leap-42-3-64-v$(date +'%Y%m%d')"
    FAMILY="opensuse-leap-42-3-64"
    DESCRIPTION="Opensuse leap 42.3 64 bits"

The generated image has the snapd test dependencies installed and configuration needed to run the snapd test suite.
The base image used for this is the one provided by opensuse-cloud/opensuse-leap-42-3-v20180116


### Ubuntu

#### Ubuntu 14.04 64 bits

Command to update the image:

    spread google:ubuntu-14.04-64-base:tasks/google/update-ubuntu-14.04-64

Image metadata generated:

    IMAGE="ubuntu-1404-64-v$(date +'%Y%m%d')"
    FAMILY="ubuntu-1404-64"
    DESCRIPTION="Ubuntu 14.04 64 bits"

The generated image has the snapd test dependencies installed and configuration needed to run the snapd test suite.
The base image used for this is the one provided by ubuntu-os-cloud/ubuntu-1404-lts

#### Ubuntu 16.04 32 bits

Command to update the image:

    spread google:ubuntu-16.04-32-base:tasks/google/update-ubuntu-16.04-32

Image metadata generated:

    IMAGE="ubuntu-1604-32-v$(date +'%Y%m%d')"
    FAMILY="ubuntu-1604-32"
    DESCRIPTION="Ubuntu 16.04 32 bits"

The generated image has the snapd test dependencies installed and configuration needed to run the snapd test suite.

#### Ubuntu 16.04 64 bits

Command to update the image:

    spread google:ubuntu-16.04-64-base:tasks/google/update-ubuntu-16.04-64

Image metadata generated:

    IMAGE="ubuntu-1604-64-v$(date +'%Y%m%d')"
    FAMILY="ubuntu-1604-64"
    DESCRIPTION="Ubuntu 16.04 64 bits"

The generated image has the snapd test dependencies installed and configuration needed to run the snapd test suite.
The base image used for this is the one provided by ubuntu-os-cloud/ubuntu-1604-lts

#### Ubuntu 18.04 64 bits

Command to update the image:

    spread google:ubuntu-18.04-64-base:tasks/google/update-ubuntu-18.04-64

Image metadata generated:

    IMAGE="ubuntu-1804-64-v$(date +'%Y%m%d')"
    FAMILY="ubuntu-1804-64"
    DESCRIPTION="Ubuntu 18.04 64 bits"

The generated image has the snapd test dependencies installed and configuration needed to run the snapd test suite.
The base image used for this is the one provided by ubuntu-os-cloud/ubuntu-1804-lts
