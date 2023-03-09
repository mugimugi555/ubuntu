#!/usr/bin/bash

# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/install_crystaldiskmark.sh && bash install_crystaldiskmark.sh ;

#-----------------------------------------------------------------------------------------------------------------------
# install fio
#-----------------------------------------------------------------------------------------------------------------------
sudo aot update ;
sudo apt install -y fio ;

#-----------------------------------------------------------------------------------------------------------------------
# create template
#-----------------------------------------------------------------------------------------------------------------------
FIO_TEMPLATE=$(cat<<TEXT
[global]
ioengine=libaio
iodepth=1
size=100m
direct=1
runtime=60
directory=/tmp
stonewall

[Seq-Read]
bs=1m
rw=read

[Seq-Write]
bs=1m
rw=write

[Rand-Read-512K]
bs=512k
rw=randread

[Rand-Write-512K]
bs=512k
rw=randwrite

[Rand-Read-4K-QD32]
iodepth=32
bs=4k
rw=randread

[Rand-Write-4K-QD32]
iodepth=32
bs=4k
rw=randwrite

[Rand-Read-4K]
bs=4k
rw=randread

[Rand-Write-4K]
bs=4k
rw=randwrite
TEXT
)
echo "$FIO_TEMPLATE" > ~/fio.txt ;

#-----------------------------------------------------------------------------------------------------------------------
# do benchmark
#-----------------------------------------------------------------------------------------------------------------------
fio -f ~/fio.txt --output-format=terse | awk -F ';' '{print $3, ($7+$48) / 1000}' ;
