# check=skip=InvalidDefaultArgInFrom
# The shared Linux base every Linux port is shot on. Every version comes from
# build/photograph/pins.json; photograph.ps1 passes them in. Do not edit a pin here.
ARG BASE
FROM ${BASE}
ARG UBUNTU_SNAPSHOT
ARG MINT_PACKAGES=""
ARG FONT_URL
ARG FONT_SHA256
ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 LC_ALL=C.UTF-8

# Mint's own repo has no snapshots, and a global APT::Snapshot makes apt abort on Mint.
# So only the Ubuntu lines carry the package date, and Mint packages pin by exact version.
RUN rm -f /etc/apt/sources.list.d/official-source-repositories.list \
    && sed -i "/ubuntu/s/^deb /deb [snapshot=${UBUNTU_SNAPSHOT}] /" /etc/apt/sources.list.d/official-package-repositories.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
         xvfb picom metacity hsetroot imagemagick x11-utils x11-xserver-utils xdotool \
         dbus-x11 dconf-cli dconf-service libglib2.0-bin adwaita-icon-theme gnome-themes-extra \
         procps curl unzip fontconfig faketime git ${MINT_PACKAGES}

# BlexMono Nerd Font (IBM Plex Mono with icons), checked against its pinned hash.
RUN mkdir -p /usr/share/fonts/nerd \
    && curl -fsSL -o /tmp/f.zip "${FONT_URL}" \
    && echo "${FONT_SHA256}  /tmp/f.zip" | sha256sum -c - \
    && unzip -q /tmp/f.zip 'BlexMonoNerdFontMono-*.ttf' -d /usr/share/fonts/nerd \
    && rm /tmp/f.zip && fc-cache -f

# resvg, which renders the build's .png.svg templates, checked against its pinned hash.
# The same script CI installs it with.
ARG RESVG_URL
ARG RESVG_SHA256
ARG RESVG_VERSION
COPY install-resvg.sh /tmp/install-resvg.sh
RUN bash /tmp/install-resvg.sh "${RESVG_URL}" "${RESVG_SHA256}" "${RESVG_VERSION}" && rm /tmp/install-resvg.sh

# Lossless PNG optimization for the shots.
RUN apt-get install -y --no-install-recommends optipng

# The ordinary user every shot runs as. The apt lists stay, so a port's install steps can use apt-get.
RUN useradd -m shooter

# Chromium, the browser of the web scene and the preview shots. Its own last layer, with
# its ARG declared here, so moving its pin leaves every layer above in the cache.
ARG CHROMIUM_VERSION
RUN apt-get install -y --no-install-recommends chromium=${CHROMIUM_VERSION} && apt-get clean
