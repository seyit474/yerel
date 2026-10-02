#!/usr/bin/env bash
# Yerel Messenger — Termux kurulumu (tek seferlik)
set -e
cd "$(dirname "$0")"
if command -v pkg >/dev/null; then
  echo "• Paketler kuruluyor (nodejs, openssl, qrencode)..."
  pkg update -y >/dev/null 2>&1 || true
  pkg install -y nodejs
  pkg install -y openssl 2>/dev/null || pkg install -y openssl-tool
  pkg install -y libqrencode 2>/dev/null || true
  pkg install -y termux-api 2>/dev/null || true
else
  command -v node >/dev/null || { echo "Node.js gerekli (https://nodejs.org)"; exit 1; }
fi
bash sertifika.sh
chmod +x baslat.sh sertifika.sh
echo
echo "✓ Kurulum tamam. Başlatmak için:  bash baslat.sh"
