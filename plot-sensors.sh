#!/bin/sh
dir=$(mktemp -d)

sense() {
	cd "$dir";
	# 's' tells us whether the previous line is a section (not empty)
	sensors -u | awk '/Adapter|fan/ { next }
			/^$/ { s=0; next }
			!s && !/^$/ { h=$1; s=1; next }
			/(fan|temp)[0-9]+_input:/ { sub(/_input:/, "", $1); print $2 >> h "-" $1 }'
}

plot=$(mktemp -u)
mkfifo "$plot"
gnuplot -p "$plot" & plotpid=$!

exec > "$plot"


cat <<- EOF
set xdata time
set timefmt "%M:%S"

set xlabel "Minutes"
set ylabel "Celcius"

set key left top
EOF

sense && for file in "$dir"/*; do
	printf '"%s" using 0:1 with lines title "%s"\n' \
		"$file" \
		"$(basename "$file")"
done | awk 'NR==1 { printf "plot " }
	NR!=1 { printf ", \\\n\t" }
	{ printf "%s", $0 }
	END { printf "\n" }'

wait "$plotpid"
