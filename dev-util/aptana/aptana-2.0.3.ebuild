# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils 
DESCRIPTION="The leading eclipse IDE for Ajax and today's web platforms"
HOMEPAGE="http://www.aptana.com"
#SRC_URI="http://update.aptana.com/studio-standalone/Aptana_Studio_Setup_Linux_${PV}.zip"
SRC_URI="http://d3lq98emif3szr.cloudfront.net/tools/studio/standalone/2.0.3.1265134283/linux/Aptana_Studio_Setup_Linux_x86_2.0.3.zip"

LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND="app-arch/unzip"
RDEPEND=">=virtual/jre-1.5
	|| ( >=net-libs/xulrunner-bin-1.8 net-libs/xulrunner:1.8 )"

src_install() {
	einfo "Installing Aptana"
	dodir "/opt/${PN}"
	local dest="${D}/opt/${PN}"
	cd ${WORKDIR}/${PN}/
	cp -pPR about_files/ configuration/ features/ plugins/ "${dest}" || die "Failed to install Files"
	insinto "/opt/${PN}"
	doins libcairo-swt.so startup.jar about.html AptanaStudio.ini full_uninstall.txt version.txt
	exeinto "/opt/${PN}"
	doexe AptanaStudio

	dodir /opt/bin
	echo "#!/bin/sh" > ${T}/AptanaStudio
	if [ -x /opt/xulrunner ]; then
		echo "export MOZILLA_FIVE_HOME=/opt/xulrunner" >> ${T}/AptanaStudio
	else
		echo "export MOZILLA_FIVE_HOME=/usr/lib/xulrunner" >> ${T}/AptanaStudio
	fi
	echo "/opt/${PN}/AptanaStudio" >> ${T}/AptanaStudio
	dobin ${T}/AptanaStudio

	newicon plugins/com.aptana.ide.framework.jaxer_1.2.7.024774/aptana32.gif AptanaStudio.png
	make_desktop_entry "AptanaStudio" "Aptana Studio" AptanaStudio.png "Development"
}

pkg_postinst() {
	elog "Aptana does not currently work on 64 bit system,"
	elog "if you need it please install the Eclipse plugin version."
}
