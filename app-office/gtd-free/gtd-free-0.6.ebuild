# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils

DESCRIPTION="GTD-Free is personal TODO/action manager inspired by GTD (Getting Things Done®) method by David Allen"
HOMEPAGE="http://gtd-free.sourceforge.net"
SRC_URI="http://downloads.sourceforge.net/gtd-free/${P}-beta.jar"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=virtual/jre-1.5"
RDEPEND="${DEPEND}"

src_unpack() {
einfo "Unpacking"
#einfo "A=${A}"
#einfo "S=${S}"
#einfo "D=${D}"
#einfo "P=${P}"
#einfo "{WORKDIR}=${WORKDIR}"
#einfo "{DISTDIR}=${DISTDIR}"
}

src_configure() {
	einfo "Configuring"
}

src_compile() {
	einfo "Nothing to compile"
}

src_install() {
	dodir   /opt/gtd-free
	insinto /opt/gtd-free
	doins "${DISTDIR}/${A}"

	insinto /opt/gtd-free
	newins "${FILESDIR}/gtd-free.sh" gtd-free.sh || diey
	fperms a+rx /opt/gtd-free/gtd-free.sh


	dosym   /opt/gtd-free/${A} /opt/gtd-free/gtd-free.jar
	dosym   /opt/gtd-free/gtd-free.sh	/usr/bin/gtd-free

	make_desktop_entry gtd-free "GTD-free Task Manager" gtd-free "Office"

}
