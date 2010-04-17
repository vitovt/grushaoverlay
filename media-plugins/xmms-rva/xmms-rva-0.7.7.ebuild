# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/normalize/normalize-0.7.7.ebuild,v 1.8 2007/10/15 14:39:12 corsair Exp $

DESCRIPTION="Audio file volume normalizer plugin for XMMS"
HOMEPAGE="http://normalize.nongnu.org/"
SRC_URI="http://savannah.nongnu.org/download/normalize/normalize-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc ppc64 sparc x86 ~x86-fbsd"
IUSE="mad audiofile nls userland_BSD"

RDEPEND="mad? ( media-libs/libmad )
	 audiofile? ( >=media-libs/audiofile-0.2.3-r1 )
	 media-sound/xmms"
DEPEND="${RDEPEND}
	nls? ( dev-util/intltool )"

S="${WORKDIR}/normalize-${PV}"

src_unpack() {
	unpack ${A}
	use userland_BSD && sed -i -e 's/md5sum/md5/' "${S}"/test/*.sh
}

src_compile() {
	econf \
		$(use_enable nls) \
		$(use_with mad) \
		$(use_with audiofile) \
		|| die

	emake || die "emake failed"
}

src_install() {
    mkdir -p "${D}/usr/lib/xmms/Effect"
    install -c -m 755 xmms-rva/.libs/librva.so "${D}/usr/lib/xmms/Effect"
    install -c -m 755 xmms-rva/.libs/librva.la "${D}/usr/lib/xmms/Effect"
}
