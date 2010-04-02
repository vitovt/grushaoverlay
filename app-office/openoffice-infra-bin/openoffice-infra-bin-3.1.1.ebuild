# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-office/openoffice-bin/openoffice-bin-2.4.0.ebuild,v 1.1 2008/03/27 08:14:06 suka Exp $

inherit eutils fdo-mime multilib

IUSE="java"

DESCRIPTION="Сборка OpenOffice от компании Инфра-ресурс"

SRC_URI="x86?	( http://download.i-rs.ru/pub/openoffice/${PV}/ru/OOo_${PV}_LinuxIntel_ru_infra.tar.gz )
	amd64?	( http://download.i-rs.ru/pub/openoffice/${PV}/ru/OOo_${PV}_LinuxX86-64_ru_infra.tar.gz )
              http://download.i-rs.ru/pub/openoffice/${PV}/uk/OOo_${PV}_LinuxIntel_langpack_generic_uk_infra.tar.gz"
HOMEPAGE="http://www.i-rs.ru/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="!app-office/openoffice
	!app-office/openoffice-infra
    x11-libs/libXaw
    x11-libs/libXinerama
    sys-libs/glibc
    >=dev-lang/perl-5.0
    app-arch/zip
    app-arch/unzip
    >=media-libs/freetype-2.1.10-r2
    java? ( >=virtual/jre-1.5 )"

DEPEND="${RDEPEND}
    sys-apps/findutils"
								

PROVIDE="virtual/ooo"
RESTRICT="strip nomirror"

src_unpack() {
	unpack ${A}
	unzip -qq "${WORKDIR}"/openoffice.org/basis3.1/share/config/images_tango.zip res/*48_8.png
	cd "${WORKDIR}"/res
	mv odb_48_8.png openofficeorg3-base.png
	mv ods_48_8.png openofficeorg3-calc.png
	mv odg_48_8.png openofficeorg3-draw.png
	mv odp_48_8.png openofficeorg3-impress.png
	mv odf_48_8.png openofficeorg3-math.png
	mv odt_48_8.png openofficeorg3-writer.png
	mv printeradmin_48_8.png openofficeorg3-printeradmin.png
}

src_install () {

	#Multilib install dir magic for AMD64
	has_multilib_profile && ABI=x86

	local instdir="/usr/$(get_libdir)"
	local basecomponents="base calc draw impress math writer printeradmin"
	local allcomponents
	local instdirp=$(echo $(echo ${instdir}|sed	's/\//\\\//g')\\/openoffice.org3\\/program )

	dodir "${instdir}"

	mv "${WORKDIR}"/openoffice.org	"${D}${instdir}"
	mv "${WORKDIR}"/openoffice.org3	"${D}${instdir}"

	#Menu entries, icons and mime-types
	cd "${D}${instdir}/openoffice.org3/share/xdg/"

	for desk in ${basecomponents}; do
		sed -i -e s/"Exec=openoffice.org3"/"Exec=ooffice"/	${desk}.desktop || die
		domenu ${desk}.desktop
		doicon "${WORKDIR}"/res/openofficeorg3-"${desk}".png
	done
	
	
	
	# Component symlinks
	for app in base calc draw impress math writer; do
		dosym ${instdir}/openoffice.org3/program/s${app} /usr/bin/oo${app}
	done

	dosym ${instdir}/openoffice.org3/program/spadmin	/usr/bin/ooffice-printeradmin
	dosym ${instdir}/openoffice.org3/program/soffice	/usr/bin/soffice

	# Install wrapper script
	newbin "${FILESDIR}/wrapper.in" ooffice
	sed -i -e s/"\/usr\/LIBDIR\/openoffice\/program"/"${instdirp}"/g "${D}/usr/bin/ooffice" || die


	# Change user install dir
	sed -i -e s/".openoffice.org\/3"/.ooo-3.0/g "${D}${instdir}/openoffice.org3/program/bootstraprc" || die

	# Non-java weirdness see bug #99366
	use !java && rm -f "${D}${instdir}/openoffice.org3/program/javaldx"

	# install java-set-classpath
	if use java; then
	    insinto /usr/$(get_libdir)/openoffice.org/basis3.0/program
	    newins "${FILESDIR}/java-set-classpath.in" java-set-classpath
		fperms 755	/usr/$(get_libdir)/openoffice.org/basis3.0/program/java-set-classpath
	fi

	# prevent revdep-rebuild from attempting to rebuild all the time
	insinto /etc/revdep-rebuild && doins "${FILESDIR}/50-openoffice-infra-bin"

}

pkg_postinst() {

	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update

	[[ -x /sbin/chpax ]] && [[ -e /usr/$(get_libdir)/openoffice/program/soffice.bin ]] && chpax -zm /usr/$(get_libdir)/openoffice/program/soffice.bin

	elog " Чтобы запустить OpenOffice.org ${PV} Pro, выполните:"
	elog
	elog " $ ooffice"
	elog
	elog " Также, для конкретных компонентов, вы можете использовать следующее:"
	elog
	elog " oobase, oocalc, oodraw, ooimpress, oomath, или oowriter"
}
