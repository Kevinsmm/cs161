#!/bin/sh
if [[ $1 == remote ]]; then
    echo 'Connecting ucb cs161 autograde machine...'
    u=atw
    echo ssh -t cs161-$u@hive$((36#${u:2}%26+1)).cs.berkeley.edu \~cs161/proj1/start
    ssh -t cs161-$u@hive$((36#${u:2}%26+1)).cs.berkeley.edu \~cs161/proj1/start
else
    echo 'Connecting localhost...'
    #sshpass -p r4e8kWpeFC ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no  vsftpd@localhost -p 16161
    #sshpass -p 37ZFBrAPm8 ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no  smith@localhost -p 16161
    #sshpass -p mXFLFR5C62 ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no  brown@localhost -p 16161
    #sshpass -p cqkeuevfIO ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no  jz@localhost -p 16161
    sshpass -p Bw6eAWWXM8 ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no  jones@localhost -p 16161

fi
