#!/bin/sh

dupwhl() {
	fd -e whl | sed -E 's/-[0-9].*//' | sort | uniq -d

}

mp32ogg() {
	fd -e mp3 -i . | while read -r f; do
		out="${f%.mp3}.ogg"
		mkdir -p "$(dirname "$out")"
		oggenc -q 6 -o "$out" "$f"
	done
}

readf() {
	if [ -z "$1" ]; then
		echo "Usage: readf <filename>"
		return 1
	fi

	if [ ! -f "$1" ]; then
		echo "File not found: $1"
		return 1
	fi

	while IFS= read -r line; do
		termux-tts-speak "$line"
		sleep 0.3 # optional: small pause between lines
	done <"$1"
}

mp32opus() {
	fd -e mp3 -i . | while read -r f; do
		out="${f%.mp3}.opus"
		mkdir -p "$(dirname "$out")"
		opusenc --bitrate 128 "$f" "$out"
	done
}
fdelc() {

	fd -t d -i -g --hidden "$1" | while read -r dir; do
		read -p "Delete '$dir'? [y/N] " ans
		if [[ "$ans" =~ ^[Yy]$ ]]; then
			rm -rf "$dir"
			echo "Deleted: $dir"
		fi
	done
}

fdel() {
	fd -t d -i -g --hidden "$1" -x rm -rf {}
}
