#!/bin/bash

export IPT="iptables"

# WAN
export WAN=eno2

# LAN 
export LAN=eno1

# Очищаем правила
$IPT -F
$IPT -F -t nat
$IPT -F -t mangle
$IPT -X
$IPT -t nat -X
$IPT -t mangle -X

# Запрещаем все по-умолчанию
$IPT -P INPUT DROP
$IPT -P OUTPUT DROP
$IPT -P FORWARD DROP

# Разрешаем подключение к этому серверу из localhost и локальной сети по SSН, логируем соединения по SSH
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A INPUT -i $LAN -s 192.168.10.0/24 -p tcp --dport 22 -m conntrack --ctstate NEW -j LOG --log-prefix "iptables: SSH NEW CONNECTION FROM LAN " --log-level info
$IPT -A INPUT -i $LAN -s 192.168.10.0/24 -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT

# Разрешаем любые подключения этого сервера в локальную сеть и localhost
$IPT -A OUTPUT -o lo -j ACCEPT
$IPT -A OUTPUT -o LAN -j ACCEPT

# Разрешаем пинги
#$IPT -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
#$IPT -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
#$IPT -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
#$IPT -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
#$IPT -A OUTPUT -p icmp -j ACCEPT

# Разрешаем исходящие подключения сервера в сторону WAN
$IPT -A OUTPUT -o $WAN -j ACCEPT

# Разрешаем любые установленные подключения
$IPT -A INPUT -p all -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
$IPT -A OUTPUT -p all -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
$IPT -A FORWARD -p all -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Отбрасываем неопознанные пакеты
$IPT -A INPUT -m conntrack --ctstate INVALID -j DROP
$IPT -A FORWARD -m conntrack --ctstate INVALID -j DROP

# Отбрасываем нулевые пакеты
$IPT -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

# Закрываемся от 
$IPT -A INPUT -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
$IPT -A OUTPUT -p tcp ! --syn -m conntrack --ctstate NEW -j DROP

# Блокируем доступ с указанных адресов (если таковые имеются)
# $IPT -A INPUT -s 192.168.10.22 -j REJECT

# ----------------------

# Разрешаем SSL подключения к почтовому серверу
#$IPT -A INPUT -i $LAN -s 192.168.10.0/24 -p tcp -m multiport --dports 465,993,995 -m conntrack --ctstate NEW -j LOG --log-prefix "iptables: MAILSERVER NEW CONNECT " --log-level info
#$IPT -A INPUT -i $LAN -s 192.168.20.0/24 -p tcp -m multiport --dports 465,993,995 -m conntrack --ctstate NEW -j ACCEPT

# Разрешаем подключение к postfixadmin, roundcube
# HTTP
#$IPT -A INPUT -i $LAN -s 192.168.10.0/24 -p tcp --dport 80 -m conntrack --ctstate NEW -j LOG --log-prefix "iptables: HTTP NEW CONNECT " --log-level info
#$IPT -A INPUT -i $LAN -s 192.168.10.0/24 -p tcp --dport 80 -m conntrack --ctstate NEW -j ACCEPT
# HTTPS
#$IPT -A INPUT -i $LAN -s 192.168.10.0/24 -p tcp --dport 443 -m conntrack --ctstate NEW -j LOG --log-prefix "iptables: HTTPS NEW CONNECT " --log-level info
#$IPT -A INPUT -i $LAN -s 192.168.10.0/24 -p tcp --dport 443 -m conntrack --ctstate NEW -j ACCEPT

# Перенаправление для запросов из внутренней сети
#$IPT -t nat -I PREROUTING -i $LAN -p tcp --dport 2233 -j DNAT --to-destination 127.0.0.1:22
#$IPT -A INPUT -i $LAN -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT

# $IPT -t nat -A POSTROUTING -o $WAN -j MASQUERADE
#$IPT -t nat -A POSTROUTING -o $WAN -j SNAT --to-source 172.16.100.1

# Логирование пакетов политики по умолчанию
$IPT -A INPUT -j LOG --log-prefix "iptables: INPUT DROP " --log-level info
$IPT -A OUTPUT -j LOG --log-prefix "iptables: OUTPUT DROP " --log-level info
$IPT -A FORWARD -j LOG --log-prefix "iptables: FORWARD DROP " --log-level info

