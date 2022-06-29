# syntax=docker/dockerfile:1

FROM python:3-slim-bullseye AS build

RUN adduser --disabled-login --disabled-password --gecos "" --ingroup audio mopidy \
 && printf '\n# include local bin folder in path\nif [ -d ~/bin ]; then\n   export PATH="~/bin:\$PATH"\nfi\n' >> /home/mopidy/.bashrc

RUN set -ex \
    # Official Mopidy install for Debian/Ubuntu along with some extensions
    # (see https://docs.mopidy.com/en/latest/installation/debian/ )
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        gir1.2-gst-plugins-base-1.0 \
        gir1.2-gstreamer-1.0 \
        git \
        gstreamer1.0-alsa \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-ugly \
        gstreamer1.0-tools \
        libasound2-dev \
        libcairo2-dev \
        libgirepository1.0-dev \
        pkg-config \
        python3-alsaaudio \
        python3-dev \
        python3-gst-1.0 \
        python3-pip \
    # Clean-up
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache

USER mopidy
WORKDIR /home/mopidy

#  && export PATH="~/.local/bin:\$PATH" \
RUN set -ex \
 && python3 -m venv --system-site-packages --upgrade-deps /home/mopidy \
 && . bin/activate \
 && python3 -m pip install \
    mopidy \
    mopidy-alsamixer \
    pygobject \
    mopidy-beets \
    mopidy-iris \
    mopidy-ytmusic \
    pytube

USER root
RUN set -ex \
 && apt-get purge --auto-remove -y \
        build-essential \
        libasound2-dev \
        libcairo2-dev \
        libgirepository1.0-dev \
        pkg-config \
        python3-dev \
        pulseaudio gstreamer1.0-pulseaudio \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache \
 && mkdir -p /mnt/mopidy \
 && chmod 0777 /mnt/mopidy
USER mopidy


# Default configuration.
COPY mopidy.conf /home/mopidy/.config/mopidy/mopidy.conf

# Basic check,
RUN /home/mopidy/bin/mopidy --version \
 && /home/mopidy/bin/mopidy config

VOLUME ["/var/lib/mopidy/local", "/var/lib/mopidy/media"]

EXPOSE 6600 6680 5555/udp

ENTRYPOINT ["/home/mopidy/bin/mopidy"]

HEALTHCHECK --interval=5s --timeout=2s --retries=20 \
    CMD curl --connect-timeout 5 --silent --show-error --fail http://localhost:6680/ || exit 1
