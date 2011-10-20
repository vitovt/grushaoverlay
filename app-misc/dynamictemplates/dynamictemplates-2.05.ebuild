# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

LANGS="ar br cs de es fr gl it lt nl pl pt ru si tr zh zh_CN"
inherit qt4-r2

DESCRIPTION="Classic versions of the D*I*Y Planner template generator"
HOMEPAGE="http://diyplanner.com/node/6210"
SRC_URI="http://diyplanner.com/files/Dynamic%20Templates%20v2.05a%20source.zip"
LICENSE="GPL-3"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="x11-libs/qt-gui:4"
RDEPEND="${DEPEND}"

src_configure() {
	elog "Configuring..."
	cd "${S}"/DynamicTemplates
	eqmake4
	}

src_compile() {
	elog "Compiling ..."
	cd "${S}"/DynamicTemplates
	make
	}

src_install() {
	exeinto /usr/bin
	cd "${S}"/DynamicTemplates
	doexe   DynamicTemplates

#                local res
#                        for res in 16 32 48; do
#                        insinto /usr/share/icons/hicolor/${res}x${res}/apps
#                        newins "${FILESDIR}/xmind.${res}.png" xmind.png || die
#                done

	make_desktop_entry DynamicTemplates "DynamicTemplates" DynamicTemplates "Office"

}
