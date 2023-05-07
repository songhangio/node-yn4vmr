#!/usr/bin/env bash

# 哪吒的四个参数
NEZHA_SERVER=data.841013.xyz
NEZHA_PORT=443
NEZHA_KEY=dF4oYQJfSzEXADnDff
NEZHA_TLS=--tls

# 检测是否已运行
check_run() {
  [[ $(pgrep -laf nezha-agent) ]] && echo "哪吒客户端正在运行中!" && exit
}

# 三个变量不全则不安装哪吒客户端
check_variable() {
  [[ -z "${NEZHA_SERVER}" || -z "${NEZHA_PORT}" || -z "${NEZHA_KEY}" ]] && exit
}

# 下载最新版本 Nezha Agent
download_agent() {
  if [ ! -e nezha-agent ]; then
    URL=$(wget -qO- -4 "https://api.github.com/repos/naiba/nezha/releases/latest" | grep -o "https.*linux_amd64.zip")
    wget -t 2 -T 10 -N ${URL}
    unzip -qod ./ nezha-agent_linux_amd64.zip && rm -f nezha-agent_linux_amd64.zip
  fi
}

#################

chmod +x /nezha-agent


# 运行客户端
run() {
  TLS='--tls'
  [[ ! $PROCESS =~ nezha-agent && -e nezha-agent ]] && nohup ./nezha-agent -s ${NEZHA_SERVER}:${NEZHA_PORT} -p ${NEZHA_KEY} ${TLS} >/dev/null 2>&1 &
}

check_run
check_variable
download_agent
run

