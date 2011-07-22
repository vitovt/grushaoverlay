# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/networkmanager-pptp/networkmanager-pptp-0.8.2.ebuild,v 1.2 2011/03/29 12:52:08 angelos Exp $

EAPI="2"

inherit eutils autotools gnome.org

# NetworkManager likes itself with capital letters
MY_PN="${PN/networkmanager/NetworkManager}"

DESCRIPTION="NetworkManager L2TP plugin"
HOMEPAGE="https://github.com/atorkhov/NetworkManager-l2tp"
SRC_URI="http://distfiles.grusha.org.ua/NetworkManager-l2tp-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gnome"

RDEPEND="
	>=net-misc/networkmanager-0.8.2
	>=dev-libs/dbus-glib-0.74
	net-dialup/ppp
	net-dialup/xl2tpd
	net-dialup/pptpclient
	gnome? (
		>=x11-libs/gtk+-2.6:2
		gnome-base/gconf:2
		gnome-base/gnome-keyring
		gnome-base/libglade:2.0
	)"

DEPEND="${RDEPEND}
	sys-devel/gettext
	dev-util/intltool
	dev-util/pkgconfig"

S=${WORKDIR}/NetworkManager-l2tp-${PV}
ewarn "work dir ${S}"

src_prepare() {
einfo "Preparing sources"
	./autogen.sh
	}

src_configure() {
einfo "Configuring sources"
	econf
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS ChangeLog NEWS README || die "dodoc failed"
}
