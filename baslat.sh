#!/usr/bin/env bash
# Yerel Messenger — sunucuyu başlatır. Durdurmak: Ctrl+C
cd "$(dirname "$0")"
command -v termux-wake-lock >/dev/null && termux-wake-lock
trap 'command -v termux-wake-unlock >/dev/null && termux-wake-unlock' EXIT
while true; do
  node server.js "$@"
  code=$?
  [ $code -eq 0 ] || [ $code -eq 130 ] && break
  echo "Sunucu kapandı (kod $code), 3 sn sonra yeniden başlatılıyor..."
  sleep 3
done
