#!/bin/bash
# This script is changed from https://github.com/teddysun/across/blob/master/bbr.sh
# 本脚本改编自：https://github.com/teddysun/across/blob/master/bbr.sh
#
# Auto install latest kernel
#
# System Required:  CentOS 7+ || Red Hat Enterprise Linux 7+ || All Debian base system (included Ubuntu Debian Deepin)

install_headers=0

#系统信息
#指令集
machine=""
#什么系统
release=""
#系统版本号
systemVersion=""
debian_package_manager=""
redhat_package_manager=""

#功能性函数：
#定义几个颜色
purple()                           #基佬紫
{
    echo -e "\\033[35;1m${*}\\033[0m"
}
tyblue()                           #天依蓝
{
    echo -e "\\033[36;1m${*}\\033[0m"
}
green()                            #原谅绿
{
    echo -e "\\033[32;1m${*}\\033[0m"
}
yellow()                           #鸭屎黄
{
    echo -e "\\033[33;1m${*}\\033[0m"
}
red()                              #姨妈红
{
    echo -e "\\033[31;1m${*}\\033[0m"
}
blue()                             #蓝色
{
    echo -e "\\033[34;1m${*}\\033[0m"
}
#检查基本命令
check_base_command()
{
    local i
    local temp_command_list=('bash' 'true' 'false' 'exit' 'echo' 'test' 'sort' 'sed' 'awk' 'grep' 'cut' 'cd' 'rm' 'cp' 'mv' 'head' 'tail' 'uname' 'tr' 'md5sum' 'cat' 'find' 'type' 'command' 'wc' 'ls' 'mktemp' 'swapon' 'swapoff' 'mkswap' 'chmod' 'chown' 'export')
    for i in ${!temp_command_list[@]}
    do
        if ! command -V "${temp_command_list[$i]}" > /dev/null; then
            red "命令\"${temp_command_list[$i]}\"未找到"
            red "不是标准的Linux系统"
            exit 1
        fi
    done
}
#版本比较函数
version_ge()
{
    test "$(echo -e "$1\\n$2" | sort -rV | head -n 1)" == "$1"
}
#安装单个重要依赖
test_important_dependence_installed()
{
    local temp_exit_code=1
    if [ $release == "ubuntu" ] || [ $release == "debian" ] || [ $release == "deepin" ] || [ $release == "other-debian" ]; then
        if LANG="en_US.UTF-8" LANGUAGE="en_US:en" dpkg -s "$1" 2>/dev/null | grep -qi 'status[ '$'\t]*:[ '$'\t]*install[ '$'\t]*ok[ '$'\t]*installed[ '$'\t]*$'; then
            if LANG="en_US.UTF-8" LANGUAGE="en_US:en" apt-mark manual "$1" | grep -qi 'set[ '$'\t]*to[ '$'\t]*manually[ '$'\t]*installed'; then
                temp_exit_code=0
            else
                red "安装依赖 \"$1\" 出错！"
                green  "欢迎进行Bug report(https://github.com/kirin10000/Xray-script/issues)，感谢您的支持"
                yellow "按回车键继续或者Ctrl+c退出"
                read -s
            fi
        elif $debian_package_manager -y --no-install-recommends install "$1"; then
            temp_exit_code=0
        else
            $debian_package_manager update
            $debian_package_manager -y -f install
            $debian_package_manager -y --no-install-recommends install "$1" && temp_exit_code=0
        fi
    else
        if rpm -q "$2" > /dev/null 2>&1; then
            if [ "$redhat_package_manager" == "dnf" ]; then
                dnf mark install "$2" && temp_exit_code=0
            else
                yumdb set reason user "$2" && temp_exit_code=0
            fi
        elif $redhat_package_manager -y install "$2"; then
            temp_exit_code=0
        fi
    fi
    return $temp_exit_code
}
check_important_dependence_installed()
{
    if ! test_important_dependence_installed "$@"; then
        if [ $release == "ubuntu" ] || [ $release == "debian" ] || [ $release == "deepin" ] || [ $release == "other-debian" ]; then
            red "重要组件\"$1\"安装失败！！"
        else
            red "重要组件\"$2\"安装失败！！"
        fi
        yellow "按回车键继续或者Ctrl+c退出"
        read -s
    fi
}
#安装依赖
install_dependence()
{
    if [ $release == "ubuntu" ] || [ $release == "debian" ] || [ $release == "deepin" ] || [ $release == "other-debian" ]; then
        if ! $debian_package_manager -y --no-install-recommends install "$@"; then
            $debian_package_manager update
            $debian_package_manager -y -f install
            if ! $debian_package_manager -y --no-install-recommends install "$@"; then
                yellow "依赖安装失败！！"
                green  "欢迎进行Bug report(https://github.com/kirin10000/Xray-script/issues)，感谢您的支持"
                yellow "按回车键继续或者Ctrl+c退出"
                read -s
            fi
        fi
    else
        if $redhat_package_manager --help | grep -q "\\-\\-enablerepo="; then
            local temp_redhat_install="$redhat_package_manager -y --enablerepo="
        else
            local temp_redhat_install="$redhat_package_manager -y --enablerepo "
        fi
        if ! $redhat_package_manager -y install "$@"; then
            if $temp_redhat_install'epel' install "$@"; then
                return 0
            fi
            if [ $release == "centos" ] && version_ge "$systemVersion" 8;then
                if $temp_redhat_install"epel,powertools" install "$@" || $temp_redhat_install"epel,PowerTools" install "$@"; then
                    return 0
                fi
            fi
            if $temp_redhat_install'*' install "$@"; then
                return 0
            fi
            yellow "依赖安装失败！！"
            green  "欢迎进行Bug report(https://github.com/kirin10000/Xray-script/issues)，感谢您的支持"
            yellow "按回车键继续或者Ctrl+c退出"
            read -s
        fi
    fi
}
# 检查procps是否安装
check_procps_installed()
{
    if [ $release == "centos" ] || [ $release == "rhel" ] || [ $release == "fedora" ] || [ $release == "other-redhat" ]; then
        if ! test_important_dependence_installed "" "procps-ng" && ! test_important_dependence_installed "" "procps"; then
            red '重要组件"procps"安装失败！！'
            yellow "按回车键继续或者Ctrl+c退出"
            read -s
        fi
    else
        check_important_dependence_installed "procps" ""
    fi
}
ask_if()
{
    local choice=""
    while [ "$choice" != "y" ] && [ "$choice" != "n" ]
    do
        tyblue "$1"
        read choice
    done
    [ $choice == y ] && return 0
    return 1
}

if [[ -d "/proc/vz" ]]; then
    red "Error: Your VPS is based on OpenVZ, which is not supported."
    exit 1
fi
check_base_command
if [[ "$(type -P apt)" ]]; then
    if [[ "$(type -P dnf)" ]] || [[ "$(type -P yum)" ]]; then
        red "同时存在apt和yum/dnf"
        red "不支持的系统！"
        exit 1
    fi
    release="other-debian"
    debian_package_manager="apt"
    redhat_package_manager="true"
elif [[ "$(type -P dnf)" ]]; then
    release="other-redhat"
    redhat_package_manager="dnf"
    debian_package_manager="true"
elif [[ "$(type -P yum)" ]]; then
    release="other-redhat"
    redhat_package_manager="yum"
    debian_package_manager="true"
else
    red "apt yum dnf命令均不存在"
    red "不支持的系统"
    exit 1
fi
case "$(uname -m)" in
    'i386' | 'i686')
        machine='i386'
        ;;
    'amd64' | 'x86_64')
        machine='amd64'
        ;;
    'armv5tel' | 'armv6l' | 'armv7' | 'armv7l')
        machine='armhf'
        grep Features /proc/cpuinfo | grep -qw 'vfp' || machine=''
        ;;
    'armv8' | 'aarch64')
        machine='arm64'
        ;;
    'riscv64')
        machine='riscv64'
        ;;
    'ppc64le')
        machine='ppc64el'
        ;;
    's390x')
        machine='s390x'
        ;;
    *)
        machine=''
        ;;
esac
if ([ $release == "ubuntu" ] || [ $release == "debian" ] || [ $release == "deepin" ] || [ $release == "other-debian" ]) && [ -z "$machine" ]; then
    red "不支持的指令集"
    exit 1
fi
if [ $release == "ubuntu" ] || [ $release == "debian" ] || [ $release == "deepin" ] || [ $release == "other-debian" ]; then
    if ! dpkg-deb --help | grep -qw "zstd"; then
        red    "当前系统dpkg不支持解压zst包，不支持安装此内核！"
        green  "请更新系统，或选择使用其他系统，或选择安装xanmod内核"
        exit 1
    fi
    check_important_dependence_installed "linux-base" ""
    if ! version_ge "$(dpkg --list | grep '^[ '$'\t]*ii[ '$'\t][ '$'\t]*linux-base[ '$'\t]' | awk '{print $3}')" "4.5ubuntu1~16.04.1"; then
        install_dependence linux-base
        if ! version_ge "$(dpkg --list | grep '^[ '$'\t]*ii[ '$'\t][ '$'\t]*linux-base[ '$'\t]' | awk '{print $3}')" "4.5ubuntu1~16.04.1"; then
            if ! $debian_package_manager update; then
                red "$debian_package_manager update出错"
                green  "欢迎进行Bug report(https://github.com/kirin10000/Xray-script/issues)，感谢您的支持"
                yellow "按回车键继续或者Ctrl+c退出"
                read -s
            fi
            install_dependence linux-base
        fi
    fi
    if ! version_ge "$(dpkg --list | grep '^[ '$'\t]*ii[ '$'\t][ '$'\t]*linux-base[ '$'\t]' | awk '{print $3}')" "4.5ubuntu1~16.04.1"; then
        red    "系统版本太低！"
        yellow "请更换新系统或使用xanmod内核"
        tyblue "xanmod内核安装脚本：https://github.com/kirin10000/xanmod-install"
        exit 1
    fi
fi
if [ "$EUID" != "0" ]; then
    red "请用root用户运行此脚本！！"
    exit 1
fi

#获取系统版本信息
get_system_info()
{
    local temp_release
    temp_release="$(lsb_release -i -s | tr "[:upper:]" "[:lower:]")"
    if [[ "$temp_release" =~ ubuntu ]]; then
        release="ubuntu"
    elif [[ "$temp_release" =~ debian ]]; then
        release="debian"
    elif [[ "$temp_release" =~ deepin ]]; then
        release="deepin"
    elif [[ "$temp_release" =~ centos ]]; then
        release="centos"
    elif [[ "$temp_release" =~ (redhatenterprise|rhel) ]]; then
        release="rhel"
    fi
    systemVersion="$(lsb_release -r -s)"
}

check_mem()
{
    if (($(free -m | sed -n 2p | awk '{print $2}')<300)); then
        red    "检测到内存小于300M，更换内核可能无法开机，请谨慎选择"
        yellow "按回车键以继续或ctrl+c中止"
        read -s
        echo
    fi
}

#获取可下载内核列表，包存在 kernel_list 中
get_kernel_list()
{
    tyblue "Info: Getting latest kernel version..."
    kernel_list=()
    local temp_file
    temp_file="$(mktemp)"
    if ! wget -O "$temp_file" "https://kernel.ubuntu.com/~kernel-ppa/mainline/"; then
        rm "$temp_file"
        red "获取内核版本失败"
        exit 1
    fi
    local kernel_list_temp
    kernel_list_temp=($(awk -F'\"v' '/v[0-9]/{print $2}' "$temp_file" | cut -d '"' -f1 | cut -d '/' -f1 | sort -rV))
    rm "$temp_file"
    if [ ${#kernel_list_temp[@]} -le 1 ]; then
        red "failed to get the latest kernel version"
        exit 1
    fi
    local i2=0
    local i3
    local kernel_rc=""
    local kernel_list_temp2
    while ((i2<${#kernel_list_temp[@]}))
    do
        if [[ "${kernel_list_temp[$i2]}" =~ -rc(0|[1-9][0-9]*)$ ]] && [ "$kernel_rc" == "" ]; then
            kernel_list_temp2=("${kernel_list_temp[$i2]}")
            kernel_rc="${kernel_list_temp[$i2]%-*}"
            ((i2++))
        elif [[ "${kernel_list_temp[$i2]}" =~ -rc(0|[1-9][0-9]*)$ ]] && [ "${kernel_list_temp[$i2]%-*}" == "$kernel_rc" ]; then
            kernel_list_temp2+=("${kernel_list_temp[$i2]}")
            ((i2++))
        elif [[ "${kernel_list_temp[$i2]}" =~ -rc(0|[1-9][0-9]*)$ ]] && [ "${kernel_list_temp[$i2]%-*}" != "$kernel_rc" ]; then
            for((i3=0;i3<${#kernel_list_temp2[@]};i3++))
            do
                kernel_list+=("${kernel_list_temp2[$i3]}")
            done
            kernel_rc=""
        elif [ -z "$kernel_rc" ] || version_ge "${kernel_list_temp[$i2]}" "$kernel_rc"; then
            kernel_list+=("${kernel_list_temp[$i2]}")
            ((i2++))
        else
            for((i3=0;i3<${#kernel_list_temp2[@]};i3++))
            do
                kernel_list+=("${kernel_list_temp2[$i3]}")
            done
            kernel_rc=""
        fi
    done
    if [ -n "$kernel_rc" ]; then
        for((i3=0;i3<${#kernel_list_temp2[@]};i3++))
        do
            kernel_list+=("${kernel_list_temp2[$i3]}")
        done
    fi
}
get_latest_version() {
    local kernel_list
    get_kernel_list
    local temp_file
    temp_file="$(mktemp)"
    local i
    for ((i=0;i<${#kernel_list[@]};i++))
    do
        if [[ "${kernel_list[$i]}" =~ dontuse ]]; then
            yellow "Skip the don't use version v${kernel_list[$i]}"
            continue
        fi
        if ! wget -q -O "$temp_file" "https://kernel.ubuntu.com/~kernel-ppa/mainline/v${kernel_list[$i]}/"; then
            red "获取内核版本失败"
            rm "$temp_file"
            return 1
        fi
        if grep -q "href=\".*linux-image.*generic_.*$machine\\.deb\"" "$temp_file"; then
            break
        else
            yellow "Kernel version v${kernel_list[$i]} for this arch build failed,finding next one"
        fi
    done
    headers_all_deb_name="$(grep "href=\".*linux-headers.*all\\.deb\"" "$temp_file" | awk -F 'href="' '{print $2}' | cut -d '"' -f1 | sort -rV | head -n 1)"
    headers_all_deb_url="https://kernel.ubuntu.com/~kernel-ppa/mainline/v${kernel_list[$i]}/${headers_all_deb_name}"
    real_headers_all_deb_name="${headers_all_deb_name##*/}"
    headers_generic_deb_name="$(grep "href=\".*linux-headers.*generic_.*$machine\\.deb\"" "$temp_file" | awk -F 'href="' '{print $2}' | cut -d '"' -f1 | sort -rV | head -n 1)"
    headers_generic_deb_url="https://kernel.ubuntu.com/~kernel-ppa/mainline/v${kernel_list[$i]}/${headers_generic_deb_name}"
    real_headers_generic_deb_name="${headers_generic_deb_name##*/}"
    image_deb_name="$(grep "href=\".*linux-image.*generic_.*$machine\\.deb\"" "$temp_file" | awk -F 'href="' '{print $2}' | cut -d '"' -f1 | sort -rV | head -n 1)"
    image_deb_url="https://kernel.ubuntu.com/~kernel-ppa/mainline/v${kernel_list[$i]}/${image_deb_name}"
    real_image_deb_name="${image_deb_name##*/}"
    modules_deb_name="$(grep "href=\".*linux-modules.*generic_.*$machine\\.deb\"" "$temp_file" | awk -F 'href="' '{print $2}' | cut -d '"' -f1 | sort -rV | head -n 1)"
    modules_deb_url="https://kernel.ubuntu.com/~kernel-ppa/mainline/v${kernel_list[$i]}/${modules_deb_name}"
    real_modules_deb_name="${modules_deb_name##*/}"
    rm "$temp_file"
}

remove_kernel()
{
    local exit_code=1
    local temp_file
    temp_file="$(mktemp)"
    if [ $release == "ubuntu" ] || [ $release == "debian" ] || [ $release == "other-debian" ] || [ $release == "deepin" ]; then
        dpkg --list > "$temp_file"
        local kernel_list_headers
        kernel_list_headers=($(awk '{print $2}' "$temp_file" | grep '^linux-headers'))
        local kernel_list_image
        kernel_list_image=($(awk '{print $2}' "$temp_file" | grep '^linux-image'))
        local kernel_list_modules
        kernel_list_modules=($(awk '{print $2}' "$temp_file" | grep '^linux-modules'))
        rm "$temp_file"
        local kernel_headers_all="${headers_all_deb_name%%_*}"
        kernel_headers_all="${kernel_headers_all##*/}"
        local kernel_headers="${headers_generic_deb_name%%_*}"
        kernel_headers="${kernel_headers##*/}"
        local kernel_image="${image_deb_name%%_*}"
        kernel_image="${kernel_image##*/}"
        local kernel_modules="${modules_deb_name%%_*}"
        kernel_modules="${kernel_modules##*/}"
        local ok_install
        local i
        if [ "$install_headers" == "1" ]; then
            ok_install=0
            for ((i=${#kernel_list_headers[@]}-1;i>=0;i--))
            do
                if [[ "${kernel_list_headers[$i]}" == "$kernel_headers" ]] ; then     
                    unset 'kernel_list_headers[$i]'
                    ((ok_install++))
                fi
            done
            if [ "$ok_install" != "1" ] ; then
                red "内核可能安装失败！不卸载"
                return 1
            fi
            ok_install=0
            for ((i=${#kernel_list_headers[@]}-1;i>=0;i--))
            do
                if [[ "${kernel_list_headers[$i]}" == "$kernel_headers_all" ]] ; then     
                    unset 'kernel_list_headers[$i]'
                    ((ok_install++))
                fi
            done
            if [ "$ok_install" != "1" ] ; then
                red "内核可能安装失败！不卸载"
                return 1
            fi
        fi
        ok_install=0
        for ((i=${#kernel_list_image[@]}-1;i>=0;i--))
        do
            if [[ "${kernel_list_image[$i]}" == "$kernel_image" ]] ; then     
                unset 'kernel_list_image[$i]'
                ((ok_install++))
            fi
        done
        if [ "$ok_install" != "1" ] ; then
            red "内核可能安装失败！不卸载"
            return 1
        fi
        ok_install=0
        for ((i=${#kernel_list_modules[@]}-1;i>=0;i--))
        do
            if [[ "${kernel_list_modules[$i]}" == "$kernel_modules" ]] ; then     
                unset 'kernel_list_modules[$i]'
                ((ok_install++))
            fi
        done
        if [ "$ok_install" != "1" ] ; then
            red "内核可能安装失败！不卸载"
            return 1
        fi
        if [ ${#kernel_list_image[@]} -eq 0 ] && [ ${#kernel_list_modules[@]} -eq 0 ] && ([ $install_headers -eq 0 ] || [ ${#kernel_list_headers[@]} -eq 0 ]); then
            red "未发现可卸载内核！不卸载"
            return 1
        fi
        yellow "卸载过程中弹出对话框，请选择NO！"
        yellow "卸载过程中弹出对话框，请选择NO！"
        yellow "卸载过程中弹出对话框，请选择NO！"
        tyblue "按回车键继续。。"
        read -s
        if [ $install_headers -eq 1 ]; then
            apt -y purge "${kernel_list_headers[@]}" "${kernel_list_image[@]}" "${kernel_list_modules[@]}" && exit_code=0
        else
            apt -y purge "${kernel_list_image[@]}" "${kernel_list_modules[@]}" && exit_code=0
        fi
        [ $exit_code -eq 1 ] && apt -y -f install
    else
        rpm -qa > "$temp_file"
        local kernel_list
        kernel_list=($(grep -E '^kernel(|-ml|-lt)-[0-9]' "$temp_file"))
        local kernel_list_headers
        kernel_list_headers=($(grep -E '^kernel(|-ml|-lt)-headers' "$temp_file"))
        local kernel_list_devel
        kernel_list_devel=($(grep -E '^kernel(|-ml|-lt)-devel' "$temp_file"))
        local kernel_list_modules
        kernel_list_modules=($(grep -E '^kernel(|-ml|-lt)-modules' "$temp_file"))
        local kernel_list_core
        kernel_list_core=($(grep -E '^kernel(|-ml|-lt)-core' "$temp_file"))
        rm "$temp_file"
        if [ $((${#kernel_list[@]}-${#kernel_list_first[@]})) -le 0 ] || [ $((${#kernel_list_devel[@]}-${#kernel_list_devel_first[@]})) -le 0 ] || (version_ge "$systemVersion" 8 && ([ $((${#kernel_list_modules[@]}-${#kernel_list_modules_first[@]})) -le 0 ] || [ $((${#kernel_list_core[@]}-${#kernel_list_core_first[@]})) -le 0 ])) || ([ $install_headers -eq 1 ] && [ $((${#kernel_list_headers[@]}-${#kernel_list_headers_first[@]})) -le 0 ]); then
            red "内核可能未安装！不卸载"
            return 1
        fi
        if [ $install_headers -eq 1 ]; then
            rpm -e --nodeps "${kernel_list_first[@]}" "${kernel_list_devel_first[@]}" "${kernel_list_modules_first[@]}" "${kernel_list_core_first[@]}" "${kernel_list_headers_first[@]}" && exit_code=0
        else
            rpm -e --nodeps "${kernel_list_first[@]}" "${kernel_list_devel_first[@]}" "${kernel_list_modules_first[@]}" "${kernel_list_core_first[@]}" && exit_code=0
        fi
    fi
    if [ $exit_code -eq 0 ]; then
        green "卸载成功"
    else
        red "卸载失败！"
        yellow "按回车键继续或Ctrl+c退出"
        read -s
        return 1
    fi
}

update_kernel() {
    [ "$redhat_package_manager" == "yum" ] && check_important_dependence_installed "" "yum-utils"
    check_important_dependence_installed lsb-release redhat-lsb-core
    get_system_info
    if [ $release == "other-redhat" ] || ( ([ ${release} == "centos" ] || [ ${release} == "rhel" ]) && ! version_ge "$systemVersion" 7 ); then
        red "不支持的系统"
        yellow "仅支持CentOS 7+ 、 Red Hat Enterprise Linux 7+ 和 Debian基系统 (包含 Ubuntu Debian Deepin)"
        exit 1
    fi
    check_procps_installed
    check_mem
    check_important_dependence_installed ca-certificates ca-certificates
    if [ ${release} == "centos" ] || [ ${release} == "rhel" ]; then
        local temp_file
        temp_file="$(mktemp)"
        rpm -qa > "$temp_file"
        kernel_list_first=($(grep -E '^kernel(|-ml|-lt)-[0-9]' "$temp_file"))
        kernel_list_headers_first=($(grep -E '^kernel(|-ml|-lt)-headers' "$temp_file"))
        kernel_list_devel_first=($(grep -E '^kernel(|-ml|-lt)-devel' "$temp_file"))
        kernel_list_modules_first=($(grep -E '^kernel(|-ml|-lt)-modules' "$temp_file"))
        kernel_list_core_first=($(grep -E '^kernel(|-ml|-lt)-core' "$temp_file"))
        rm "$temp_file"
        if ! rpm --import "https://www.elrepo.org/RPM-GPG-KEY-elrepo.org"; then
            red "导入elrepo公钥失败"
            yellow "按回车键继续或Ctrl+c退出"
            read -s
        fi
        if version_ge "$systemVersion" 8; then
            local elrepo_url="https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm"
        else
            local elrepo_url="https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm"
        fi
        if ! $redhat_package_manager -y install "$elrepo_url"; then
            red "Install elrepo failed, please check it and retry."
            yellow "按回车键继续或Ctrl+c退出"
            read -s
        fi
        if $redhat_package_manager --help | grep -q "\\-\\-enablerepo="; then
            local redhat_install_command=("$redhat_package_manager" "-y" "--enablerepo=elrepo-kernel" "install")
        else
            local redhat_install_command=("$redhat_package_manager" "-y" "--enablerepo" "elrepo-kernel" "install")
        fi
        if version_ge "$systemVersion" 8; then
            local temp_install=("kernel-ml" "kernel-ml-core" "kernel-ml-devel" "kernel-ml-modules")
        else
            local temp_install=("kernel-ml" "kernel-ml-devel")
        fi
        [ $install_headers -eq 1 ] && temp_install+=("kernel-ml-headers")
        if ! "${redhat_install_command[@]}" "${temp_install[@]}"; then
            red "Error: Install latest kernel failed, please check it."
            yellow "按回车键继续或Ctrl+c退出"
            read -s
        fi
        #[ ! -f "/boot/grub2/grub.cfg" ] && red "/boot/grub2/grub.cfg not found, please check it."
        #grub2-set-default 0
    else
        check_important_dependence_installed wget wget
        check_important_dependence_installed initramfs-tools
        get_latest_version
        local latest_kernel_version="${image_deb_name##*/}"
        latest_kernel_version="${latest_kernel_version%%_*}(${latest_kernel_version#*_}"
        latest_kernel_version="${latest_kernel_version%%_*})"
        tyblue "latest_kernel_version=${latest_kernel_version}"
        local temp_your_kernel_version
        temp_your_kernel_version="$(uname -r)($(dpkg --list | grep "$(uname -r)" | head -n 1 | awk '{print $3}'))"
        tyblue "your_kernel_version=${temp_your_kernel_version}"
        if [[ "${latest_kernel_version}" =~ "${temp_your_kernel_version}" ]]; then
            echo
            green "Info: Your kernel version is lastest"
            return 0
        fi
        rm -rf kernel_
        mkdir kernel_
        cd kernel_
        if ! ([ ${release} == "ubuntu" ] && version_ge "$systemVersion" 18.04) && ! ([ ${release} == "debian" ] && version_ge "$systemVersion" 10) && ! ([ ${release} == "deepin" ] && version_ge "$systemVersion" 20); then
            install_headers=0
        fi
        if ! wget -O "$real_image_deb_name" "$image_deb_url" || ! wget -O "$real_modules_deb_name" "$modules_deb_url"; then
            cd ..
            rm -rf kernel_
            red "下载内核失败！"
            exit 1
        fi
        if [ $install_headers -eq 1 ]; then
            if ! wget -O "$real_headers_all_deb_name" "$headers_all_deb_url" || ! wget -O "$real_headers_generic_deb_name" "$headers_generic_deb_url"; then
                cd ..
                rm -rf kernel_
                red "下载内核失败！"
                exit 1
            fi
        fi
        local check_temp=("$real_image_deb_name" "$real_modules_deb_name")
        [ $install_headers -eq 1 ] && check_temp+=("$real_headers_all_deb_name" "$real_headers_generic_deb_name")
        for i in "${!check_temp[@]}"
        do
            mkdir _check_temp
            if ! dpkg -x "${check_temp[$i]}" _check_temp; then
                cd ..
                rm -rf kernel_
                red "当前系统dpkg版本过低，不支持解压最新内核安装包"
                yellow "请使用新系统"
                exit 1
            fi
            rm -rf _check_temp
        done
        if ! dpkg -i ./*; then
            apt -y -f install
            cd ..
            rm -rf kernel_
            red "安装失败！"
            exit 1
        fi
        cd ..
        rm -rf kernel_
        apt -y -f install
    fi
    ask_if "是否卸载其余内核？(y/n)" && remove_kernel
    green "安装完成"
    yellow "系统需要重启"
    if ask_if "现在重启系统? (y/n)"; then
        reboot
    else
        yellow "请尽快重启！"
    fi
}

get_char() {
    SAVEDSTTY="$(stty -g)"
    stty -echo
    stty cbreak
    dd if=/dev/tty bs=1 count=1 2> /dev/null
    stty -raw
    stty echo
    stty "$SAVEDSTTY"
}
echo -e "\\n\\n\\n"
echo "---------- System Information ----------"
echo " Arch    : $(uname -m)"
echo " Kernel  : $(uname -r)"
echo "----------------------------------------"
echo " Auto install latest kernel"
echo
echo " URL: https://github.com/kirin10000/update-kernel"
echo "----------------------------------------"
echo "Press any key to start...or Press Ctrl+C to cancel"
get_char
update_kernel
