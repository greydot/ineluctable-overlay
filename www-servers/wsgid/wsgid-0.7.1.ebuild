# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python{2_6,2_7} )
inherit distutils-r1

DESCRIPTION="Wsgid is a generic WSGI handler for mongrel2 web server."
HOMEPAGE="http://wsgid.com"
SRC_URI="https://github.com/daltonmatos/${PN}/releases/tag/v${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE=""

RDEPEND=">=www-servers/mongrel-1.7.5:2
	dev-python/plugnplay
	dev-python/pyzmq
	dev-python/python-daemon"

src_install(){
	distutils_src_install
	doman doc/wsgid.8.bz2
	newconfd "${FILESDIR}"/wsgid.confd wsgid || die
	newinitd "${FILESDIR}"/wsgid.initd wsgid || die
}