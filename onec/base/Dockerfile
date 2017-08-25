FROM onec32/baseimage:latest

ARG WEBHOST
ADD conf /distr/

RUN groupadd -r grp1cv8 --gid=1024 && useradd -r -m -g grp1cv8 --uid=1024 usr1cv8

VOLUME $RDATA
VOLUME $REPODATA
VOLUME $DESCRIPTORS

ENTRYPOINT ["dumb-init", "/distr/docker-entrypoint.sh"]

EXPOSE 1540:1590
EXPOSE 80

RUN curl http://$WEBHOST/client.deb32.tar.gz | tar xvz \
    && curl http://$WEBHOST/deb.tar.gz | tar xvz \
    && dpkg -i 1c*common_*.deb && dpkg -i 1c*server_*.deb && dpkg -i 1c*ws_*.deb  && dpkg -i 1c*crs_*.deb \
    && rm *.deb \
    && apt-get update && apt-get install -f -y \
    && apt-get remove -y ttf-mscorefonts-installer \
    && apt-get install -y ttf-mscorefonts-installer \
    && apt-get clean && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/tmp/* /tmp/* \
    && chmod +x /distr/docker-entrypoint.sh


CMD ["ragent"]
