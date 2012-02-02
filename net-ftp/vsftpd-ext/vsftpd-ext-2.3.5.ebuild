# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-ftp/vsftpd/vsftpd-2.3.5.ebuild,v 1.1 2012/01/08 14:11:40 hwoarang Exp $

EAPI="4"

inherit eutils toolchain-funcs

DESCRIPTION="Vsftpd with additional features like encoding on-the-fly, additional security options, speed limits and so on"
HOMEPAGE="http://vsftpd.devnet.ru/"
SRC_URI="http://vsftpd.devnet.ru/files/${PV}/ext.1/vsFTPd-${PV}-ext1.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="pam tcpd ssl selinux xinetd"
#caps - need to fix files/vsftpd-2.1.0-caps.patch
#caps? ( >=sys-libs/libcap-2 )
DEPEND="
	pam? ( virtual/pam )
	tcpd? ( >=sys-apps/tcp-wrappers-7.6 )
	ssl? ( >=dev-libs/openssl-0.9.7d )"
RDEPEND="${DEPEND}
	net-ftp/ftpbase
	selinux? ( sec-policy/selinux-ftpd )
	xinetd? ( sys-apps/xinetd )
	!net-ftp/vsftpd"
S="${WORKDIR}/vsFTPd-${PV}-ext.1"
MY_PN="vsftpd"
MY_PF=${MY_PN}-${PVR}

src_prepare() {

	# as-needed patch. Bug #335977
	epatch "${FILESDIR}/${MY_PN}-2.3.2-as-needed.patch"

	# kerberos patch. bug #335980
	epatch "${FILESDIR}/${MY_PN}-2.3.2-kerberos.patch"

	# Fix building without the libcap
##	epatch "${FILESDIR}/${MY_PN}-2.1.0-caps.patch"

	# Configure vsftpd build defaults
	use tcpd && echo "#define VSF_BUILD_TCPWRAPPERS" >> builddefs.h
	use ssl && echo "#define VSF_BUILD_SSL" >> builddefs.h
	use pam || echo "#undef VSF_BUILD_PAM" >> builddefs.h

	# Ensure that we don't link against libcap unless asked
##	if ! use caps ; then
##		sed -i '/^#define VSF_SYSDEP_HAVE_LIBCAP$/ d' sysdeputil.c || die
##		epatch "${FILESDIR}"/${MY_PN}-2.2.0-dont-link-caps.patch
##	fi

	# Let portage control stripping
	sed -i '/^LINK[[:space:]]*=[[:space:]]*/ s/-Wl,-s//' Makefile || die
}

src_compile() {
	emake \
		CFLAGS="${CFLAGS}" \
		CC="$(tc-getCC)"
}

src_install() {
	into /usr
	doman ${MY_PN}.conf.5 ${MY_PN}.8
	dosbin ${MY_PN} || die "disbin failed"

	dodoc AUDIT BENCHMARKS BUGS Changelog FAQ \
		README README.security REWARD SIZE \
		SPEED TODO TUNING || die "dodoc failed"
	newdoc ${MY_PN}.conf ${MY_PN}.conf.example

	docinto security
	dodoc SECURITY/* || die "dodoc failed"

	insinto "/usr/share/doc/${PF}/examples"
	doins -r EXAMPLE/* || die "doins faileD"

	insinto /etc/${MY_PN}
	newins ${MY_PN}.conf{,.example}

	insinto /etc/logrotate.d
	newins "${FILESDIR}/${MY_PN}.logrotate" ${MY_PN}

	if use xinetd ; then
		insinto /etc/xinetd.d
		newins "${FILESDIR}/${MY_PN}.xinetd" ${MY_PN}
	fi

	newinitd "${FILESDIR}/${MY_PN}.init" ${MY_PN}

	keepdir /usr/share/${MY_PN}/empty
}

pkg_preinst() {
	# If we use xinetd, then we set listen=NO
	# so that our default config works under xinetd - fixes #78347
	if use xinetd ; then
		sed -i 's/listen=YES/listen=NO/g' "${D}"/etc/${MY_PN}/${MY_PN}.conf.example
	fi
}

pkg_postinst() {
	einfo "vsftpd init script can now be multiplexed."
	einfo "The default init script forces /etc/vsftpd/vsftpd.conf to exist."
	einfo "If you symlink the init script to another one, say vsftpd.foo"
	einfo "then that uses /etc/vsftpd/foo.conf instead."
	einfo
	einfo "Example:"
	einfo "   cd /etc/init.d"
	einfo "   ln -s vsftpd vsftpd.foo"
	einfo "You can now treat vsftpd.foo like any other service"
}
