# Copyright 2007-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="GIMP plugin to generate large textures from a small sample"
HOMEPAGE="http://gimp-texturize.sourceforge.net/"
SRC_URI="http://registry.gimp.org/files/gimp-save-for-web-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=media-gfx/gimp-2.4"
DEPEND="${RDEPEND}"

src_compile()
{
	einfo "Configuring sources"
	econf || die "unable to configure"
        emake || die "emake failed"
}

src_install() {
	emake || die "unable to make"
	emake DESTDIR="${D}" install || die "unable to install"
}
