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

f10() {
	find . -type f -mmin -10 -printf '%f  %s bytes\n'
}

pyempty() {
	fd -e py --size 0B --exclude '__init__.py'
	#    fd --type f --extension py --size 0B --exclude '__init__.py'
}

cd_and_extract() {
	for f in */; do
		(cd "$f" && tar -xvf *.tar.gz 2>/dev/null || echo "No tar.gz in $f")
	done
}

psevenz() {
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

pss() {
	ff="/sdcard/data/pip.txt"
	grep "$@" "$ff"
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
		*.7z) 7z x "$1" ;; *) echo "Unknown archive: $1" ;;
		esac
	else
		echo "'$1' is not a file"
	fi
}
dowhl() {
	for f in */; do bash -c "cd \"$f\" && unzip *.whl && rm -v *.whl"; done
}
dir2whl() {
	for f in */; do bash -c "wheel pack \"$f\" && rm -rf $f"; done
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

gif2jpg_ffmpeg() {
	ffmpeg -i "$1" -frames:v 1 "${1%.gif}.jpg"
}

iterpy() {
	for f in */; do
		case "$f" in
		site-packages/) continue ;;
		esac
		echo "Processing $f"
		python -m compileall "$f"
	done
}

trr() {
	local name="$(basename "$PWD")"
	local archive="../${name}.tar"

	echo "Compressing '$name' into '$archive'..."
	tar -cvf "$archive" -C .. "$name" || {
		echo "❌ Compression failed."
		return 1
	}

	cd .. || {
		echo "❌ Failed to change directory."
		return 1
	}
	rm -rf "$name"
	xzz "${name}.tar"

	echo "✅ Done: created '${name}.tar.xz' and removed '$name/'"}

}

tzstd() {
	local name="$(basename "$PWD")"
	local archive="../${name}.tar"

	echo "Compressing '$name' into '$archive'..."
	tar -cvf "$archive" -C .. "$name" || {
		echo "❌ Compression failed."
		return 1
	}

	cd .. || {
		echo "❌ Failed to change directory."
		return 1
	}
	rm -rf "$name"
	zstd --rm -3 "${name}.tar"

	echo "✅ Done: created '${name}.tar.zst' and removed '$name/'"
}

py_ruff() {
	for f in */; do
		case "$f" in
		site-packages/) continue ;;
		esac
		echo "Processing $f"
		ruff format "$f"
	done
}
apidoc() {
	sphinx-apidoc -o ./apidocs . "$@"
}

creset() {
	printf "\e[5 q"
}

d3() {
	du -h --max-depth=1 | sort -h
}

dff() {
	du -d 2 -ch "$@"
}

dnhost() {
	if [ -f ~/../usr/etc/resolv.conf ]; then
		nvim ~/../usr/etc/resolv.conf
	else
		echo "Error: resolv.conf not found"
		return 1
	fi
}

dss() {
	du -sh "$@"
}

du1() {
	du -hd 1 | sort -hr
}

du2() {
	du -h --max-depth=1 | sort -hr | head -10
}

gitdiff() {
	git diff --ignore-all-space --ignore-space-at-eol --ignore-space-change --ignore-blank-lines -- . ':(exclude)*package-lock.json' "$@"
}

gitlink2() {
	if [ -z "$1" ]; then
		echo "Error: Please provide repository name"
		return 1
	fi
	git remote set-url origin "https://github.com/isaac4everlast/${1}.git"
}

gitlog() {
	git log --all --oneline --decorate --graph "$@"
}

gitpublic() {
	gh repo edit --visibility public --accept-visibility-change-consequences "$@"
}

gitpull() {
	git pull --depth 1 "$@"
}

gittag() {
	git ls-remote --tags origin "$@"
}

gittagsort2() {
	git tag -l 'v1.*' "$@"
}

gittagsort() {
	git tag --sort=-version:refname "$@"
}

gl() {
	git log --oneline --graph --decorate "$@"
}

gpush1() {
	git push -u origin master "$@"
}

grc() {
	if [ -z "$1" ]; then
		echo "Error: Please provide repository name"
		return 1
	fi
	gh repo clone "$1"
}

convert_images_to_jpg() {
	fd -e webp -e bmp -e tiff -e svg -e jpeg -e png -e PNG --batchsize=33 -X magick {} {.}.jpg "$@"
}

jpng() {
	fd -e jpg -e jpeg -e JPG -e JPEG --batchsize=33 -X magick {} {.}.png "$@"
}

lss() {
	ls | less
}

mcinet() {
	termux-telephony-call '*100*622*0#'
}

mtn() {
	termux-telephony-call '*555*1*4*1#'
}

pinger() {
	ping -i 4 game.clashofclans.com
}

pingg() {
	ping -i 3 google.com
}

pipconf() {
	if [ -f ~/.config/pip/pip.conf ]; then
		nano ~/.config/pip/pip.conf
	else
		echo "Error: pip.conf not found. Creating directory structure..."
		mkdir -p ~/.config/pip
		nano ~/.config/pip/pip.conf
	fi
}

pkgnames() {
	apt search python | grep -E "^[a-zA-Z0-9]" | cut -d"/" -f1
}


pp3() {
	MATHLIB=m LDFLAGS=-lpython3.12 python -m pip install --verbose numpy
}

ppu() {
	yes | pkg update && pkg upgrade
}

pretcss() {
	fd -e css --batch-size=33 -X prettier -w {} "$@"
}

prethtm() {
	fd -e htm --batch-size=33 -X prettier -w {} "$@"
}

prethtml() {
	fd -e html --batch-size=33 -X prettier -w {} "$@"
}

pretjs() {
	fd -e js --batch-size=33 -X prettier -w {} "$@"
}

pretjson() {
	fd -e json --batch-size=33 -X prettier -w {} "$@"
}

pretts() {
	fd -e ts --batch-size=33 -X prettier -w {} "$@"
}

sdist() {
	python setup.py sdist "$@"
}

showfiles() {
	if [ -z "$1" ]; then
		echo "Error: Please provide package name"
		return 1
	fi
	dpkg-query --listfiles "$1"
}

spb() {
	sphinx-build -b html . _build/html "$@"
}

spbs() {
	sphinx-build -b singlehtml . _build/singlehtml "$@"
}

svg_to_pdf() {
	fd -e svg --batchsize=33 -X magick {} {.}.pdf "$@"
}

tcal() {
	termux-telephony-call "$@"
}

tconf() {
	if [ -f ~/.termux/termux.properties ]; then
		nano ~/.termux/termux.properties
	else
		echo "Error: termux.properties not found. Creating directory..."
		mkdir -p ~/.termux
		nano ~/.termux/termux.properties
	fi
}

tlog() {
	if [ -f ~/.tor/tor.log ]; then
		tail ~/.tor/tor.log "$@"
	else
		echo "Error: tor.log not found"
		return 1
	fi
}

convert_to_jpg() {
	fd -e webp -e png -e bmp -e jpeg --batchsize=33 -X magick {} {.}.jpg "$@"
}

tstart() {
	if [ -f ~/tor.sh ]; then
		~/tor.sh
	else
		echo "Error: ~/tor.sh not found"
		return 1
	fi
}

tstat() {
	pgrep -l tor
}

tstop() {
	pkill tor
}

wifikey() {
	grep -r '^psk=' /data/data/com.termux/files/usr/etc/NetworkManager/system-connections/ 2>/dev/null || echo "No WiFi keys found or directory not accessible"
}

xtree() {
	find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'
}

youtube2mp3() {
	if [ -z "$1" ]; then
		echo "Error: Please provide YouTube URL"
		return 1
	fi
	youtube-dl --extract-audio --audio-format mp3 "$@"
}

list_installed() {
	dpkg-query -W -f='${Package} ${Status}  ${Version}\n'
}

trzip() {
	local name="$(basename "$PWD")"
	local archive="../${name}.zip"

	echo "Compressing '$name' into '$archive'..."
	zip -r -9 "$archive" . || {
		echo "❌ Compression failed."
		return 1
	}

	cd .. || {
		echo "❌ Failed to change directory."
		return 1
	}
	rm -rf "$name"

	echo "✅ Done: created '${name}.zip' and removed '$name/'"
}

gdepth1() {
	local repo_url

	# Determine the full URL
	if [[ "$1" =~ ^https?:// ]]; then
		repo_url="$1"
	else
		repo_url="https://github.com/$1"
	fi

	# Extract owner/repo from URL for size check
	local repo_path=$(echo "$repo_url" | sed -E 's#https?://github\.com/##' | sed 's/\.git$//')

	# Get and display repo size from GitHub API
	echo "Fetching repository size..."
	local size=$(curl -s "https://api.github.com/repos/$repo_path" | grep -o '"size": [0-9]*' | awk '{print $2}')

	if [[ -n "$size" ]]; then
		# Convert size from KB to MB/GB for better readability
		if [[ $size -gt 1048576 ]]; then
			echo "Repository size: $(echo "scale=2; $size/1048576" | bc) GB"
		elif [[ $size -gt 1024 ]]; then
			echo "Repository size: $(echo "scale=2; $size/1024" | bc) MB"
		else
			echo "Repository size: ${size} KB"
		fi
	else
		echo "Could not fetch repository size (rate limit or private repo)"
	fi

	# Clone the repository
	git clone --depth 1 "$repo_url"
}

md() {
	mkdir -p "$@" && cd "$_"
}

rfs() {
	local dir_name=$(basename "$PWD")
	local parent_dir=$(dirname "$PWD")
	cd "$parent_dir" && rm -rf "$dir_name" && echo "Now in: $(pwd)"
}
