green='\033[0;32m'

install_sing_box() {
    bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/sing-box-yes/master/install.sh) install
}

config_ss() {
    read -p "ss port:" port
    if [ -z $port ]; then
        port=8080
    fi
    echo The port is $port
    read -p "ss password:" password
    if [ -z $password ]; then
        password=$(openssl rand -base64 16)
    fi
    echo The password is $password
    cat >/usr/local/etc/sing-box/config.json <<EOF
{
    "log": {
        "disabled": false,
        "level": "warn",
        "timestamp": true
    },
    "inbounds": [
    {
        "type": "shadowsocks",
        "listen": "::",
        "listen_port": ${port},
        "method": "2022-blake3-aes-128-gcm",
        "password": "${password}"
    }
    ]
}
EOF
}

restart_ss() {
    bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/sing-box-yes/master/install.sh) restart
}

enable_bbr() {
    bash <(curl -Ls https://raw.githubusercontent.com/teddysun/across/master/bbr.sh)
}

get_sing_box_status() {
    bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/sing-box-yes/master/install.sh) status
}

install_ss() {
    install_sing_box
    config_ss
    restart_ss
    enable_bbr
}

auto_install_ss() {
    install_sing_box
    port=$1
    [ -z $port ] && port=8080
    password=$(openssl rand -base64 16)
    cat >/usr/local/etc/sing-box/config.json <<EOF
{
    "log": {
        "disabled": false,
        "level": "warn",
        "timestamp": true
    },
    "inbounds": [
    {
        "type": "shadowsocks",
        "listen": "::",
        "listen_port": ${port},
        "method": "2022-blake3-aes-128-gcm",
        "password": "${password}"
    }
    ]
}
EOF
    restart_ss
    enable_bbr
    cat >/usr/local/etc/sing-box/config.json
}

check_sing_box_status() {
    bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/sing-box-yes/master/install.sh) status
}

get_sing_box_log() {
    bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/sing-box-yes/master/install.sh) log
}

show_help() {
    echo -e "
${green}0.${plain} exit
${green}1.${plain} install sing-box-shadowsocks
${green}2.${plain} check ss status
${green}3.${plain} check ss log
"
    read -p "[0-3]:" num
    case "${num}" in
    0)
        exit
        ;;
    1)
        install_ss
        ;;
    2)
        get_sing_box_status
        ;;
    3)
        get_sing_box_log
        ;;
    esac
}

main() {
    if [[ $# > 0 ]]; then
        case $1 in
        "auto_install")
            auto_install_ss $2
            ;;
        esac
    else
        show_help
    fi
}

main $*
