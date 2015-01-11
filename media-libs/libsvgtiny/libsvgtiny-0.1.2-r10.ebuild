# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libsvgtiny/libsvgtiny-0.1.2.ebuild,v 1.1 2014/11/15 13:07:54 xmw Exp $

EAPI=5

NETSURF_BUILDSYSTEM=buildsystem-1.2
inherit netsurf

DESCRIPTION="framebuffer abstraction library, written in C"
HOMEPAGE="http://www.netsurf-browser.org/projects/libsvgtiny/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~m68k-mint"
IUSE=""

RDEPEND=">=net-libs/libdom-0.1.1[xml,static-libs?,${MULTILIB_USEDEP}]
	>=dev-libs/libwapcaplet-0.2.1-r1[static-libs?,${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}
	dev-util/gperf
	virtual/pkgconfig"

PATCHES=( "${FILESDIR}"/${P}-glibc2.20.patch )

src_prepare() {
	# FIX: pkgconfig install path
	sed  -i -e "s:\$(LIBDIR)/pkgconfig:share/pkgconfig:" \
		Makefile || die
	netsurf_src_prepare
}
src_install() {
	# FIX: lib install path
	export LIBDIR="${EPREFIX}/$(get_libdir)"
	netsurf_src_install
}
