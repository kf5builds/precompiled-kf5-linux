#!/bin/bash

set -e

usage() {
	echo "Usage: build_frameworks.sh [ -t Release|Debug  ]] [ -g <CMake Generator, like Ninja or Unix Makefiles ] [ -v version of KF5 to install, example 5.33.0 ] -i /path/to/install [ -a Extra CMake args ]"
	exit 1
}

# parse options
buildType=Debug
generator="Unix Makefiles"
installDir=""
kf5Version=5.54.0
extraCmakeArgs=""

while getopts ":t:q:g:v:i:a:" o; do
	case "${o}" in
		t)
			buildType=${OPTARG}
			if [ "$buildType" != "Debug" ] && [ "$buildType" != "Release" ]; then
				echo "Unrecognized Build Type: $buildType"
				usage
			fi
			;;
		g)
			generator=${OPTARG}
			;;
		i)
			installDir=${OPTARG}
			;;
		v)
			kf5Version=${OPTARG}
			;;
		a)
			extraCmakeArgs=${OPTARG}
			;;
		*)
			echo "Unrecognized option: -${o} ${OPTARG}"
			usage
			;;
	esac
done

if [ -z "$installDir" ]; then
	echo "Empty install dir, please specify -i on the command line"
	usage
fi

printf "Building KDE Frameworks 5 version \"$kf5Version\" with build type \"$buildType\", generator \"$generator\", into \"$installDir\", extra args $extraCmakeArgs"
echo

mkdir -p $installDir

shortKF5Version=${kf5Version:0:4}

builddir=/tmp/buildkf5yeah
mkdir -p $builddir

build_framework() {

    framework=$1
    echo "Building $1:"

    cd $builddir

    foldername=$framework-$kf5Version

    echo -n " - Downloading..."
    downloadURL="https://download.kde.org/stable/frameworks/$shortKF5Version/$foldername.tar.xz"
    wget $downloadURL &> $builddir/log.txt || ( echo &&  echo "Failed to download $downloadURL for $framework. Log: " && cat $builddir/log.txt && exit 1 )
    echo "Done"
    echo -n " - Extracting..."
    tar xvf $foldername.tar.xz &> $builddir/log.txt || ( echo && echo "Failed to extract $builddir/$foldername.tar.xz for $framework. Log: " && cat $builddir/log.txt && exit 1 )
    echo "Done"
    echo -n " - Configuring..."

    mkdir -p $foldername/build
    cd $foldername/build

    cmake .. \
		-DCMAKE_PREFIX_PATH="$installDir" \
		-DCMAKE_INSTALL_PREFIX="$installDir" \
		-DCMAKE_BUILD_TYPE=$buildType \
		-G"$generator" $extraCmakeArgs &> $builddir/log.txt || \
			( echo && echo "Failed to configure $framework. cmake ..  Command: " &&
			echo "cd $builddir/$foldername/build && cmake .. -DCMAKE_PREFIX_PATH=\"$installDir\" -DCMAKE_INSTALL_PREFIX=\"$installDir\" -DCMAKE_BUILD_TYPE=$buildType $extraCmakeArgs" && 
			cat $builddir/log.txt && exit 1 )
    echo "Done"
    echo -n " - Building..."
    cmake --build . &> $builddir/log.txt || ( echo && echo "Failed to build $framework. Log: " && cat $builddir/log.txt && exit 1 )
    echo "Done"
    echo -n " - Installing..."
    cmake --build . --target install &> $builddir/log.txt || ( echo && echo "Failed to install $framework. Log: " && cat $builddir/log.txt && exit 1 )
    echo "Done"
}


(while :; do sleep 300; echo "KEEP TRAVIS ALIVE TICK"; done) &

# ECM
if [[ ! -f  "$installDir/ECM_BUILT" ]] || [[ ! -z BUILD_ECM ]]; then
    build_framework extra-cmake-modules
    touch "$installDir/ECM_BUILT"
fi

# Tier 1 Frameworks
if [[ ! -f  "$installDir/TIER_1_BUILT" ]]; then
    build_framework attica
    build_framework kconfig
    #build_framework bluez-qt # kinda buggy with install paths
    build_framework kapidox
    build_framework kdnssd
    build_framework kidletime
    build_framework kplotting
    #build_framework modemmanager-qt # this crashes gcc for some reason...
    #build_framework networkmanager-qt # it's been a pain in the ass to get the dependencies to work on travis. Contact me if you want this implemented.
    #build_framework kwayland # trusty gives hella old version of this
    build_framework prison
    build_framework kguiaddons
    build_framework ki18n
    build_framework kitemviews
    build_framework sonnet
    build_framework kwidgetsaddons
    build_framework kwindowsystem
    build_framework kdbusaddons
    build_framework karchive
    build_framework kcoreaddons
    build_framework kcodecs
    build_framework solid
    build_framework kitemmodels # this crashes gcc for some reason...
    build_framework threadweaver
    build_framework syntax-highlighting
    build_framework breeze-icons

    touch "$installDir/TIER_1_BUILT"
    if [ -z $BUILD_ALL ]; then
        exit 0
    fi
fi

# Tier 2 Frameworks
if [[ ! -f  "$installDir/TIER_2_BUILT" ]]; then
    build_framework kcompletion
    build_framework kfilemetadata
    build_framework kjobwidgets
    build_framework kcrash
    build_framework kimageformats
    build_framework kunitconversion
    build_framework kauth
    build_framework knotifications
    build_framework kpackage
    build_framework kdoctools
    build_framework kpty

    touch "$installDir/TIER_2_BUILT"
    if [ -z $BUILD_ALL ]; then
        exit 0
    fi
fi

# Tier 3 Frameworks
if [[ ! -f  "$installDir/TIER_3_1_BUILT" ]]; then
    build_framework kservice
    build_framework kdesu
    build_framework kemoticons
    build_framework kpeople
    build_framework kconfigwidgets
    build_framework kiconthemes
    build_framework ktextwidgets
    build_framework kglobalaccel
    build_framework kxmlgui
    build_framework kbookmarks
    # build_framework kwallet
    build_framework kio
    build_framework kactivities
    build_framework kactivities-stats
    build_framework baloo
    # build_framework kded # requires a KDE install
    build_framework kxmlrpcclient
    build_framework kparts

    touch "$installDir/TIER_3_1_BUILT"
    if [ -z $BUILD_ALL ]; then
        exit 0
    fi
fi

if [[ ! -f  "$installDir/TIER_3_2_BUILT" ]]; then
    # build_framework kdewebkit
    build_framework kdesignerplugin
    build_framework knewstuff
    build_framework ktexteditor
    build_framework kdeclarative
    build_framework kirigami2
    build_framework qqc2-desktop-style
    build_framework plasma-framework
    build_framework kcmutils
    build_framework knotifyconfig
    build_framework krunner
    build_framework kinit

    touch "$installDir/TIER_3_1_BUILT"
fi;

# if everything went smoothly, remove the builddir
rm -r $builddir
