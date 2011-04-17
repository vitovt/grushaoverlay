# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit python autotools

DESCRIPTION="Common modules of Red Hat's printer administration tool"
HOMEPAGE="http://spohlenz.blogspot.com/"
SRC_URI="http://launchpad.net/ndisgtk/0.8/${PV}/+download/ndisgtk-${PV}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
SLOT="0"

# system-config-printer split since 1.1.3
RDEPEND="
	net-wireless/ndiswrapper
"
DEPEND="${RDEPEND}
"

S="${WORKDIR}/ndisgtk-${PV}"


src_compile() {
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
