# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
AUTOTOOLS_AUTORECONF=1
inherit autotools-utils

DESCRIPTION="SaasC is an implementer for LibSaas"
HOMEPAGE="http://github.com/sass/sassc"
SRC_URI="https://github.com/sass/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="static-libs"

RDEPEND="=dev-libs/libsass-${PV}"

src_prepare() {
	sed -i \
		-e "s:-Wall -fPIC::" \
		-e "s:-Wall::" \
		Makefile.am || die
	sed -i \
		-e "s:-Wall -fPIC::" \
		-e "s:-Wall::" \
		Makefile || die
	autotools-utils_src_prepare
}