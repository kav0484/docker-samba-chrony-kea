FROM ubuntu:21.04

ENV DEBIAN_FRONTEND noninteractive TZ=Europe/Moscow

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && apt install -y acl attr samba samba-dsdb-modules samba-vfs-modules winbind \
     libpam-winbind libnss-winbind libpam-krb5 krb5-config krb5-user bind9 supervisor \
     dnsutils chrony kea-dhcp4-server kea-ctrl-agent rsyslog mc ldb-tools iputils-ping

COPY ./conf/supervisord.conf /etc/supervisor/supervisord.conf 
COPY ./conf/bind/ /etc/bind/
COPY ./conf/chrony.conf /etc/chrony/chrony.conf

COPY entrypoint.sh entrypoint.sh

RUN mkdir -p /run/named && chown bind:bind /run/named && mkdir -p /run/kea

ENTRYPOINT [ "/entrypoint.sh" ]
