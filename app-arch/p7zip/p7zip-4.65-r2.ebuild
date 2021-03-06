# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/p7zip/p7zip-4.65.ebuild,v 1.6 2009/05/03 07:12:52 dirtyepic Exp $

EAPI="2"
WX_GTK_VER="2.8"

inherit eutils toolchain-funcs multilib wxwidgets

DESCRIPTION="Port of 7-Zip archiver for Unix"
HOMEPAGE="http://p7zip.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${PN}_${PV}_src_all.tar.bz2"

LICENSE="LGPL-2.1 rar? ( unRAR )"
SLOT="0"
KEYWORDS="~alpha amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc x86 ~x86-fbsd"
#SDS
IUSE="doc kde rar static wxwidgets rcc"
#EDS

RDEPEND="kde? ( x11-libs/wxGTK:2.8[X,-odbc] || ( kde-base/konqueror kde-base/kdebase-meta kde-base/kdebase ) )
	wxwidgets? ( x11-libs/wxGTK:2.8[X,-odbc] )"

#SDS
DEPEND="${RDEPEND}
	rcc? ( app-i18n/librcc )"
#EDS

S=${WORKDIR}/${PN}_${PV}

pkg_setup() {
	use wxwidgets && wxwidgets_pkg_setup
}

src_prepare() {
	if use kde && ! use wxwidgets ; then
		einfo "USE-flag kde needs wxwidgets flag"
		einfo "silently enabling wxwidgets flag"
	fi

	# remove non-free RAR codec
	if use rar; then
		ewarn "Enabling nonfree RAR decompressor"
	else
		sed -e '/Rar/d' -i makefile*
		rm -rf CPP/7zip/Compress/Rar
		epatch "${FILESDIR}"/${PV}-makefile.patch
	fi

	sed -i \
		-e "/^CXX=/s:g++:$(tc-getCXX):" \
		-e "/^CC=/s:gcc:$(tc-getCC):" \
		-e "s:OPTFLAGS=-O:OPTFLAGS=${CXXFLAGS}:" \
		-e 's:-s ::' \
		makefile* || die "changing makefiles"

	if use amd64; then
		cp -f makefile.linux_amd64 makefile.machine
	elif [[ ${CHOST} == *-darwin* ]] ; then
		# Mac OS X needs this special makefile, because it has a non-GNU linker
		cp -f makefile.macosx makefile.machine
	elif use x86-fbsd; then
		# FreeBSD needs this special makefile, because it hasn't -ldl
		sed -e 's/-lc_r/-pthread/' makefile.freebsd > makefile.machine
	fi
	use static && sed -i -e '/^LOCAL_LIBS=/s/LOCAL_LIBS=/&-static /' makefile.machine

	# We can be more parallel
	cp -f makefile.parallel_jobs makefile

	epatch "${FILESDIR}"/${PV}-hardlink.patch

#SDS
	EPATCH_OPTS="-p1" epatch "${FILESDIR}"/p7zip_4.65-libun7zip.patch || die
	use rcc && ( epatch "${FILESDIR}"/p7zip_4.65-ds-rusxmms.patch || die )
	
	find . -maxdepth 1 -name "makefile.linux*" -print0 | xargs -0 sed -i -e "s/LOCAL_LIBS=-lpthread/LOCAL_LIBS=-lpthread -lrcc/"
#EDS	
}

src_compile() {
	emake all3 || die "compilation error"
	if use kde || use wxwidgets; then
		emake 7zG || die "error building GUI"
	fi
#SDS
	emake -C CPP/7zip/Bundles/Un7Zip || die
#EDS
}

src_test() {
	emake test_7z test_7zr || die "test failed"
	if use kde || use wxwidgets; then
		emake test_7zG || die "GUI test failed"
	fi
}

src_install() {
	# this wrappers can not be symlinks, p7zip should be called with full path
	make_wrapper 7zr "/usr/$(get_libdir)/${PN}/7zr"
	make_wrapper 7za "/usr/$(get_libdir)/${PN}/7za"
	make_wrapper 7z "/usr/$(get_libdir)/${PN}/7z"

	if use kde || use wxwidgets; then
		make_wrapper 7zG "/usr/$(get_libdir)/${PN}/7zG"

		dobin GUI/p7zipForFilemanager
		exeinto /usr/$(get_libdir)/${PN}
		doexe bin/7zG

		insinto /usr/$(get_libdir)/${PN}
		doins -r GUI/{Lang,help}

		if use kde; then
			insinto /usr/share/icons/hicolor/16x16/apps/
			newins GUI/p7zip_16_ok.png p7zip.png

			insinto  /usr/share/apps/konqueror/servicemenus/
			doins GUI/kde/*.desktop
		fi
	fi

	dobin "${FILESDIR}/p7zip" || die

	# gzip introduced in 4.42, so beware :)
	newbin contrib/gzip-like_CLI_wrapper_for_7z/p7zip 7zg || die

	exeinto /usr/$(get_libdir)/${PN}
	doexe bin/7z bin/7za bin/7zr bin/7zCon.sfx || die "doexe bins"
	doexe bin/*.so || die "doexe *.so files"
	if use rar; then
		exeinto /usr/$(get_libdir)/${PN}/Codecs/
		doexe bin/Codecs/*.so || die "doexe Codecs/*.so files"
	fi

	doman man1/7z.1 man1/7za.1 man1/7zr.1
	dodoc ChangeLog README TODO

	if use doc ; then
		dodoc DOCS/*.txt
		dohtml -r DOCS/MANUAL/*
	fi

#SDS
	mkdir -p ${D}/usr/lib/
	mkdir -p ${D}/usr/include/
	install -s -D -m 755 CPP/7zip/Bundles/Un7Zip/libun7zip.so ${D}/usr/lib/libun7zip.so || die
	install -D -m 644 CPP/7zip/Bundles/Un7Zip/u7zip.h ${D}/usr/include/u7zip.h || die
#EDS
}
