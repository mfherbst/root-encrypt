#####################################################################
# Licence:
#
# (C) 2015 Michael F. Herbst <info@michael-herbst.com>
#
# root-encrypt is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# It is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# A copy of the GNU General Public License can be found 
# at <http://www.gnu.org/licenses/>.
#
#####################################################################

PACKAGE=root-encrypt
TARPREFIX=`date +%Y.%m.%d`-$(PACKAGE)

################################################################

all:
	@echo "Available options:"; \
		echo "dist    Package a tar.gz with no key bundled to it. This package is";  \
		echo "        ideal for distribution, but cannot yet be installed.";  \

dist:
	@rm -f "$(TARPREFIX)_dist.tar.gz" && tar cz --exclude="*~" --exclude=".*.swp" -f "$(TARPREFIX)_dist.tar.gz" "$(PACKAGE)" Makefile README bundle.sh
