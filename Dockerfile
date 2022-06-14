# This file is basically the one from n8n's docker/images/n8n/Dockerfile but
# using root as user - in tandem with entrypoint.sh.

FROM node:14.15-alpine

EXPOSE 5678/tcp

ARG N8N_VERSION

RUN if [ -z "$N8N_VERSION" ] ; then \
        echo "The N8N_VERSION argument is missing!" ; \
        exit 1 ; \
    fi

# Update everything and install needed dependencies
RUN apk add --update \
            git \
            graphicsmagick \
            tini \
            tzdata

# Install n8n and the temporary packages
# it needs to build it correctly.
RUN apk --update add \
        --virtual build-dependencies \
            build-base \
            ca-certificates \
            python \
    && npm_config_user=root npm install -g full-icu n8n@${N8N_VERSION} \
    && apk del build-dependencies \
	&& rm -rf /root /tmp/* /var/cache/apk/* \
    && mkdir /root

# Install fonts
RUN apk --no-cache add \
        --virtual fonts \
            msttcorefonts-installer \
            fontconfig \
    && update-ms-fonts \
    && fc-cache -f \
    && apk del fonts \
    && find /usr/share/fonts/truetype/msttcorefonts/ -type l -exec unlink {} \; \
	&& rm -rf /root /tmp/* /var/cache/apk/* \
    && mkdir /root

ENV NODE_ICU_DATA /usr/local/lib/node_modules/full-icu

WORKDIR /data

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["tini", "--", "/entrypoint.sh"]
