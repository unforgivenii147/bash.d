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
	find . -type f -mmin +10 -printf '%f  %s bytes\n'
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

gpp() {
	g++ -std=c++17 -Wall -Wextra -O2 -fPIE -pie "$@" -o "$@".out
}

dir() {
	ls -lF --color=always "$PWD" | less -r
}

g1_master() {
	gh repo clone "$@" -- --depth 1 --single-branch --branch master
}
g1_main() {
	gh repo clone "$@" -- --depth 1 --single-branch --branch main
}

tally() {
	sort | uniq -c | sort -n
}

gif2jpg_fgmpeg() {
	ffmpeg -i "$@" -c vp9 -b:v 0 -crf 41 "$@".jpg
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
		exit 1
	}

	cd .. || {
		echo "❌ Failed to change directory."
		exit 1
	}
	rm -rf "$name"
	zsd "${name}.tar"

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

blk() {
    black --verbose -t py313 -l 50 --color --pyi -x -W 8 . "$@"
}

compal() {
    python -m compileall -r99 -j8 . "$@"
}

cppc() {
    g++ -std=c++17 -Wall -Wextra -O2 "$@"
}

creset() {
    printf "\e[3 q"
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

git1() {
    if [ -z "$1" ]; then
        echo "Error: Please provide a repository URL"
        return 1
    fi
    git clone --depth 1 --single-branch --branch main "$1"
}

git2() {
    if [ -z "$1" ]; then
        echo "Error: Please provide a repository URL"
        return 1
    fi
    git clone --depth 1 --single-branch --branch master "$1"
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

imjpg() {
    fd -e webp -e bmp -e tiff -e svg -e jpeg -e png -e PNG --batchsize=33 -X magick {} {.}.jpg "$@"
}

jpeg2png() {
    fd -e jpeg -e jpg --batchsize=33 -X magick {} {.}.png "$@"
}

jpg2png() {
    fd -e jpg -e jpeg --batchsize=33 -X magick {} {.}.png "$@"
}

jpng() {
    fd -e jpg -e jpeg -e JPG -e JPEG --batchsize=33 -X magick {} {.}.png "$@"
}

jpo() {
    jpegoptim -f -o -r --strip-all --max 70 -w 8 **/*.jpg
}

lesl() {
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

pirm() {
    if [ -z "$1" ]; then
        echo "Error: Please provide package name to uninstall"
        return 1
    fi
    yes | python -m pip uninstall "$@"
}

pkgnames() {
    apt search python | grep -E "^[a-zA-Z0-9]" | cut -d"/" -f1
}

pmdvlop() {
    python -m maturin develop -v "$@"
}

png2jpg() {
    fd -e png --batchsize=33 -X magick {} {.}.jpg
}



pp3() {
    MATHLIB=m LDFLAGS=-lpython3.13 python -m pip install --verbose numpy
}

pp() {
    python -m pip install --force-reinstall --upgrade "$@"
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

pyup() {
    if python setup.py sdist bdist_wheel; then
        twine upload dist/*
    else
        echo "Error: Build failed"
        return 1
    fi
}

r() {
    fc -s "$@"
}

rtmp() {
    if [ -d "$PREFIX/tmp" ]; then
        rsync -rv "$PREFIX/tmp" "$HOME/tmp"
    else
        echo "Error: $PREFIX/tmp not found"
        return 1
    fi
}

rufconf() {
    if [ -f ~/.config/ruff/ruff.toml ]; then
        nano ~/.config/ruff/ruff.toml
    else
        echo "Error: ruff.toml not found. Creating directory structure..."
        mkdir -p ~/.config/ruff
        nano ~/.config/ruff/ruff.toml
    fi
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

taplo() {
    taplo --colors=always --verbose "$@"
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

tojpg() {
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

youtube-mp3() {
    if [ -z "$1" ]; then
        echo "Error: Please provide YouTube URL"
        return 1
    fi
    youtube-dl --extract-audio --audio-format mp3 "$@"
}

grh() {
    git reset --hard
}



list_installed() {
    dpkg-query -W -f='${Package} ${Status}  ${Version}\n'
}
