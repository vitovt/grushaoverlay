# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit python autotools

MY_P="${PN%-common}-${PV}"

DESCRIPTION="Common modules of Red Hat's printer administration tool"
HOMEPAGE="http://cyberelk.net/tim/software/system-config-printer/"
SRC_URI="http://cyberelk.net/tim/data/system-config-printer/1.1/${MY_P}.tar.bz2"

LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
SLOT="0"
IUSE="doc"

# system-config-printer split since 1.1.3
RDEPEND="
	!app-admin/system-config-printer:0
	dev-libs/libxml2[python]
	dev-python/dbus-python
	dev-python/pycups
	dev-python/pygobject
	dev-python/pysmbc
	net-print/cups[dbus]
"
DEPEND="${RDEPEND}
	dev-util/intltool
	doc? ( dev-python/epydoc )
"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	epatch "${FILESDIR}/${P}-split.patch"

	eautoreconf
}

src_configure() {
	econf --disable-nls
}

src_compile() {
	emake || die "emake failed"
	if 	use doc; then
		emake html || die "emake html failed"
	fi
}

src_install() {
	dodoc AUTHORS ChangeLog README || die "dodoc failed"

	if use doc; then
		dohtml -r html/ || die "installing html docs failed"
	fi

	emake DESTDIR="${D}" install || die "emake install failed"
}
