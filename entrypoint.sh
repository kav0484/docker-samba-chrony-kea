#!/bin/bash

set -e

SAMBA_ADMIN_PASSWORD=${SAMBA_ADMIN_PASSWORD-Passw0rd}
SAMBA_AD_REALM=${SAMBA_AD_REALM-domain.local}
SAMBA_AD_DOMAIN=${SAMBA_AD_DOMAIN-domain}



create_directory(){
    if ! [ -d /var/lib/samba/ntp_signd ];then
        mkdir /var/lib/samba/ntp_signd
        chmod 750 /var/lib/samba/ntp_signd
    fi

    if ! [ -d /var/lib/samba/winbindd_privileged ];then
        mkdir /var/lib/samba/winbindd_privileged
        chmod 750 /var/lib/samba/winbindd_privileged
    fi

}

restore() {
    if [[ -f /var/lib/samba/backup.acl ]];then
        setfacl --restore=/var/lib/samba/backup.acl
    else
        chown root:bind /var/lib/samba/bind-dns
        chown root:_chrony /var/lib/samba/ntp_signd
        chown root:winbindd_priv /var/lib/samba/winbindd_privileged
        chown root:3000000 /var/lib/samba/sysvol
        
    fi
    create_directory
    cp -f /var/lib/samba/private/krb5.conf /etc/krb5.conf
    
}


create_new_domain() {
    if [ -f /etc/samba/smb.conf -o  $(find /var/lib/samba/*|wc -l) != 0 ];then
    echo "Please delete first files /etc/samba/smb.conf and /var/lib/samba/*"
    exit 0
    fi
    
    samba-tool domain provision --use-rfc2307 --domain=$SAMBA_AD_DOMAIN --realm=$SAMBA_AD_REALM --server-role=dc  --dns-backend=BIND9_DLZ --adminpass=$SAMBA_ADMIN_PASSWORD

    create_directory
    getfacl -R /var/lib/samba > /var/lib/samba/backup.acl
    cp -f /var/lib/samba/private/krb5.conf /etc/krb5.conf

}

join_as_dc() {
    if [ -f /etc/samba/smb.conf  -o $(find /var/lib/samba/*|wc -l) != 0 ];then
    echo "Please delete first files /etc/samba/smb.conf and /var/lib/samba/*"
    exit 0
    fi

    samba-tool domain join --option='idmap_ldb:use rfc2307 = yes' --dns-backend=BIND9_DLZ  $SAMBA_AD_REALM DC -U"$SAMBA_AD_DOMAIN\Administrator" --password=$SAMBA_ADMIN_PASSWORD

    create_directory
    getfacl -R /var/lib/samba > /var/lib/samba/backup.acl
    cp -f /var/lib/samba/private/krb5.conf /etc/krb5.conf

}

start() {
    cp -f /var/lib/samba/private/krb5.conf /etc/krb5.conf
    supervisord

}

case $1 in
    create_new_domain)
        create_new_domain
        ;;
    join_as_dc)
        join_as_dc
	;;
    restore)
        echo "restore"
	;;
    *)
    start
    ;;
esac