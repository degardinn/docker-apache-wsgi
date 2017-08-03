FROM alpine:3.6
LABEL author="Nicolas Degardin"

# Packages
RUN apk --update --no-cache add python3 python3-dev apache2 apache2-dev  wget ca-certificates make gcc musl-dev
RUN ln -s pip3 /usr/bin/pip 
RUN pip install -U pip setuptools wheel 

RUN apk --no-cache add sqlite mysql-client mariadb-dev jpeg-dev
RUN pip install -U pip django mysqlclient sqlite3client pgsql

# mod_wsgi compilation
RUN wget -O /tmp/mod_wsgi.tar.gz https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/modwsgi/mod_wsgi-3.4.tar.gz && \
    tar -C /tmp -xvf /tmp/mod_wsgi.tar.gz && \
    rm /tmp/mod_wsgi.tar.gz

WORKDIR /tmp/mod_wsgi-3.4
RUN ln -s /usr/lib/libpython3.6m.so /usr/lib/libpython3.6.so && \
    ./configure --with-python=/usr/bin/python3.6 --with-apxs=/usr/bin/apxs && \
    make && make install clean

WORKDIR /srv   
RUN rm -rf /tmp/mod_wsgi-3.4

# Apache conf
RUN sed -i -r 's@#(LoadModule rewrite_module modules/mod_rewrite.so)@\1@i' /etc/apache2/httpd.conf
RUN sed -i -r 's@Errorlog .*@Errorlog /dev/stderr@i' /etc/apache2/httpd.conf
RUN sed -i -r 's@#Servername.*@Servername wsgi@i' /etc/apache2/httpd.conf
RUN echo -e "Transferlog /dev/stdout\n\
LoadModule wsgi_module modules/mod_wsgi.so\n\
WSGIPythonPath /usr/lib/python3.6\n\
Alias / /srv/\n\
<Directory /srv>\n\
    Options ExecCGI Indexes FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
    AddHandler wsgi-script .wsgi\n\
</Directory>" >> /etc/apache2/httpd.conf
RUN mkdir -p /run/apache2

WORKDIR /srv
EXPOSE 80

ONBUILD COPY . /srv

CMD ["httpd", "-D", "FOREGROUND", "-e", "info"]
