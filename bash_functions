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

read_file() {
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

mkv2mp3() {
	if [ $# -lt 1 ]; then
		echo "Usage: movie2mp3 <movie-file>"
		return 1
	fi

	FNAME="$1"

	OUT="${FNAME%.*}.mp3"

	ffmpeg -i "$FNAME" -vn -acodec libmp3lame -b:a 128k "$OUT"
}

f1() {
	find . -type f -mmin -1 -printf '%f  %s bytes\n'
}

f20() {
	find . -type f -mmin -20 -printf '%f  %s bytes\n'
}

f30() {
	find . -type f -mmin -30 -printf '%f  %s bytes\n'
}

f10() {
	find . -type f -mmin -10 -printf '%f  %s bytes\n'
}

f5() {
	find . -type f -mmin -5 -printf '%f  %s bytes\n'
}

fhour() {
	find . -type f -mmin -60 -printf '%f  %s bytes\n'
}

f7() {
	find . -type f -mmin -7 -printf '%f  %s bytes\n'
}

f9() {
	find . -type f -mmin -9 -printf '%f  %s bytes\n'
}

f2() {
	find . -type f -mmin -2 -printf '%f  %s bytes\n'
}

f3() {
	find . -type f -mmin -3 -printf '%f  %s bytes\n'
}

pyempty() {
	fd -e py --size 0B --exclude '__init__.py'
	#    fd --type f --extension py --size 0B --exclude '__init__.py'
}

cd_and_extract() {
	for f in *; do bash -c "cd $f && tar -xvf *.tar.gz"; done
}

p7zz() {
	local name="$(basename "$PWD")"
	local archive="../${name}.7z"

	echo "🗜️ Compressing '$name' into '$archive'..."
	7z a -mx9 "$archive" "../$name" || {
		echo "❌ Compression failed."
		return 1
	}

	cd .. || {
		echo "❌ Failed to change directory."
		return 1
	}

	rm -rf "$name"
	echo "✅ Done: created '$archive' and removed '$name/'"
}

p7zaa() {
	7z a -mx9 "../$(basename "$PWD").7z" "../$(basename "$PWD")"
}
stree() {
	tree -h --du | sort -hr
}
atree() {
	tree -d -L 2 | tail -n 1
}
dtree() {
	tree -d -L 2
}

btree() {
	tree -a -L 4 -h /path/to/backup | grep "GB"

}
ftree() {
	tree -a -I "__pycache__|.git" -L 3 -h
}

gtree() {
	tree -a -I "node_modules|.git|dist|build" -L 3 -h
}

la() {
	ls -a
}
lu() {
	ls -hla
}
pss() {
	ff="/sdcard/data/pip.txt"
	grep "$@" "$ff"
}

md() {
	mkdir -p "$@" && cd "$_"
}
mdr() {
	mkdir -p "$@" && cd "$_"
}
mkdr() {
	mkdir -p "$@" && cd "$_"
}

ljj() {
	ls -la | awk 'NR>1 && !/^d/ {printf "%s %.2f MB\n", $9, $5/1024/1024}'
}

# --------- C++ Programming Shortcuts ---------
cpp_run() {
	if [ "$#" -eq 0 ]; then
		echo "Usage: cpprun <file.cpp>"
		return 1
	fi
	file="$1"
	exe="${file%.cpp}"
	g++ -std=c++17 -Wall -Wextra -O2 "$file" -o "$exe" && ./"$exe"
}
cppnew() {
	if [ $# -eq 0 ]; then
		echo "Usage: cppnew <filename.cpp>"
		return 1
	fi
	file="$1"
	cat >"$file" <<'EOF'
#include <bits/stdc++.h>
using namespace std;

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    // Your code here

    return 0;
}
EOF
	echo "Created $file with basic C++ template"
	nano "$file"
}

pynew() {
	if [ $# -eq 0 ]; then
		echo "Usage: pynew <script.py>"
		return 1
	fi
	file="$1"
	cat >"$file" <<'EOF'
#!/data/data/com.termux/files/usr/bin/python

import sys
from pathlib import Path

from dh import mpf3,get_files


def process_file(fp):
    if not fp.exists():
        return False

    return True


def main():
    cwd=Path.cwd()
    args = sys.argv[1:]
    files = [Path(arg) for arg in args] if args else get_files(cwd)
    mpf3(process_file,files)


if __name__ == "__main__":
    sys.exit(main())
EOF
	chmod +x "$file"
	echo "$file created"
	nvim "$file"
}

git_clone2() {

	if [ -z "$1" ]; then
		echo "Usage: g2 <repo-url> [target-dir]"
		return 1
	fi

	local url="$1"
	local target="${2:-}"

	# Get default branch from remote (e.g. main or master)
	local branch
	branch=$(git ls-remote --symref "$url" HEAD 2>/dev/null | awk '/^ref:/ {print $2}' | sed 's|refs/heads/||')

	if [ -z "$branch" ]; then
		echo "❌ Could not determine default branch for $url"
		return 1
	fi

	# Derive repo name if no custom folder name given
	local repo
	repo=$(basename "$url" .git)

	# Determine target directory
	if [ -z "$target" ]; then
		target="${repo}.git"
	fi

	echo "🔍 Default branch: $branch"
	echo "📦 Cloning only '$branch' from $url into $target ..."
	git clone --single-branch --branch "$branch" --bare "$url" "$target" || return 1

	echo "✅ Done!"
	echo "   To update later: cd $target && git fetch origin $branch"
}

p7xzz() {
	local file
	for file in *; do
		# Only regular files that 7z can handle
		if [[ -f "$file" ]] && 7z l "$file" >/dev/null 2>&1; then
			echo "=== Extracting: $file ==="
			7z x "$file" -y # -y = assume Yes on all queries
		fi
	done
}

gtop() {
	local file
	file=$(
		python3 - <<'EOF'
import os
from pathlib import Path

start = Path(".").resolve()
largest = None

for p in start.rglob("*"):
    if p.is_file():
        try:
            size = p.stat().st_size
            if largest is None or size > largest[1]:
                largest = (p, size)
        except:
            continue

if largest:
    print(largest[0])
EOF
	)

	if [ -z "$file" ]; then
		echo "No files found."
		return 1
	fi

	echo "Largest file: $file"
	local dir
	dir=$(dirname "$file")
	echo "Directory: $dir"

	cd "$dir" || return
	pwd
}

mcd() { mkdir -p "$1" && cd "$1"; }

extract_archive() {
	if [ -f "$1" ]; then
		case "$1" in
		*.tar.bz2) tar xjf "$1" ;;
		*.tar.gz) tar xzf "$1" ;;
		*.tar.xz) tar -xJf "$1" ;;
		*.bz2) bunzip2 "$1" ;;
		*.rar) unrar x "$1" ;;
		*.gz) gunzip "$1" ;;
		*.tar) tar xf "$1" ;;
		*.tbz2) tar xjf "$1" ;;
		*.tgz) tar xzf "$1" ;;
		*.zip) unzip "$1" ;;
		*.7z) 7z x "$1" ;;
		*) echo "Unknown archive: $1" ;;
		esac
	else
		echo "'$1' is not a file"
	fi
}
dowhl() {
	for f in *; do bash -c "cd $f && unzip *.whl && rm -v *.whl"; done
}
dir2whl() {
	for f in */; do bash -c "wheel pack $f && rm -rf $f"; done
}

pipallwhl() {
	for f in *.whl; do python -m pip install --no-deps $f; done
}

clean_exec() {
	"$@" 2>&1 | grep -v 'unsupported flags DT_FLAGS_1'
}

clean_log() {
	if [ -f "$1" ]; then
		sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' "$1" | col -b >"${1}_cleaned.log"
		echo "Cleaned log saved to ${1}_cleaned.log"
	else
		echo "File not found."
	fi
}
