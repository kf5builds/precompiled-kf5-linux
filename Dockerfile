FROM ubuntu:trusty
MAINTAINER LNJ <git@lnj.li>
WORKDIR /var/build/

RUN echo set debconf/frontend Noninteractive | debconf-communicate \
 && echo set debconf/priority critical | debconf-communicate

RUN echo "deb [arch=amd64] http://archive.ubuntu.com/ubuntu trusty main restricted multiverse universe" > /etc/apt/sources.list \
 && echo "deb [arch=amd64] http://archive.ubuntu.com/ubuntu trusty-updates main restricted multiverse universe" >> /etc/apt/sources.list \
 && echo "deb [arch=amd64] http://archive.ubuntu.com/ubuntu trusty-security main restricted multiverse universe" >> /etc/apt/sources.list

RUN apt-get update \
 && apt-get -y --no-install-recommends install apt-transport-https software-properties-common gnupg \
 && apt-get clean

RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test \
 && add-apt-repository -y ppa:beineri/opt-qt593-trusty

RUN apt-get update

RUN apt-get -y --no-install-recommends install \
    qt59base qt59script qt59declarative qt59tools qt59x11extras qt59svg qt59quickcontrols2 \
    ninja-build g++-7 gcc-7 pkg-config gperf \
    gettext bison wget texinfo docbook-xml docbook-xsl flex \
    libxcb-keysyms1-dev libxml2-utils libudev-dev libqrencode-dev libdmtx-dev \
    libattr1-dev libphonon4qt5-dev libphonon4qt5experimental-dev liburi-perl \
    libboost-all-dev liblmdb-dev libxrender-dev libxslt1-dev \
 && apt-get clean

RUN wget https://cmake.org/files/v3.11/cmake-3.11.0-rc3-Linux-x86_64.tar.gz -O- | \
    sudo tar xz -C /usr --strip-components=1

ENV QT_DIR="/opt/qt59"
ENV PATH="$QT_DIR:$PATH"
ENV LD_LIBRARY_PATH=$QT_DIR/lib/x86_64-linux-gnu:$QT_DIR/lib:$LD_LIBRARY_PATH
ENV PKG_CONFIG_PATH=$QT_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

# Workaround to build all travis-ci tiers
ENV BUILD_TIER_1=1
ENV BUILD_TIER_2=1
ENV BUILD_TIER_3=1

