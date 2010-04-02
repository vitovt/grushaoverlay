# Copyright 1999-2002 Gentoo Technologies, Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header: $
DESCRIPTION="Python bindings for the libsmbclient API from Samba, known as pysmbc"
SRC_URI="http://cyberelk.net/tim/data/pysmbc/${P}.tar.bz2"
HOMEPAGE="http://cyberelk.net/tim/software/pysmbc/"
KEYWORDS="~x86"
SLOT="0"
LICENSE="GPL-2"
IUSE=""
RDEPEND="
	dev-python/dbus-python
	dev-python/pygobject
"
DEPEND="dev-lang/python"

src_compile() {
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
