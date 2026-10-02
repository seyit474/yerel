#!/usr/bin/env bash
# Yerel CA + sunucu sertifikası üretir.
#   bash sertifika.sh            -> CA yoksa oluşturur, sunucu sertifikasını üretir
#   bash sertifika.sh --yenile   -> sadece sunucu sertifikasını yeniler (IP değişince otomatik çağrılır)
#   bash sertifika.sh --sifirla  -> CA dahil hepsini baştan üretir (cihazlara CA tekrar kurulmalı)
set -e
cd "$(dirname "$0")"
mkdir -p certs
command -v openssl >/dev/null || { echo "openssl yok: pkg install openssl-tool  (veya: pkg install openssl)"; exit 1; }

[ "$1" = "--sifirla" ] && rm -f certs/*

if [ ! -f certs/ca.key ]; then
  echo "• Yerel sertifika otoritesi (CA) oluşturuluyor..."
  openssl req -x509 -new -nodes -newkey rsa:2048 -sha256 -days 3650 \
    -keyout certs/ca.key -out certs/ca.crt -subj "/CN=Yerel Messenger CA/O=Yerel" \
    -addext "basicConstraints=critical,CA:TRUE" \
    -addext "keyUsage=critical,keyCertSign,cRLSign" 2>/dev/null
fi

IPS="$(node server.js --ips 2>/dev/null || true)"
SAN="DNS:localhost,IP:127.0.0.1"
for ip in $IPS $EKSTRA_IP; do SAN="$SAN,IP:$ip"; done

cat > certs/ext.cnf <<EOF
basicConstraints=CA:FALSE
keyUsage=critical,digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth
subjectAltName=$SAN
EOF

openssl req -new -nodes -newkey rsa:2048 -keyout certs/server.key -out certs/server.csr -subj "/CN=Yerel Messenger" 2>/dev/null
openssl x509 -req -in certs/server.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial \
  -out certs/server.crt -days 397 -sha256 -extfile certs/ext.cnf 2>/dev/null
rm -f certs/server.csr
echo "• Sunucu sertifikası hazır: $SAN"
