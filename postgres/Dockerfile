# vim:set ft=dockerfile:
FROM ubuntu:xenial
# explicitly set user/group IDs
RUN groupadd -r postgres --gid=999 && useradd -r -g postgres --uid=999 postgres

RUN test -n "$HTTP_PROXY" && echo "Acquire::http::Proxy \"${HTTP_PROXY}\";" >> /etc/apt/apt.conf.d/01proxy || echo "" >> /etc/apt/apt.conf.d/01proxy

RUN echo /etc/apt/apt.conf.d/01proxy && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget lsb-release \
        && apt-get install -y locales wget gosu language-pack-en language-pack-ru language-pack-uk \
        && localedef -i uk_UA -c -f UTF-8 -A /usr/share/locale/locale.alias uk_UA.UTF-8 \
        && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8 \
        && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
        && update-locale LANG=ru_RU.UTF-8
# make the "ru_RU.UTF-8" locale so postgres will be utf-8 enabled by default      
ENV LANG ru_RU.UTF-8
ENV LC_MESSAGES "en_US.UTF-8"

RUN mkdir /docker-entrypoint-initdb.d

#RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

ENV PG_MAJOR 9.6
#ENV PG_VERSION 9.4.5-1.pgdg80+1

RUN sh -c 'echo "deb http://1c.postgrespro.ru/deb/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/postgrespro-1c.list' \
        && wget --quiet -O - http://1c.postgrespro.ru/keys/GPG-KEY-POSTGRESPRO-1C | apt-key add - && apt-get update \
        && apt-get install -y postgresql-pro-1c-$PG_MAJOR

RUN mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql

ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
ENV PGDATA /var/lib/postgresql/data
VOLUME /var/lib/postgresql/data

COPY docker-entrypoint.sh /

# добавил установку powa мониторига от dabo https://github.com/dalibo/docker 
WORKDIR /usr/local/src

RUN apt-get update && apt-get install -y \
    gcc \
    jq \
    make \
    postgresql-contrib-pro-1c-$PG_MAJOR \
    postgresql-server-dev-pro-1c-$PG_MAJOR \
    postgresql-plpython-pro-1c-$PG_MAJOR \
    wget \
    && wget -O- $(wget -O- https://api.github.com/repos/dalibo/powa-archivist/releases/latest|jq -r '.tarball_url') | tar -xzf - \
    && wget -O- $(wget -O- https://api.github.com/repos/dalibo/pg_qualstats/releases/latest|jq -r '.tarball_url') | tar -xzf - \
    && wget -O- $(wget -O- https://api.github.com/repos/dalibo/pg_stat_kcache/releases/latest|jq -r '.tarball_url') | tar -xzf - \
    && wget -O- $(wget -O- https://api.github.com/repos/dalibo/hypopg/releases/latest|jq -r '.tarball_url') | tar -xzf - \
    && wget -O- $(wget -O- https://api.github.com/repos/rjuju/pg_track_settings/releases/latest|jq -r '.tarball_url') | tar -xzf - \
    && for f in $(ls); do cd $f; make install; cd ..; rm -rf $f; done \
    && apt-get purge -y --auto-remove gcc jq make postgresql-server-dev-pro-1c-$PG_MAJOR wget \
    && rm -rf /var/lib/apt/lists/* && rm -rf /etc/apt/apt.conf.d/01proxy

# configure powa-archivist
ADD setup_powa-archivist.sh /docker-entrypoint-initdb.d/
ADD install_all.sql /usr/local/src/


ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 5432
CMD ["postgres"]
