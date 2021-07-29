=======
# docker-samba-chrony-kea-dhcp4

## Описание


## Переменные
1. SAMBA_ADMIN_PASSWORD DEFAULT Passw0rd
2. SAMBA_AD_REALM DEFAULT domain.local
3. SAMBA_AD_DOMAIN DEFAULT domain


## СОЗДАНИЕ НОВОГО ДОМЕНА
### Подготовка
1. Убедиться, что папка $PWD/data/etc/samba не содержит smb.conf и $PWD/data/var/samba полностью очищена
2. в файле $PWD/data/etc/kea/kea-dhcp4.conf добавить свои настройки

3. Запустить команду

```bash
docker run  -v $PWD/data/etc/samba:/etc/samba  -v $PWD/data/var/samba:/var/lib/samba \
  -v $PWD/data/log:/var/log -v $PWD/data/etc/kea:/etc/kea -v $PWD/data/var/kea:/var/lib/kea \
  -e SAMBA_ADMIN_PASSWORD=password -e SAMBA_AD_REALM DEFAULT=domain.local \
  -e SAMBA_AD_DOMAIN DEFAUL=domain  -h dc01 --net dc01_localnet --ip 192.168.0.4 --dns 127.0.0.1 \
  --dns 192.168.0.5  --privileged  --name dc01   -it ad-dc create_ad_domain
```


4. docker-compose up -d