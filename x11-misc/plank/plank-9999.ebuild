# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit bzr

DESCRIPTION="Plank is meant to be the simplest dock on the planet. Stupidly simple."
HOMEPAGE="https://launchpad.net/plank"
EBZR_REPO_URI="lp:plank"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND=">=dev-libs/glib-2.26:2
	dev-libs/libgee
	dev-libs/libunique:1
	>=x11-libs/gtk+-2.22:2
	x11-libs/bamf:0
	x11-libs/libX11
	x11-libs/libwnck:1"
DEPEND="${RDEPEND}
	dev-lang/vala:0.12[vapigen]
	dev-util/intltool
	dev-util/pkgconfig
	gnome-base/gnome-common
	sys-devel/gettext"

DOCS=( AUTHORS COPYRIGHT )

src_prepare() {
	NOCONFIGURE=1 ./autogen.sh
}

src_configure() {
	VALAC=$(type -p valac-0.12) \
	VAPIGEN=$(type -p vapigen-0.12) \
		econf
}
