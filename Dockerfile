FROM ubuntu:14.04
MAINTAINER Andres Rojas <andres@conpat.io>
ENV REFRESHED_AT 2015-04-05


# Install
RUN mkdir seafile
WORKDIR /seafile

RUN apt-get -qq update
RUN apt-get -qqy install wget python2.7 python-setuptools python-imaging sqlite3

RUN wget https://bitbucket.org/haiwen/seafile/downloads/seafile-server_4.1.2_x86-64.tar.gz
RUN tar -xzf seafile-server_4.1.2_x86-64.tar.gz

RUN mkdir installed
RUN mv seafile-server_4.1.2_x86-64.tar.gz installed


# Options
ENV SEAFILE_SERVER_NAME MySeafile
ENV SEAFILE_URI localhost
ENV SEAFILE_DATA_DIR /seafile/seafile-data
ENV SEAHUB_ADMIN_EMAIL foo@bar.com
ENV SEAHUB_ADMIN_PASS baz


# Configure
ENV SEAFILE_LD_LIBRARY_PATH /seafile/seafile-server-4.1.2/seafile/lib/:/seafile/seafile-server-4.1.2/seafile/lib64:${LD_LIBRARY_PATH}

RUN mkdir conf
COPY seafdav.conf conf/

WORKDIR /seafile/seafile-server-4.1.2
RUN LD_LIBRARY_PATH=$SEAFILE_LD_LIBRARY_PATH seafile/bin/ccnet-init --config-dir=/seafile/ccnet --name=$SEAFILE_SERVER_NAME --host=$SEAFILE_URI
RUN LD_LIBRARY_PATH=$SEAFILE_LD_LIBRARY_PATH seafile/bin/seaf-server-init --seafile-dir=$SEAFILE_DATA_DIR --port=12001 --fileserver-port=8082
RUN echo $SEAFILE_DATA_DIR > ../ccnet/seafile.ini
RUN echo "SECRET_KEY = \"$(python seahub/tools/secret_key_generator.py)\"" > ../seahub_settings.py

RUN sqlite3 ../seahub.db ".read seahub/sql/sqlite3.sql" 2>/dev/null 1>&2
RUN mkdir /seafile/seahub-data
RUN mv seahub/media/avatars ../seahub-data/avatars
RUN ln -s ../../../seahub-data/avatars seahub/media

WORKDIR /seafile
RUN ln -s seafile-server-4.1.2 seafile-server-latest
RUN chmod 0600 seahub_settings.py
RUN chmod 0700 ccnet seafile-data conf

RUN mkdir seafile-data/library-template
RUN cp -f seafile-server-4.1.2/seafile/docs/*.doc seafile-data/library-template

WORKDIR /seafile/seafile-server-4.1.2
COPY create_admin.py create_admin.py
RUN ./seafile.sh start && PYTHONPATH=/seafile/seafile-server-4.1.2/seafile/lib64/python2.6/site-packages CCNET_CONF_DIR=/seafile/ccnet python create_admin.py $SEAHUB_ADMIN_EMAIL $SEAHUB_ADMIN_PASS
RUN rm create_admin.py


# Run
EXPOSE 10001 12001 8082 8000

COPY start_services.sh start_services.sh

ENTRYPOINT ["/bin/bash"]
CMD ["start_services.sh"]
