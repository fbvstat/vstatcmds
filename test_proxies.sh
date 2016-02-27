#!/bin/bash

#Definition variables
pushd `dirname $0` > /dev/null
parent_directory=`pwd`
popd > /dev/null
proxy_list=`cat $parent_directory/proxy_urls`
urls_list=`cat $parent_directory/domain_urls`
mon_url="http://statreceiver.hrenbet.com"
curl_options="--max-time 3 --retry 2 --retry-delay 2"
src_ip=`curl ifconfig.io`

for proxy in $proxy_list; do
        proxy_ip=`echo $proxy | cut -f 1 -d ":"`
        proxy_prt=`echo $proxy | cut -f 2 -d ":"`
        proxy_hostname=`echo $proxy | cut -f 3 -d ":"`
        for url in $urls_list; do
                cmd=`curl $curl_options --proxy $proxy_ip:$proxy_prt http://$url/robots.txt | grep -c fon`
                echo -e $cmd
                curl -i -XPOST "$mon_url/write?db=fbps" --data-binary "get,host_dmn=$url,host_proxy=$proxy_hostname,src_ip=$src_ip value=$cmd"
        done
done

