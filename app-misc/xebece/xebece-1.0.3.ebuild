# Copyright 1999-2011 Vitovt at www.grusha.org.ua
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils

DESCRIPTION="Xebece is a multipurpose tool for information visualization and organization"
HOMEPAGE="http://xebece.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${PN}-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
IUSE=""
KEYWORDS="~amd64 ~x86"


DEPEND=">=virtual/jre-1.5"
RDEPEND="${DEPEND}"

#src_unpack() {
#	unzip -d ${S} ${DISTDIR}/${P}.zip
#}

#src_configure() {
# 	XDIR="Xebece"
#    mv -v "$XDIR" xmind
#
#}

src_compile() {
	einfo "Nothing to compile"
}

src_install() {
	dodir   /opt/xebece

	insinto /opt/xebece
#    doins "${DISTDIR}/${A}"
     einfo "copying files from ${WORKDIR}"
	cd "${WORKDIR}/xebece-1.0"
	doins   -r dist
	doins   -r doc
	doins   -r lib
	doins   -r src
	doins   build.xml
	doins   README.txt

		insinto /opt/xebece
		newins "${FILESDIR}/xebece" xebece || die
		fperms a+rx /opt/xebece/xebece
		dosym   /opt/xebece/xebece       /usr/bin/xebece

#		local res
#			for res in 16 32 48; do
#			insinto /usr/share/icons/hicolor/${res}x${res}/apps
#			newins "${FILESDIR}/xebece.${res}.png" xebec.png || die
#		done

		make_desktop_entry xebece "Xebece" xebece "Office"

}

src_postinstall() {

einfo "You find some examples in the installation directory under"
einfo "/opt/xebece/doc/examples/ ."
einfo "You can also find examples on the Xebece website:"
einfo "http://xebece.sourceforge.net"
}
