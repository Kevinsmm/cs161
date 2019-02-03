#!/bin/sh
#echo 'Use password r4e8kWpeFC'
#ssh vsftpd@localhost -p 16161
sshpass -p r4e8kWpeFC ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no  vsftpd@localhost -p 16161
