# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils

MY_PV_ADD=U1

DESCRIPTION="FreeRapid is a simple Java downloader that supports downloading from Rapidshare and other file-sharing services."
HOMEPAGE="http://wordrider.net/freerapid"
SRC_URI="http://freerapid-downloader.sweb.cz/FreeRAPID-${PV}${MY_PV_ADD}.zip"

LICENSE="GPL"
KEYWORDS="x86 amd64"
RESTRICT="nomirror"

IUSE=""
SLOT="0"
DEPEND=">=dev-java/sun-jre-bin-1.6"
RDEPEND=">=dev-java/sun-jre-bin-1.6"

S="${WORKDIR}/FreeRapid-${PV}u1"
INSTALLDIR="/usr/share/freerapid"

src_install() {
	dodir "${INSTALLDIR}"
	echo -e "[Desktop Entry]\nName=FreeRapid DownLoader\nType=Application\nComment=Software designed for automatic management of downloads and uploads at hosting sites like rapidshare or megaupload\nExec=/usr/share/freerapid/frd.sh\nTryExec=/usr/share/freerapid/frd.sh\nIcon=/usr/share/freerapid/frd.png\nCategories=Network;;" > "${S}"/freerapid.desktop
	mv "${S}/lib" "${S}"/*.sh "${S}/lookandfeel" "${S}/plugins" "${S}"/*.jar "${S}"/*.png "${D}/${INSTALLDIR}/" || die "Cannot install core-files"

	dodoc "${S}"/*.txt
	domenu "${S}"/freerapid.desktop
	doicon "${INSTALLDIR}"/frd.png

	dosym "${INSTALLDIR}"/frd.sh /usr/bin/freerapid

	fowners -R root:users "${INSTALLDIR}"/plugins
        fperms -R 775 "${INSTALLDIR}"
}
