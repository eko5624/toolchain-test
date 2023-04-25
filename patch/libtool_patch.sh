#! /bin/sh

# When run in the root directory of a source package, this script
# patches all the libtoolized files for pe-x86_64 magic.  one may
# try re-libtoolizing with the latest development version of libtool,
# but doing so may give unexpected results, especially if the project
# in question is using a customized libtool version.  This script
# modifies only one necessary line in a given file, instead.
#
# Requires common shell tools.

libtool_patch()
{
	echo "Applying patch for libtool pe-x86_64 magic.."
	rm -f tmp.0lt.diff && touch tmp.0lt.diff
	lst="libtool.m4 aclocal.m4 ltmain.sh libtool configure"
	for i in $lst
	do
		j=`find . -type f -name $i`
		for f in $j
		do
			if test -f $f; then
				cp -p $f tmp.0lt
				sed -e "s|EGREP[-e ]*'file format pe-i386(\.\*architecture: i386)?' >|EGREP 'file format (pei\*-i386(\.\*architecture:\ i386)?\|pe-arm-wince\|pe-x86-64)' >|" \
					-e "s|EGREP[-e ]*'file format (pe-i386(\.\*architecture: i386)?\|pe-arm-wince\|pe-x86-64)' >|EGREP 'file format (pei\*-i386(\.\*architecture:\ i386)?\|pe-arm-wince\|pe-x86-64)' >|" \
					-e "s|deplibs_check_method='file_magic file format pei\*-i386(\.\*architecture: i386)?'|deplibs_check_method='file_magic file format (pei\*-i386(\.\*architecture:\ i386)?\|pe-arm-wince\|pe-x86-64)'|" \
					-e "s|deplibs_check_method='file_magic file format pe-i386(\.\*architecture: i386)?'|deplibs_check_method='file_magic file format (pei\*-i386(\.\*architecture:\ i386)?\|pe-arm-wince\|pe-x86-64)'|" \
					tmp.0lt > $f
				diff -up tmp.0lt $f >> tmp.0lt.diff
				#   preserve the original file timestamp to avoid autotools' reconfiguration
				touch -r tmp.0lt $f
				rm -f tmp.0lt
			fi
		done
	done
	# tell us who actually changed:
	diffstat -l -p0 tmp.0lt.diff 2> /dev/null
}

libtool_patch

