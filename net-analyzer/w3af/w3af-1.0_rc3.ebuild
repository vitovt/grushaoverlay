# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/scapy/scapy-2.0.1.ebuild,v 1.1 2009/03/10 01:32:30 ikelos Exp $

inherit eutils versionator distutils

MY_PV=$(replace_version_separator 2 '-')

DESCRIPTION="a Web Application Attack and Audit Framework"
HOMEPAGE="http://w3af.sourceforge.net"
#SRC_URI="mirror://sourceforge/${PN}/${PN}_${MY_PV}.tar.bz2"
#SRC_URI="mirror://sourceforge/project/${PN}/${PN}/${PN}_${MY_PV}.tar.bz2"
SRC_URI="http://downloads.sourceforge.net/project/w3af/w3af/w3af%201.0-rc3%20%5Bmoyogui%5D/w3af-1.0-rc3.tar.bz2?use_mirror=space"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="gtk"

DEPEND="virtual/python"
RDEPEND="
	>=dev-python/fpconst-0.7.2
	dev-python/pygoogle
	dev-python/soappy
	dev-python/pyPdf
	dev-python/beautifulsoup
	dev-python/pyopenssl
	dev-python/jsonpickle
	net-analyzer/scapy

	gtk? ( dev-python/pysqlite
	dev-python/pygtk
	>=x11-libs/gtk+-2.12
	dev-python/pygraphviz
	)"

# GTK: not sure about dev-python/pygraphviz and dev-python/visual
#	media-gfx/graphviz

#pkg_setup() {
#	if ! built_with_use dev-lang/python sqlite ; then
#		eerror "dev-lang/python requires sqlite"
#		die "rebuild dev-lang/python with the sqlite USE flag"
#	fi
#}

src_unpack() {
    unpack ${PN}_${MY_PV}.tar.bz2
    epatch "${FILESDIR}"/w3af-ds-pdf.patch || die
}

src_compile() {
    elog "Nothing to compile"
}

src_install() {
	dodir /usr/lib/
	dodir /usr/bin/
	# should be as simple as copying everything but extlib into the target...
	cp -pPR "${WORKDIR}"/w3af "${D}"usr/lib/w3af || die

	#remove depends already in a portage
	for i in BeautifulSoup.py fpconst-0.7.2 jsonpy nltk nltk_contrib pygoogle pyPdf scapy SOAPpy yaml; do
		rm -r "${D}"usr/lib/w3af/extlib/$i
	done

	dobin "${FILESDIR}"/w3af_console
	if use gtk
	then
		dobin "${FILESDIR}"/w3af_gui
	fi

#why?
	chown -R root:0 "${D}"
}
