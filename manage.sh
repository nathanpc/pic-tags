#!/bin/bash
# manage.sh
# Manages tags for the Microchip PIC headers.
#
# Author: Nathan Campos <nathan@innoveworkshop.com>

# Directories.
xc8dir="/opt/microchip/xc8/v2.00"
xc16dir="/opt/microchip/xc16/v1.35"
tagsdir="tags"

# Flags.
ctflags="--c-kinds=+defgmpstuvxz"

# Terminal coloring.
bold=$(tput bold)
normal=$(tput sgr0)

# Usage dialog.
function usage {
	echo "Usage: $0 <command>"
	echo "\n    command: build or clean"
	exit 1
}

# Creates the necessary folders for placing tags into.
function create_dirs {
	echo "${bold}Creating the tags directories${normal}"
	
	echo "Creating $tagsdir/xc8/"
	mkdir -p "$tagsdir/xc8"

	echo "Creating $tagsdir/xc16/"
	mkdir -p "$tagsdir/xc16"
}

# Cleans the tags directory.
function clean {
	echo "${bold}Deleting $tagsdir/${normal}"
	rm -rf "$tagsdir"
}

# Builds a tag file from XC8.
#
# @param $1 Compiler name.
# @param $2 Header file location.
# @param $3 Tag file name.
function build_tag {
	echo "Building tags from $3"
	ctags $ctflags -o $tagsdir/$1/$3 $2
}

# Builds the tags for XC8.
function build_xc8 {
	hdir="$xc8dir/pic/include"
	echo "${bold}Building tags for the 8-bit family${normal}"

	for f in $hdir/*.h; do
		if [[ -f $f ]]; then
			header=$(basename $f)

			# Checks if the file is a valid device header.
			if [[ $header =~ ^pic([a-zA-Z0-9]+)\.h$ ]]; then
				# Make sure the device name is uppercase.
				device=$(echo ${BASH_REMATCH[1]} | tr a-z A-Z)

				# Build the tags.
				build_tag "xc8" $f $device
			fi
		fi
	done

	# Build the last tag for the utility headers.
	echo -e "Building tags from xc.h and pic.h as \"$tagsdir/xc8/generic\""
	ctags $ctflags -o $tagsdir/xc8/generic $hdir/xc.h $hdir/pic.h
}

# Builds the tags for XC16.
function build_xc16 {
	hdir="$xc16dir/support"
	echo "${bold}Building tags for the 16-bit family${normal}"

	for family in $hdir/*; do
		# Making sure we are only getting the appropriate device folders.
		if [[ -d $family && $(basename $family) =~ ^(ds)?PIC[a-zA-Z0-9]+ ]]; then
			# Go through the header files for each device.
			for f in $family/h/*.h; do
				if [[ -f $f ]]; then
					header=$(basename $f)

					# Checks if a file is a valid device header.
					if [[ $header =~ ^p([0-9]+[a-zA-Z0-9]+)[^x].h$ ]]; then
						# Make sure the device name is uppercase.
						device=$(echo ${BASH_REMATCH[1]} | tr a-z A-Z)

						# Build the tags.
						build_tag "xc16" $f $device
					fi
				fi
			done
		fi
	done

	# Build the last tag for the utility headers.
	echo -e "Building tags for the generic headers as \"$tagsdir/xc16/generic\""
	ctags $ctflags -o $tagsdir/xc16/generic $hdir/generic/h/*.h
}

# The actual execution of the script.
if [[ $# -gt 0 ]]; then
	if [[ $1 == "build" ]]; then
		# Builds all the tags.
		create_dirs
		build_xc8
		build_xc16
		
		echo -e "${bold}Done${normal}"
	elif [[ $1 == "clean" ]]; then
		# Cleans the tags.
		clean
	else
		# Dumb user.
		echo "Invalid command."
		usage
	fi
else
	# Don't know how to use it?
	usage
fi

