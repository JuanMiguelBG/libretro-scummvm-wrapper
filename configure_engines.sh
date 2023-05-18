#!/bin/bash

 # Copyright (C) 2022 Giovanni Cascione <ing.cascione@gmail.com>
 #
 # This program is free software: you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
 # the Free Software Foundation, either version 3 of the License, or
 # (at your option) any later version.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License
 # along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -e

BUILD_PATH=$(pwd)
SRC_PATH="${BUILD_PATH}/scummvm"

cd "${SRC_PATH}"

# Retrieve all configure functions
sed -i.bak -e "s/exit 0/return 0/g" configure
. configure -h > /dev/null 2>&1

# Collect all default engines dependencies and force to yes
tot_deps=""
for a in $_engines ; do
	varname=_engine_${a}_deps
	for dep in ${!varname} ; do
		found=0
		for rec_dep in $tot_deps ; do
			[ $dep = $rec_dep ] && found=1
		done
		[ $found -eq 0 ] && tot_deps+=" $dep"
	done
done

for dep in $tot_deps ; do
	eval _$dep=yes
done

# Test NO_HIGH_DEF
[ $1 -eq 1 ] && _highres=no

# Create needed engines build files
awk -f "engines.awk" < /dev/null > /dev/null 2>&1

mkdir -p "engines"

copy_if_changed engines/engines.mk.new "engines/engines.mk"
copy_if_changed engines/detection_table.h.new "engines/detection_table.h"
copy_if_changed engines/plugins_table.h.new "engines/plugins_table.h"

# Test NO_WIP
[ $2 -ne 1 ] && sed -i.bak -e "s/# \(.*\)/\1 = STATIC_PLUGIN/g" "config.mk.engines"

echo 0
