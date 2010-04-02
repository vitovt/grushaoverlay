# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="OpenProj is a free, open source desktop alternative to Microsoft Project"
HOMEPAGE="http://openproj.org/openproj"
SRC_URI="mirror://sourceforge/openproj/openproj-${PV}.tar.gz
http://openproj.cvs.sourceforge.net/*checkout*/openproj/openproj_build/resources/openproj.desktop
http://openproj.cvs.sourceforge.net/*checkout*/openproj/openproj_build/resources/openproj.png"


LICENSE="CPLA"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND=">=virtual/jre-1.5"
DEPEND="${DEPEND}"

S="${WORKDIR}/openproj-${PV}"

src_unpack() {
	unpack openproj-${PV}.tar.gz
	cd "${S}"
	epatch "${FILESDIR}/openproj-${PV}-fix-launcher.patch"
}

src_install() {
	local installDir=/opt/openproj-${PV}
	insinto /opt
	doins -r "${S}"
	fperms a+rx ${installDir}/openproj.sh
	# Symlink the laucher script
	dosym ${installDir}/openproj.sh /usr/bin/openproj
	# Symlink the directory and the jar to have them without version number
    dosym ${installDir} /opt/openproj

	# Install the desktop menu entry and the corresponding icon
	domenu ${DISTDIR}/openproj.desktop
	doicon ${DISTDIR}/openproj.png
}
