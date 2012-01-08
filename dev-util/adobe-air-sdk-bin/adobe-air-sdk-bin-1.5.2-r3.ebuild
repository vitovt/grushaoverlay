# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit multilib

EPPI=3
DESCRIPTION="Adobe AIR SDK"
HOMEPAGE="http://www.adobe.com/products/air/tools/sdk/"
SRC_URI="http://airdownload.adobe.com/air/lin/download/1.5.3/AdobeAIRSDK.tbz2"
RESTRICT="fetch"

LICENSE="AdobeAirSDK"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="=dev-libs/nss-3*
	=dev-libs/nspr-4*"

src_install() {
	AIR_BASE="/opt/Adobe/AirSDK"
	insinto ${AIR_BASE}
	ebegin "Removing broken symlinks"
	rm runtimes/air/linux/Adobe\ AIR/Versions/1.0/Resources/nss3/0d/*
	rm runtimes/air/linux/Adobe\ AIR/Versions/1.0/Resources/nss3/1d/*
	rm runtimes/air/linux/Adobe\ AIR/Versions/1.0/Resources/nss3/None/*
	eend
	ebegin "Setting sane permissions to files"
	find -type f -exec chmod 0644 {} \;
	find -type d -exec chmod 0755 {} \;
	eend

	doins -r *
	dodir ${APP_BASE}

	ebegin "Re-setting execute permissions"
	fperms 0755 ${AIR_BASE}/bin/adt
	fperms 0755 ${AIR_BASE}/bin/adl
	find ${D}/${AIR_BASE} -depth -type f -name "*.so" -exec chmod 0755 {} \;
	eend
	ebegin "Recreating symlinks"
	for dir in 0d 1d None; do
		cd ${D}/${AIR_BASE}/runtimes/air/linux/Adobe\ AIR/Versions/1.0/Resources/nss3/$dir
		ln -s ${D}/usr/$(get_libdir)/nss/libnss3.so libnss3.so
		ln -s ${D}/usr/$(get_libdir)/nss/libsmime3.so libsmime3.so
		ln -s ${D}/usr/$(get_libdir)/nss/libssl3.so libssl3.so
		ln -s ${D}/usr/$(get_libdir)/nspr/libnspr4.so libnspr4.so
		ln -s ${D}/usr/$(get_libdir)/nspr/libplc4.so libplc4.so
		ln -s ${D}/usr/$(get_libdir)/nspr/libplds4.so libplds4.so
	done
	eend
	
	cat <<- EOF > airstart
	#!/bin/bash
	# Simple Adobe Air SDK wrapper script to use it as a simple AIR application
	# launcher
	# By Spider.007 / Sjon

	if [[ -z "\$1" ]]
	then
		echo "Please supply an .air application as first argument"
		exit 1
	fi

	tmpdir=\`mktemp -d /tmp/adobeair.XXXXXXXXXX\`

	echo "adobe-air: Extracting application to directory: \$tmpdir"
	mkdir -p \$tmpdir
	unzip -q \$1 -d \$tmpdir || exit 1

	echo "adobe-air: Attempting to start application"
	${AIR_BASE}/bin/adl -nodebug \$tmpdir/META-INF/AIR/application.xml \$tmpdir

	echo "adobe-air: Cleaning up temporary directory"
	rm -Rf \$tmpdir && echo "adobe-air: Done"
	EOF
	
	dobin airstart
}
