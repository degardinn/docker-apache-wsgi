FROM alpine:3.6
LABEL author="Nicolas Degardin"

RUN apk --update --no-cache add python3 python3-dev apache2-mod-wsgi apache2-dev gcc musl-dev

# Python
RUN ln -s pip3 /usr/bin/pip 
RUN pip install -U pip setuptools wheel mod_wsgi

# Apache
RUN sed -i -r 's@#(LoadModule rewrite_module modules/mod_rewrite.so)@\1@i' /etc/apache2/httpd.conf
RUN sed -i -r 's@Errorlog .*@Errorlog /dev/stderr@i' /etc/apache2/httpd.conf
RUN sed -i -r 's@#Servername.*@Servername wsgi@i' /etc/apache2/httpd.conf
RUN echo -e "Transferlog /dev/stdout\n\
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
