#!/bin/bash

# SPDX-FileCopyrightText: 2022 - 2023 Orthanc Team SRL <info@orthanc.team>
#
# SPDX-License-Identifier: CC0-1.0

# set -o xtrace
set -o errexit

# 도커 컴포즈 파일에서 해당 이미지를 빌드할 때 환경 변수로 리버스 프록시 허용 할 서비스 true로 보내 줄 거임.
enableOrthanc="${ENABLE_ORTHANC:-false}"
enableOrthancForApi="${ENABLE_ORTHANC_FOR_API:-false}"
enableOrthancForShares="${ENABLE_ORTHANC_FOR_SHARES:-false}"
enableKeycloak="${ENABLE_KEYCLOAK:-false}"
enableOrthancTokenService="${ENABLE_ORTHANC_TOKEN_SERVICE:-false}"
enableOhif="${ENABLE_OHIF:-false}"
enableHttps="${ENABLE_HTTPS:-false}"
enableMedDream="${ENABLE_MEDDREAM:-false}"

ls -al /etc/nginx/disabled-conf/

# 일단 통신을 HTTP로 할 지 HTTPS로 할 지 판단.
if [[ $enableHttps == "true" ]]; then
  echo "ENABLE_HTTPS is true -> will listen on port 443 and read certificate from /etc/nginx/tls/crt.pem and private key from /etc/nginx/tls/key.pem"
  cp -f /etc/nginx/disabled-conf/orthanc-nginx-https.conf /etc/nginx/conf.d/default.conf
else
  echo "ENABLE_HTTPS is false or not set -> will listen on port 80"
  cp -f /etc/nginx/disabled-conf/orthanc-nginx-http.conf /etc/nginx/conf.d/default.conf
fi

ls -al /etc/nginx/disabled-reverse-proxies/

# 사용 할 서비스들을 리버스 프록시 enabled 폴더에 옮김.
if [[ $enableOrthanc == "true" ]]; then
  echo "ENABLE_ORTHANC is true -> enable /orthanc/ reverse proxy"
  cp -f /etc/nginx/disabled-reverse-proxies/reverse-proxy.orthanc.conf /etc/nginx/enabled-reverse-proxies/
fi

if [[ $enableOrthancForApi == "true" ]]; then
  echo "ENABLE_ORTHANC_FOR_API is true -> enable /orthanc-api/ reverse proxy"
  cp -f /etc/nginx/disabled-reverse-proxies/reverse-proxy.orthanc-api.conf /etc/nginx/enabled-reverse-proxies/
fi

if [[ $enableOrthancForShares == "true" ]]; then
  echo "ENABLE_ORTHANC_FOR_SHARES is true -> enable /shares/ reverse proxy"
  cp -f /etc/nginx/disabled-reverse-proxies/reverse-proxy.shares.conf /etc/nginx/enabled-reverse-proxies/
fi

if [[ $enableKeycloak == "true" ]]; then
  echo "ENABLE_KEYCLOAK is true -> enable /keycloak/ reverse proxy"
  cp -f /etc/nginx/disabled-reverse-proxies/reverse-proxy.keycloak.conf /etc/nginx/enabled-reverse-proxies/
fi

if [[ $enableOrthancTokenService == "true" ]]; then
  echo "ENABLE_ORTHANC_TOKEN_SERVICE is true -> enable /token-service/ reverse proxy"
  cp -f /etc/nginx/disabled-reverse-proxies/reverse-proxy.token-service.conf /etc/nginx/enabled-reverse-proxies/
fi

if [[ $enableMedDream == "true" ]]; then
  echo "ENABLE_MEDDREAM is true -> enable /meddream/ reverse proxy"
  cp -f /etc/nginx/disabled-reverse-proxies/reverse-proxy.meddream.conf /etc/nginx/enabled-reverse-proxies/
fi

if [[ $enableOhif == "true" ]]; then
  echo "ENABLE_OHIF is true -> enable /ohif/ reverse proxy"
  cp -f /etc/nginx/disabled-reverse-proxies/reverse-proxy.ohif.conf /etc/nginx/enabled-reverse-proxies/
fi

# call the default nginx entrypoint
/docker-entrypoint.sh "$@"
