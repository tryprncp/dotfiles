#!/usr/bin/env bash

cat << "EOF"

╭━━╮╱╱╱╱╱╭╮╱╱╱╭╮╭╮╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╭╮╱╱╱╱╱╱╱╱╱╱╱╭╮╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱
╰┫┣╯╱╱╱╱╭╯╰╮╱╱┃┃┃┃╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱┃┃╱╱╱╱╱╱╱╱╱╱╱┃┃╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱
╱┃┃╭━╮╭━┻╮╭╋━━┫┃┃┃╭┳━╮╭━━╮╭━━┳━┳━━┫╰━╮╭━━┳━━┳━━┫┃╭┳━━┳━━┳━━┳━━╮╱╱╱
╱┃┃┃╭╮┫━━┫┃┃╭╮┃┃┃┃┣┫╭╮┫╭╮┃┃╭╮┃╭┫╭━┫╭╮┃┃╭╮┃╭╮┃╭━┫╰╯┫╭╮┃╭╮┃┃━┫━━┫╱╱╱
╭┫┣┫┃┃┣━━┃╰┫╭╮┃╰┫╰┫┃┃┃┃╰╯┃┃╭╮┃┃┃╰━┫┃┃┃┃╰╯┃╭╮┃╰━┫╭╮┫╭╮┃╰╯┃┃━╋━━┣┳┳╮
╰━━┻╯╰┻━━┻━┻╯╰┻━┻━┻┻╯╰┻━╮┃╰╯╰┻╯╰━━┻╯╰╯┃╭━┻╯╰┻━━┻╯╰┻╯╰┻━╮┣━━┻━━┻┻┻╯
╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╭━╯┃╱╱╱╱╱╱╱╱╱╱╱╱┃┃╱╱╱╱╱╱╱╱╱╱╱╱╱╭━╯┃╱╱╱╱╱╱╱╱╱
╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╰━━╯╱╱╱╱╱╱╱╱╱╱╱╱╰╯╱╱╱╱╱╱╱╱╱╱╱╱╱╰━━╯╱╱╱╱╱╱╱╱╱

EOF

sleep 1

# Define pkg_installed function
pkg_installed() {
    dpkg -l "$1" &>/dev/null
}

# Define pkg_available function
pkg_available() {
    apt-cache show "$1" &>/dev/null
}

scrDir=$(dirname "$(realpath "$0")")

listPkg="${1:-"${scrDir}/debian-packages.lst"}"
debianPkg=()
ofs=$IFS
IFS='|'

while read -r pkg deps; do
    pkg="${pkg// /}"
    if [ -z "${pkg}" ]; then
        continue
    fi

    if [ ! -z "${deps}" ]; then
        deps="${deps%"${deps##*[![:space:]]}"}"
        while read -r cdep; do
            if ! pkg_installed "${cdep}"; then
                echo "Error: missing dependency ${cdep} for package ${pkg}"
                exit 1
            fi
        done < <(echo "${deps}" | xargs -n1)
    fi

    if pkg_installed "${pkg}"; then
        echo -e "\033[0;33m[skip]\033[0m ${pkg} is already installed..."
    elif pkg_available "${pkg}"; then
        echo -e "\033[0;32m[debian]\033[0m queueing ${pkg} from official debian repo..."
        debianPkg+=("${pkg}")
    else
        echo "Error: unknown package ${pkg}..."
    fi
done < <(cut -d '#' -f 1 "${listPkg}")

IFS=${ofs}

if [[ ${#debianPkg[@]} -gt 0 ]]; then
    sudo apt-get update
    sudo apt-get install -y "${debianPkg[@]}"
fi

