# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
PYTHON_COMPAT=( python{2_7,3_3,3_4} pypy )
inherit distutils-r1

DESCRIPTION="A linter for prose"
HOMEPAGE="http://proselint.com"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"

# tests require proselint to be already installed
RESTRICT="test"

DEPEND="dev-python/future[${PYTHON_USEDEP}]
	dev-python/click[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]"

python_prepare_all() {
	sed -i \
		-e "s:find_packages():find_packages(exclude=['tests']):g" \
		setup.py || die
	distutils-r1_python_prepare_all
}