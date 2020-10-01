FROM lsiobase/alpine:3.11

# set version label
ARG BUILD_DATE
ARG VERSION
ARG SERVER_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	curl && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	nodejs \
	npm && \
 echo "**** install server ****" && \
 mkdir -p /app/server && \
 if [ -z ${SERVER_RELEASE+x} ]; then \
	SERVER_RELEASE=$(curl -sX GET "https://api.github.com/repos/Akkadius/eqemu-web-admin/commits/master" \
	| awk '/sha/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 	/tmp/server.tar.gz -L \
	"https://github.com/Akkadius/eqemu-web-admin/archive/${SERVER_RELEASE}.tar.gz" && \
 tar xf \
 	/tmp/server.tar.gz -C \
	/app/server/ --strip-components=1 && \
 cd /app/server && \
 npm install && \
 echo "**** install client ****" && \
 mkdir -p /tmp/client && \
 if [ -z ${CLIENT_RELEASE+x} ]; then \
	CLIENT_RELEASE=$(curl -sX GET "https://api.github.com/repos/Akkadius/eqemu-web-admin-client/commits/master" \
	| awk '/sha/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 	/tmp/client.tar.gz -L \
	"https://github.com/Akkadius/eqemu-web-admin-client/archive/${CLIENT_RELEASE}.tar.gz" && \
 tar xf \
 	/tmp/client.tar.gz -C \
	/tmp/client/ --strip-components=1 && \
 cd /tmp/client && \
 npm install && \
 npm run build && \
 mv /tmp/client/dist/* /app/server/public/ && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/root/.cache \
	/tmp/*

# copy local files
COPY root/ /
