#!/data/data/com.termux/files/usr/bin/bash
sleep 10
crond
echo "Termux:Boot triggered at $(date)" >> ~/logs/boot.log
