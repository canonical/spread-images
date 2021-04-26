# About this project

This project provides a set of tasks and scripts used to create and update images used by spread.

This documents explains the images matching criteria and shows the examples to add and update all the supported images.

# Google Backend

The following sections explain the images matching criteria used on gce and show how to create/update images used to run the snapd test suite.

## Image matching criteria

The criteria used to match images on google backend is defined by the following criteria:

The system name in the spread.yaml is used by default to match the image in gce, but the image property can be used instead as in the following example:

	- ubuntu-14.04-64:
        image: ubuntu-os-cloud/ubuntu-1404-lts

To select the project, when it is provided in the image property, then it is used, oterwise snapd-spread will be used by default and if there is not match it will retry with these projects: "ubuntu-os-cloud", "centos-cloud", "debian-cloud", "opensuse-cloud", "freebsd-org-cloud-dev".

To select the image, first it is considered exact matches on name, next is considered exact matches on family and otherwise use term matching. Terms matching method matches when all the single terms of the image name used in the spread.yaml are contained in the description of an image. See this example:

	- ubuntu-16.04-64

	will match by description with the following image on snapd-spread project:

	name: ubuntu-1604-64-v20180628
	family: ubuntu-1604-64
	description: Ubuntu 16.04 64 bits

The images to be matched are ordered by creation date (latest first).

## Naming images on snapd-spread

The criteria for naming images on snapd-spread project follows the rule:

	name: <osname>-<version>-<arch>-v<date>
	family: <osname>-<version>-<arch>
	description: <osname> <version> <arch> bits + <extras>

When it is possible (based on gce naming restrictions) we match images by family (system name in the spread.yaml and the family of the desired image), this guarantees that when an image is updated (the date in the name changes) so we automatically will use the last image published for that family. 

When there is not match by family, the match is done by description.

## Base images

Base images are images with no any dependency or extra configuration, just the settings needed to boot on gce. Those images are used as baed to create final images with test dependencies which are used for snapd test suite.

Some base images are created as part of the snapd-spread projects and others are used from other projects like ubuntu-os-cloud. 

The criteria for naming base images on snapd-spread project follows the rule:

	name: <osname>-<version>-<arch>-base-v<date>
	family: <osname>-<version>-<arch>-base
	description: Base Image

To create a base image there are a set of tasks described on the following section "Add new image", to create a final image also there are a set of tasks described on the following section "Update image".

## Add new images

### Amazon Linux 2

Command to update the image:

    spread google:ubuntu-16.04-64-base:tasks/google/add-amazon-linux-2

Image metadata generated:

    IMAGE="amazon-linux-2-64-base-v$(date +'%Y%m%d')"
    FAMILY="amazon-linux-2-64-base"
    DESCRIPTION="Base image"

The generated image has not the snapd test dependencies. 

### Arch Linux

Command to update the image:

    spread google:ubuntu-16.04-64-base:tasks/google/add-arch-linux

Image metadata generated:

    IMAGE="arch-linux-64-base-v$(date +'%Y%m%d')"
    FAMILY="arch-linux-64-base"
    DESCRIPTION="Base image"

The generated image has not the snapd test dependencies. 

### Debian

Command to update the image:

    spread google:debian-9-64-base:tasks/google/add-debian-sid

Image metadata generated:

    IMAGE="debian-sid-64-base-v$(date +'%Y%m%d')"
    FAMILY="debian-sid-64-base"
    DESCRIPTION="Base image"

The generated image has not the snapd test dependencies. 


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

The update tasks are intended to update a base image installing test dependencies and updating and configuring the system to run the snapd test suite optimally. Some update tasks use base images which are generated on the snapd-spread project, and other take images from other projects such as we get ubuntu-1604-lts images from project ubuntu-os-cloud.

### Amazon Linux 2

This task is not working yet, it will done when amazon linux it is supported by snapd. 


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

Command to update the image:

    spread google:debian-sid-64-base:tasks/google/update-debian-sid

Image metadata generated:

    IMAGE="debian-sid-64-v$(date +'%Y%m%d')"
    FAMILY="debian-sid-64"
    DESCRIPTION="Debian sid 64 bits"

The generated image has the snapd test dependencies installed.

### Opensuse

#### Opensuse 42.2 64 bits

Command to update the image:

    spread google:opensuse-42.2-64-base:tasks/google/update-opensuse-42-2

Image metadata generated:

    IMAGE="opensuse-leap-42-2-64-v$(date +'%Y%m%d')"
    FAMILY="opensuse-leap-42-2-64"
    DESCRIPTION="Opensuse leap 42.2 64 bits"

The generated image has the snapd test dependencies installed and configuration needed to run the snapd test suite.

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

### Fedora

#### Fedora 28

Command to update the image:

    spread google:fedora-28-64-base:tasks/google/update-fedora-28-64

Image metadata generated:

    IMAGE="fedora-28-64-v$(date +'%Y%m%d')"
    FAMILY="fedora-28-64"
    DESCRIPTION="Fedora 28 64 bits with test dependencies"

The generated image has SElinux configured as permissive and the test dependencies installed.

## Run google tasks

The bash script run_google_task.sh is used to run tasks for google backend and then restore the images based on the snapd tests results. 

To run a specific task it is just needed to pass the task name, such as:

    .../spread-images/run_google_task.sh update-ubuntu-16.04-32

In case the task finishes successfully, then the snapd tests are executed (just when the image is available on snapd spread.yaml). If snapd tests finish with errors, then the new image is deleted. In case the image which is gonna be deleted is the only one for its family, it is not deleted. 

The script is downloading spread and snapd inside the current directory to run the validation, so the avoid uploading them as part of the spread project the script has to be executed from a different path.
