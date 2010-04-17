# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/xmms-mad/xmms-mad-0.8-r2.ebuild,v 1.2 2006/07/05 06:09:38 vapier Exp $

inherit eutils

DESCRIPTION="A XMMS plugin for MAD"
HOMEPAGE="http://xmms-mad.sourceforge.net/"
SRC_URI="http://0pointer.de/lennart/projects/xmms-pulse/xmms-pulse-0.9.4.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 -mips ~ppc ~ppc64 ~sh ~sparc x86"
IUSE=""

RDEPEND="media-sound/xmms
	 media-sound/pulseaudio"

src_unpack() {
	unpack ${A}
	cd "${S}"
}

src_install() {
	exeinto `xmms-config --input-plugin-dir`
	doexe src/.libs/libxmms-pulse.so || die
	dodoc ChangeLog NEWS README
}
