# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/zip/zip-2.32-r1.ebuild,v 1.8 2008/03/17 16:06:43 jer Exp $

inherit toolchain-funcs eutils flag-o-matic

DESCRIPTION="Info ZIP (encryption support) with CP866 recoding"
HOMEPAGE="http://www.info-zip.org/"
SRC_URI="ftp://ftp.info-zip.org/pub/infozip/src/zip${PV//.}.tar.gz"

LICENSE="Info-ZIP"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="crypt"

DEPEND=""

#SDS
S=${WORKDIR}/zip-${PV}
#EDS

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/zip-2.3-unix_configure-pic.patch
	epatch "${FILESDIR}"/zip-2.31-exec-stack.patch
	epatch "${FILESDIR}"/zip-2.32-build.patch

#SDS
	epatch "${FILESDIR}"/zip232-ds-recoderus.patch
#EDS
}

src_compile() {
	tc-export CC CPP
	use crypt || append-flags -DNO_CRYPT
	append-lfs-flags
	emake -f unix/Makefile generic || die
}

src_install() {
#SDS
	mv zip ruszip
	dobin ruszip || die
#EDS
}
