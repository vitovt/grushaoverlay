# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-plugins/pidgin-knotify/pidgin-knotify-0.2.1.ebuild,v 1.2 2010/04/12 19:03:11 maekke Exp $

EAPI="2"

inherit eutils multilib

DESCRIPTION="Plugin to Quote selected message into the entry area. Use it to quick answer to a specified post"
HOMEPAGE="https://launchpad.net/quote/"
SRC_URI="http://launchpad.net/quote/trunk/0.9.3/+download/quote_text.so.i386.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="net-im/pidgin"
RDEPEND="${DEPEND}"


src_unpack() {
	einfo "unpacking ${A}"
	unpack ${A}

}


src_install () {

		INSTDIR="/usr/$(get_libdir)/pidgin"

		insinto $INSTDIR
doins "${FILESDIR}/quote_text.la"
doins "${WORKDIR}/quote_text.so"
}

pkg_postinst() {

        elog " Sucessfully installed "

}
