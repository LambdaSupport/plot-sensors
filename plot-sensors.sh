#!/bin/sh
dir=$(mktemp -d)

(
	cd "$dir";
	# 's' tells us whether the previous line is a section (not empty)
	sudo sensors | awk '/Adapter|fan/ { next }
			/^$/ { s=0; next }
			!s && !/^$/ { h=$1; s=1; next }
			/^fan|temp/ { print $2 >> h "-" $1 }'
)
