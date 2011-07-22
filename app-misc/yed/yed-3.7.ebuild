# Copyright 1999-2011 Vitovt at www.grusha.org.ua
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils

DESCRIPTION="yEd is a powerful diagram editor"
HOMEPAGE="http://www.yworks.com/en/products_yed_about.html"
SRC_URI="http://www.yworks.com/products/${PN}/demo/yEd-${PV}.zip"

LICENSE="GPL-2"
SLOT="0"
IUSE=""
KEYWORDS="~amd64 ~x86"


DEPEND=">=virtual/jre-1.5"
RDEPEND="${DEPEND}"

src_compile() {
	einfo "Nothing to compile"
}

src_install() {
	dodir   /opt/yed

	insinto /opt/yed
einfo "copying files from ${S}"
	cd "${S}"
	doins   license.html
	doins   yed.jar

		insinto /opt/yed
		newins "${FILESDIR}/yed" yed || die
		newins "${FILESDIR}/yEd.png" yEd.png || die
		fperms a+rx /opt/yed/yed
		dosym   /opt/yed/yed      /usr/bin/yed

#		local res
#			for res in 16 32 48; do
#			insinto /usr/share/icons/hicolor/${res}x${res}/apps
#			newins "${FILESDIR}/xebece.${res}.png" xebec.png || die
#		done

#		make_desktop_entry yed "yEd" yed "Office"
		insinto /usr/share/applications
		newins "${FILESDIR}/yEd_Graph_Editor.desktop" yEd_Graph_Editor.desktop|| die

}

src_postinstall() {

einfo "yEd!"
}
