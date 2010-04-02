# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils multilib

MY_P="Phun_beta_${PV/./_}"
DESCRIPTION="Phun is a physics simulator such as gravity, friction, and so on"
HOMEPAGE="http://www.phun.at/"
SRC_URI="amd64? ( http://www.phunland.com/download/${MY_P}_linux64.tgz )
	x86? ( http://www.phunland.com/download/${MY_P}_linux32.tgz )"

LICENSE="free-noncomm"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT="mirror strip"

RDEPEND="virtual/opengl
	>=media-libs/sdl-image-1.2
	amd64? (
		>=sys-devel/gcc-4.2
		=media-libs/glew-1.5*
	)
	x86? (
		=media-libs/glew-1.5*
	)"
#	dev-libs/boost

S="${WORKDIR}/Phun"

PHUN_DIR="/opt/${PN}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	if use amd64 ; then
		rm -f lib/libGLEW.so.1.5 || die
		#rm -f libboost_filesystem.so || die
	fi
	if use x86 ; then
		rm -f libGLEW.so.1.3 || die
		rm -f libSDL_image-1.2.so.0 || die
		#rm -f libboost_filesystem.so || die
	fi
}

src_install() {
	insinto "${PHUN_DIR}"
	doins -r *
	exeinto "${PHUN_DIR}"
	doexe "phun.bin"

	if use x86 ; then
		exeinto "${PHUN_DIR}"
		doexe "libboost_filesystem.so"
		make_wrapper ${PN} "./phun.bin" "${PHUN_DIR}" "${PHUN_DIR}"
	fi
	if use amd64 ; then
		exeinto "${PHUN_DIR}/lib"
		doexe "lib/libboost_filesystem.so"
		make_wrapper ${PN} "./phun.bin" "${PHUN_DIR}" "${PHUN_DIR}/lib"
	fi

	make_desktop_entry ${PN} "Phun" "${PHUN_DIR}/Phun.bmp" "Education;"

	dodoc *.txt
	rm "${D}${PHUN_DIR}"/*.txt
}
