# precompiled-kf5-linux

Precompiled KDE frameworks 5 for linux. Good for use in travis.

A bunch of scripts for generating precompiled KF5 tarballs/directories

## build_frameworks.sh
Generates a tar.XX file and/or a directory with KF5 installed in it. Example:

```bash
./build_frameworks.sh -i ~/my-kf5-install -g Ninja -t Debug
```

## Building in docker

We also provide a Ubuntu Trusty (14.04) docker image to build KF5 in. It has all
dependencies preinstalled and environment variables are set.

```
docker pull kf5builds/ubuntu:trusty
docker run -v $PWD:/var/build/ kf5builds/ubuntu:trusty \
  ./build_frameworks.sh -i /var/build/kf5-install -g Ninja -t Release \
  -a "-DCMAKE_CXX_COMPILER=g++-8 -DCMAKE_C_COMPILER=gcc-8"
```

## Usage

In your travis script, find a good place to download and extract the tarball:

```bash
cd
mkdir kf5-release && cd kf5-release
wget https://github.com/chigraph/precompiled-kf5-linux/releases/download/precompiled/kf5-gcc6-linux64-release.tar.xz -O kf5.tar.xz
```

then extract it:

```bash
tar xf kf5.tar.xz
```

Then pass `-DCMAKE_PREFIX_PATH=~/kf5-release` to your cmake command.
This makes sure your `find_package` calls can succeed:

```bash
cmake <path to src directory> -DCMAKE_PREFIX_PATH=~/kf5-release
```

