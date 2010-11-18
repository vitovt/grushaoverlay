# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# FIXME: Scan for error conditions and implement appropriate dies
# FIXME: Support SLOTS to allow multiple parallel installs
# FIXME: Examine user,group,perms of resulting files

inherit eutils

DESCRIPTION="Personal information manager (PIM) desktop application and framework"
HOMEPAGE="http://chandlerproject.org/"
LICENSE="Apache-2.0"
KEYWORDS="-* ~x86 ~amd64"
IUSE="debug"
SLOT="0"

SRC_URI="http://downloads.osafoundation.org/chandler/releases/${PV}/Chandler_src_${PV}.tar.gz"
RESTRICT="mirror"

EAPI="2"

# FIXME: Maybe Perl, SDL, libpng.  Probably significant amount of
# other stuff.
# FIXME: Install in a fresh Gentoo install to catch additional dependencies.
# FIXME: Remove conflict with SVN chandler
#
# dependencies in external/ to be included in [R]DEPEND as needed
# C-= Chandler-version, or the version included in the Chandler tree
# Cpatch= Chandler has patched the thing
# Cnopatch= Chandler has not patched it (hooray)
#
# config -> no dep required
# configobj -> C-4.3.2 (dev-python/configobj-4.5.3 ~x86) Cnopatch
# dateutil -> C-1.1 (dev-python/python-dateutil-1.1)
#	Cpatch to stop iteration after 20 years
# db -> only rebuilt on windows no dep needed (sys-libs/db-4.5.20_p2-r1 in system)
# docutils -> C-0.4 (in system no dep required) Cnopatch
# eggtranslations -> C-1.1-r10-2 (OSAF product not in portage tree)
# epydoc -> C-3.0beta1 (dev-python/epydoc-2.1-r2 x86
#	dev-python/epydoc-3.0.1 ~x86) Cpatch adds --exclude feature - Needs upstream
# icu -> C-3.6 (dev-libs/icu-3.8.1-r1 x86) Cnopatch
# m2crypto -> C-0.18.2 (dev-python/m2crypto-0.16 x86
#	dev-python/m2crypto-0.18.2 ~x86) Cnopatch
#	already depends on epydoc when with doc useflag. Perhaps Chandler doesn't
#	need it but m2crypto does.
# openjdk -> C-openjdk-7-ea-j2re-b21-Linux (not in portage tree but sun-jre is) Cnopatch
#	C-openjdk-7-ea-j2sdk-b21-Linux (not in portage tree but sun-jdk is) Cnopatch
#	C-apache-ant-1.7.0-bin (dev-java/ant-1.7.1 x86) Cnopatch
# 	includes openjdk and apache-ant (only as "repackage[d] full binaries")
# openssl -> C-0.9.8d (dev-libs/openssl-0.9.8 x86 in system) Cpatch to build on windows
# parsedatetime -> C-0.8.6 (not in portage tree) Cnopatch
# PyICU -> C-0.8-92 (not in portage tree) Cpatch for cygwin
# pylint -> C-? (dev-python/pyling-0.13.1 x86) Cnopatch
#	C-logilab-astng-0.17.0 (dev-python/astng-0.17.0 x86) Cnopatch
#	C-logilab-common-0.21.2 (dev-python/logilab-common-0.21.2 x86) Cnopatch
# PyLucene C-2.3.1-3-418 (OSAF product not in portage tree yet Bug#)
# python C-2.5.1 (dev-lang/pytho-2.5.2-r7 x86 in system) Cnopatch
#	C-bzip2-1.0.3 (app-arch/bzip2-1.0.5-r1 x86) Cnopatch
# readline C-5.2 only rebuilt on windows and darwin (in system)
# setuptools C-0.6c6 (dev-python/setuptools-0.6_rc8-r1 x86 in system) Cnopatch
# swig C-1.3.29 (dev-lang/swig-1.3.36 x86) Cpatch something to remove wx prefix?
# twisted C-r18795 (dev-python/twisted-8.1.0) Cpatch to preserve IMAP4Client capability API
# vobject C-0.7.0-r206-1 (dev-python/vobject-0.7.1 ~x86) Cnopatch
# wx C-wxPython-r218 (dev-python/wxpython-2.8.9.1-r2 x86) Cnopatch
# zanshin C-171 (OSAF product not in portage tree)
# zope C-3.3.0b2-r71371 (net-zope/zope-2.10.7 x86
#	net-zope/zope-3.3.1 ~x86) Cnopatch

RDEPEND=">=x11-libs/gtk+-2
	!app-office/chandler-svn"

DEPEND="${RDEPEND}
	net-misc/curl
	>=sys-devel/gcc-3.4.2[gcj]"

S=${WORKDIR}/${P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/zope.interface.patch"  
}

src_compile() {

	# Compile Chandler the way it wants to be built.  Force
	# single-threaded make as package won't build in parallel (bug #1853).
	cd ${S}/external || die
	# FIXME: Need to file bug to remove GCJ_HOME from the docs as it's no longer
	# needed
	# FIXME: once chandler no longer needs to compile it's dependencies and can
	# use the system libraries - the external stuff will need to go.
	export BUILD_ROOT=${S}/external
	emake -j1 env || die
	emake -j1 $(use debug && echo DEBUG=1) world || die
}

src_install() {

	INST_ROOT=/usr/lib/${PN}/${PV}
	dodir ${INST_ROOT}
	dodir /usr/bin
	# FIXME: Work with upstream to support a "make DESTDIR=${D} install" option
	cp -a ${S}/chandler/* ${D}${INST_ROOT}

	# FIXME create symlink to ${D}/usr/bin/chandler
}
