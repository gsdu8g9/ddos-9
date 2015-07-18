#!/bin/bash
## Script To Check & Block DDOS ##
## Written : 17 DEC 2014 ##
## V2 On 18 July 2015 ##
## By Qasim

[ -d /var/log/ddos ] || mkdir /var/log/ddos

netstat -plan|grep :80|awk {'print $5'}|cut -d: -f 1| grep -E -o "\b[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\b" | sort|uniq -c|sort -nk 1 | tail -n 20 > /var/log/ddos/RTIPADR
IPADR=`ifconfig | grep "inet addr" |awk '{print $2}' | grep -v 127 | cut -d : -f 2 > /var/log/ddos/IPADR`
grep -Ff /var/log/ddos/IPADR -v /var/log/ddos/RTIPADR  > /var/log/ddos/Alpha
for i in {1..20}; do
	IPADR=`sed -n "$i"p /var/log/ddos/Alpha | awk '{print $2}'`
	Connections=`sed -n "$i"p /var/log/ddos/Alpha | awk '{print $1}'`
	if [[ $Connections -ge 1200 ]]; then
		csf -d $IPADR
	fi
done

grep $(date "+%d/%b/%Y") /usr/local/apache/logs/access_log | awk '{print $1}' | sort | uniq -c | sort -nk 1 | tail -n 200 > /var/log/ddos/ddosApacheAL.txt
grep -Ff /var/log/ddos/IPADR -v /var/log/ddos/ddosApacheAL.txt  > /var/log/ddos/ddosApacheALEx.txt
for dAal in {1..200}; do
NOFL=`sed -n "$dAal"p /var/log/ddos/ddosApacheALEx.txt |  awk '{print $1}'`
BIP=`sed -n "$dAal"p /var/log/ddos/ddosApacheALEx.txt |  awk '{print $2}'`
if [[ $NOFL -ge 10000 ]]; then
	csf -d $BIP
fi
done
