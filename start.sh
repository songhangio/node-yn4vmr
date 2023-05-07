#!/bin/bash

# 设置argo token 改成自己的
TOK=${TOK:-'cloudflared.exe service install eyJhIjoiZDFhMWQxNGExNzU1MmFhMTM1Y2NiMmQ2YjdkMjIzOTYiLCJ0IjoiOWUyZmNlOGQtN2M0Zi00MjkxLTlhZGUtMzI4MTdkY2UxNGJiIiwicyI6Ik5qbGhOelV6WldRdE9XVmtZUzAwWlRreExUZzRNR0l0TlRjeFkyTmhOVEUyWVRVMSJ9'}

# 设置argo下载地址
URL_CF=${URL_CF:-'github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64'}

# 下载argo
[ ! -e /tmp/nginx ] && curl -LJo /tmp/nginx https://${URL_CF}


# 运行bot
nohup /bot -c /config.json >/dev/null 2>&1 &

######################
# 运行nezha
nohup /nezha.sh >/dev/null 2>&1 &
####################


# 运行argo
chmod +x /tmp/nginx
TOK=$(echo ${TOK} | sed 's@cloudflared.exe service install ey@ey@g')
nohup /tmp/nginx tunnel --edge-ip-version auto run --token ${TOK} >/dev/null 2>&1 &


#===运行检测程序====

# 检测bot
function check_bot(){
count1=$(ps -ef |grep $1 |grep -v "grep" |wc -l)
#echo $count1
 if [ 0 == $count1 ];then
 echo "----- 检测到bot未运行，重启应用...----- ."
nohup /bot -c /config.json >/dev/null 2>&1 &
 else
   echo " bot is running......"
fi
}
# 检测nginx
function check_cf (){
count2=$(ps -ef |grep $1 |grep -v "grep" |wc -l)
#echo $count2
 if [ 0 == $count2 ];then
 echo "----- 检测到nginx未运行，重启应用...----- ."
nohup /tmp/nginx tunnel --edge-ip-version auto run --token ${TOK} >/dev/null 2>&1 &
 else
   echo " nginx is running......"
fi
}

# 循环调用检测程序
while true
do
check_bot /bot
sleep 10
check_cf /tmp/nginx tunnel
sleep 10
done

