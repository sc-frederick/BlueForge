###############################################################################
# Name: blueforge
###############################################################################

###############################################################################
# MULTI-STAGE BUILD ARCHITECTURE
###############################################################################
# BlueForge is a thin downstream image. Bluefin already contains the common
# desktop, Homebrew, container, and update infrastructure, so this image only
# layers BlueForge-owned files and packages on top of the stable Bluefin image.
# See: https://docs.projectbluefin.io/contributing/
###############################################################################

# Base image build arg. Declared before the first FROM so it is global —
# an ARG declared inside a stage is scoped to that stage and would leave
# FROM ${BASE_IMAGE} empty ("no FROM statement found").
ARG BASE_IMAGE="ghcr.io/ublue-os/bluefin:stable"

# Context stage - collect only BlueForge-owned build inputs.
FROM scratch AS ctx

COPY build /build
COPY custom /custom
COPY docs /docs

# Base Image - Bluefin GNOME included
# Default is the non-Nvidia Bluefin base. CI (build.yml matrix) and the Justfile
# override BASE_IMAGE to ghcr.io/ublue-os/bluefin-nvidia:stable to produce the
# blueforge-nvidia image. BASE_IMAGE is declared at the top of this file.
FROM ${BASE_IMAGE}

### /opt
## Some bootable images, like Fedora, have /opt symlinked to /var/opt, in order to
## make it mutable/writable for users. However, some packages write files to this directory,
## thus its contents might be wiped out when bootc deploys an image, making it troublesome for
## some packages. Eg, google-chrome, docker-desktop.
##
## Uncomment the following line if one desires to make /opt immutable and be able to be used
## by the package manager.

RUN rm /opt && mkdir /opt

### MODIFICATIONS
## Make modifications desired in your image and install packages by modifying the build scripts.
## The following RUN directive mounts BlueForge's build scripts, custom files,
## and documentation at /ctx. Bluefin's own files are inherited from the base.

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build/10-build.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
