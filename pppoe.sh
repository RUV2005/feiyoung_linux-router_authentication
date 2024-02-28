#!/bin/sh
#重启网络接口
/etc/init.d/network restart
#延迟等待一分钟
sleep 1m
#固定参数(账号密码)
userprofile="/bin/userprofile.txt"
#版本相关(设备版本)
edition="/bin/edition.ini"
#初始化参数
init() {
    user=`cat $userprofile | grep -vE "^#" | grep user= |awk -F= '{print $2}'`
    fyxml=`curl -H "Accept: */*" -H "User-Agent:CDMA+WLAN(Maod)" -H "Accept-Language: zh-Hans-CN;q=1" -H "Accept-Encoding: gzip, deflate" -H "Connection: keep-alive" -H "Content-Type:application/x-www-form-urlencoded" -L "http://100.64.0.1"`
    fylgurl=`echo $fyxml | awk -v head="CDATA[" -v tail="]" '{print substr($0, index($0,head)+length(head),index($0,tail)-index($0,head)-length(head))}'`
    usmac=`echo $fyxml | awk -v head="sermac=" -v tail="&wlanacname" '{print substr($0, index($0,head)+length(head),index($0,tail)-index($0,head)-length(head))}'`
    acname=`echo $fyxml | awk -v head="wlanacname=" -v tail="&wlanuserip" '{print substr($0, index($0,head)+length(head),index($0,tail)-index($0,head)-length(head))}'`
    usip=`echo $fyxml | awk -v head="wlanuserip=" -v tail="]" '{print substr($0, index($0,head)+length(head),index($0,tail)-index($0,head)-length(head))}'`
    AidcAuthAttr1=`echo $fyxml | awk -v head="Attr1>" -v tail="</Aidc" '{print substr($0, index($0,head)+length(head),index($0,tail)-index($0,head)-length(head))}'`
    system=`cat $edition | grep -vE "^#" | grep system |awk '{print $2}'`
    prefix=`cat $edition | grep -vE "^#" | grep prefix |awk '{print $2}'`
    AidcAuthAttr3=`cat $edition | grep -vE "^#" | grep AidcAuthAttr3 |awk '{print $2}'`
    AidcAuthAttr4=`cat $edition | grep -vE "^#" | grep AidcAuthAttr4 |awk '{print $2}'`
    AidcAuthAttr5=`cat $edition | grep -vE "^#" | grep AidcAuthAttr5 |awk '{print $2}'`
    AidcAuthAttr6=`cat $edition | grep -vE "^#" | grep AidcAuthAttr6 |awk '{print $2}'`
    AidcAuthAttr8=`cat $edition | grep -vE "^#" | grep AidcAuthAttr8 |awk '{print $2}'`
    AidcAuthAttr15=`cat $edition | grep -vE "^#" | grep AidcAuthAttr15 |awk '{print $2}'`
    AidcAuthAttr22=`cat $edition | grep -vE "^#" | grep AidcAuthAttr22 |awk '{print $2}'`
    AidcAuthAttr23=`cat $edition | grep -vE "^#" | grep AidcAuthAttr23 |awk '{print $2}'`
}

#登陆
login() {
    lgg=`echo "curl -d \"&createAuthorFlag=0&UserName=${prefix}${user}&Password=${passwd}&AidcAuthAttr1=${AidcAuthAttr1}&AidcAuthAttr3=${AidcAuthAttr3}&AidcAuthAttr4=${AidcAuthAttr4}&AidcAuthAttr5=${AidcAuthAttr5}&AidcAuthAttr6=${AidcAuthAttr6}&AidcAuthAttr8=${AidcAuthAttr8}&AidcAuthAttr15=${AidcAuthAttr15}&AidcAuthAttr22=${AidcAuthAttr22}&AidcAuthAttr23=${AidcAuthAttr23}\" -H \"User-Agent: ${system}\" -H \"Content-Type: application/x-www-form-urlencoded\"  \"${fylgurl}\"" | sh`
    result=`echo $lgg | awk -v head="ReplyMessage>" -v tail="</ReplyMessage" '{print substr($0, index($0,head)+length(head),index($0,tail)-index($0,head)-length(head))}'`
}
heart() {
    sys="CDMA+WLAN(Maod)"
    hht=`echo "curl -d \"\" -H \"User-Agent: ${sys}\" -H \"Content-Type: application/x-www-form-urlencoded\"  \"http://58.53.199.146:8007/Hv6_dW\" " | sh`
    ht=echo $hht
}
#连接
main() {
    #状态检测
    ping -c 3 114.114.114.114 >/dev/null
        if [  $? -eq 0  ];then
            echo "已登陆"
            heart
            echo $hht
        else
            echo "未登录，正在连接"
            init
                day=`echo ${AidcAuthAttr1:6:2} | sed -r 's/^0*([^0]+|0)$/\1/'`
                day="^$day="
                passwd=`cat $userprofile | grep -vE "^#" | grep -E $day |awk -F= '{print $2}' `
                login
                echo $result
                echo 用户账号:$user
                echo 用户密码:$passwd
                echo 用户mac地址:$usmac
                echo 用户ip地址:$usip
                echo 学校feiyoung服务器地址:$acname
                echo feiyoung服务器时间:$AidcAuthAttr1
        fi
}
main $@
