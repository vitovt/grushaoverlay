# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit versionator eutils linux-mod

SLOT=0
MY_P="${PN}-$(delete_version_separator '_')"

DESCRIPTION="Compressed RAM as fast swap"
HOMEPAGE="http://compcache.googlecode.com"
SRC_URI="http://compcache.googlecode.com/files/${MY_P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE="swapfreenotify"

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack "${A}"
	cd ${S}
		if  use swapfreenotify ; then
				einfo          
				elog "You enabled swapfreenotify option"
				elog "This will enable 'swap free notify' feature. This allows kernel"
				elog "to send callback to ramzswap as soon as a swap slot becomes"
				elog "free. So, we can immediately free memory allocated for this"
				elog "page, eliminating any stale data in (compressed) memory. "
				ewarn "make shure that your kernel is properly patched!"
		epatch "${FILESDIR}/enable-SWAP_FREE_NOTIFY-compat.h.patch"
		fi
sed -i "s/@gcc/\$(CC)/g" "sub-projects/rzscontrol/Makefile"
}

src_compile() {
	cd "${S}"
	emake CC=${CHOST}-gcc -C sub-projects/rzscontrol all doc \
		|| die "userspace utilities failed to compile."

}

src_install() {
	exeinto /sbin
	doexe sub-projects/rzscontrol/rzscontrol || die

	exeinto /etc/init.d
	newexe ${FILESDIR}/init.d-compcache compcache
	insinto /etc/conf.d
	newins ${FILESDIR}/conf.d-compcache compcache

	doman sub-projects/rzscontrol/man/rzscontrol.1 ||	die
	dodoc Changelog README

}
pkg_postinst() {
	        einfo "You must check module  before using the compcache."
			einfo "insmod ramzswap.ko num_devices=4"
}
