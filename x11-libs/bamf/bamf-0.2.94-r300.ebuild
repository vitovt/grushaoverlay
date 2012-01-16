# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit autotools

DESCRIPTION="BAMF Application Matching Framework"
HOMEPAGE="https://launchpad.net/bamf"
SRC_URI="http://launchpad.net/${PN}/0.2/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="3"
KEYWORDS="~amd64 ~x86"
IUSE="+introspection"

RDEPEND="dev-libs/dbus-glib
	dev-libs/glib:2
	gnome-base/libgtop:2
	x11-libs/libX11
	x11-libs/gtk+:3
	x11-libs/libwnck:3"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_prepare() {
	sed -i -e "s:-Wall -Werror::" configure.in || die
	eautoreconf
}

src_configure() {
	econf \
		--with-gtk=3 \
		$(use_enable introspection)
}

src_install() {
	default
	find "${ED}" -name "*.la" -exec rm {} + || die
}
