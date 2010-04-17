# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: 

SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 sparc x86"
IUSE="ipv6 ssl mmx 3dnow"

DEPEND=">=media-sound/xmms-1.2.10-r12
	ssl? ( dev-libs/openssl )"

PLUGIN_PATH="Input/mpg123"

M4_VER="1.1"
PATCH_VER="2.3.0.1"
RUSXMMS_VER="43"
inherit rusxmms-plugin

src_compile() {
	myconf="${myconf} --enable-mpg123 $(use_enable ipv6) $(use_enable ssl)"
	
	if use x86 && ! has_pic && { use mmx || use 3dnow; }; then
		myconf="${myconf} --enable-simd"
	else
		myconf="${myconf} --disable-simd"
	fi

	rusxmms-plugin_src_compile
}
