#!/usr/bin/env bash

cat << "EOF"

╭━━╮╱╱╱╱╱╭╮╱╱╱╭╮╭╮╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╭╮╱╱╱╱╱╱╱╱╱╱╱╭╮╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱
╰┫┣╯╱╱╱╱╭╯╰╮╱╱┃┃┃┃╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱┃┃╱╱╱╱╱╱╱╱╱╱╱┃┃╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱
╱┃┃╭━╮╭━┻╮╭╋━━┫┃┃┃╭┳━╮╭━━╮╭━━┳━┳━━┫╰━╮╭━━┳━━┳━━┫┃╭┳━━┳━━┳━━┳━━╮╱╱╱
╱┃┃┃╭╮┫━━┫┃┃╭╮┃┃┃┃┣┫╭╮┫╭╮┃┃╭╮┃╭┫╭━┫╭╮┃┃╭╮┃╭╮┃╭━┫╰╯┫╭╮┃╭╮┃┃━┫━━┫╱╱╱
╭┫┣┫┃┃┣━━┃╰┫╭╮┃╰┫╰┫┃┃┃┃╰╯┃┃╭╮┃┃┃╰━┫┃┃┃┃╰╯┃╭╮┃╰━┫╭╮┫╭╮┃╰╯┃┃━╋━━┣┳┳╮
╰━━┻╯╰┻━━┻━┻╯╰┻━┻━┻┻╯╰┻━╮┃╰╯╰┻╯╰━━┻╯╰╯┃╭━┻╯╰┻━━┻╯╰┻╯╰┻━╮┣━━┻━━┻┻┻╯
╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╭━╯┃╱╱╱╱╱╱╱╱╱╱╱╱┃┃╱╱╱╱╱╱╱╱╱╱╱╱╱╭━╯┃╱╱╱╱╱╱╱╱╱
╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╰━━╯╱╱╱╱╱╱╱╱╱╱╱╱╰╯╱╱╱╱╱╱╱╱╱╱╱╱╱╰━━╯╱╱╱╱╱╱╱╱╱

EOF

sleep 1

# Define pkg_installed function
pkg_installed() {
    pacman -Q "$1" &>/dev/null
}

# Define pkg_available function
pkg_available() {
    pacman -Si "$1" &>/dev/null
}

# Define aur_available function
aur_available() {
    curl -s "https://aur.archlinux.org/packages/$1/" | grep -q "404 Not Found"
}

scrDir=$(dirname "$(realpath "$0")")

listPkg="${1:-"${scrDir}/arch-packages.lst"}"
archPkg=()
aurhPkg=()
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
            pass=$(cut -d '#' -f 1 "${listPkg}" | awk -F '|' -v chk="${cdep}" '{if($1 == chk) {print 1;exit}}')
            if [ -z "${pass}" ]; then
                if pkg_installed "${cdep}"; then
                    pass=1
                else
                    break
                fi
            fi
        done < <(echo "${deps}" | xargs -n1)

        if [[ ${pass} -ne 1 ]]; then
            echo -e "\033[0;33m[skip]\033[0m ${pkg} is missing (${deps}) dependency..."
            continue
        fi
    fi

    if pkg_installed "${pkg}"; then
        echo -e "\033[0;33m[skip]\033[0m ${pkg} is already installed..."
    elif pkg_available "${pkg}"; then
        repo=$(pacman -Si "${pkg}" | awk -F ': ' '/Repository / {print $2}')
        echo -e "\033[0;32m[${repo}]\033[0m queueing ${pkg} from official arch repo..."
        archPkg+=("${pkg}")
    elif aur_available "${pkg}"; then
        echo -e "\033[0;34m[aur]\033[0m queueing ${pkg} from arch user repo..."
        aurhPkg+=("${pkg}")
    else
        echo "Error: unknown package ${pkg}..."
    fi
done < <(cut -d '#' -f 1 "${listPkg}")

IFS=${ofs}

if [[ ${#archPkg[@]} -gt 0 ]]; then
    sudo pacman ${use_default} -S "${archPkg[@]}"
fi

if [[ ${#aurhPkg[@]} -gt 0 ]]; then
    "${scrDir}/install_aur.sh" "${getAur}" ${use_default} -S "${aurhPkg[@]}"
fi

