# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit distutils

MY_P="${P/_/.}"

DESCRIPTION="Micro-blogging client with multiple interfaces"
HOMEPAGE="http://code.google.com/p/mitter/"
SRC_URI="http://${PN}.googlecode.com/files/${MY_P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=dev-python/pygtk-2.10"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

DOCS="AUTHORS CHEAT-CODES README THANKS"
