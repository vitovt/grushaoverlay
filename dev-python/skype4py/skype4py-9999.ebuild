# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/skype4py/skype4py-1.0.31.0.ebuild,v 1.2 2009/03/21 05:51:26 darkside Exp $

inherit subversion
inherit distutils

DESCRIPTION="Python wrapper for the Skype API."
HOMEPAGE="https://developer.skype.com/wiki/Skype4Py"
SRC_URI="doc? ( mirror://sourceforge/${PN}/Skype4Py-1.0.32.0-htmldoc.zip )"
ESVN_REPO_URI="https://${PN}.svn.sourceforge.net/svnroot/${PN}"
ESVN_PROJECT="${PN}-svn"

LICENSE="BSD"
SLOT="0"
IUSE="doc"
KEYWORDS="~x86 ~amd64"

RDEPEND="${DEPEND}
	net-im/skype"

S="${WORKDIR}/Skype4Py"

src_unpack() {
	subversion_src_unpack
	use doc && unpack ${A}
	cd "${S}"
	use doc && mv "${WORKDIR}/Skype4Py-htmldoc" "${S}/html_doc"
}

src_install() {
	distutils_src_install
	if use doc; then
		dohtml html_doc/* || die "dohtml failed"
	fi
}
