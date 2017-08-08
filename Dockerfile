FROM alpine:3.6
LABEL author="Nicolas Degardin"

# Packages
RUN apk --update --no-cache add python3 python3-dev apache2 apache2-dev  wget ca-certificates make gcc musl-dev
RUN ln -s pip3 /usr/bin/pip 
RUN pip install -U pip setuptools wheel 

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

# Specific packages
RUN apk --no-cache add sqlite mysql-client mariadb-dev jpeg-dev freetype freetype-dev libpng libpng-dev g++
RUN pip install -U pip "aiohttp==1.0.5" "async-timeout==1.2.1" "bleach==2.0.0" "chardet==3.0.4" "click==6.7" "cycler==0.10.0" \
    "decorator==4.0.11" "discord.py==0.16.8" "django-debug-toolbar==1.8" "django-jinja==2.3.1" "django==1.10.5" "entrypoints==0.2.3" "flask==0.12.2" \
    "gspread==0.6.2" "html5lib==0.999999999" "ipykernel==4.6.1" "ipython-genutils==0.2.0" "ipython==6.1.0" "ipywidgets==6.0.0" "itsdangerous==0.24" \
    "jedi==0.10.2" "jinja2==2.9.6" "jsonschema==2.6.0" "jupyter-client==5.0.1" "jupyter-console==5.1.0" "jupyter-core==4.3.0" "jupyter==1.0.0" "markupsafe==1.0" \
    "matplotlib==2.0.2" "mistune==0.7.4" "multidict==3.1.3" "mysqlclient==1.3.10" "nbconvert==5.2.1" "nbformat==4.3.0" "notebook==5.0.0" "numpy==1.13.0" \
    "pandas==0.20.2" "pandocfilters==1.4.1" "pexpect==4.2.1" "pickleshare==0.7.4" "pillow>=3.0" "postmarker==0.8.1" "prompt-toolkit==1.0.14" "ptyprocess==0.5.1" \
    "pygments==2.2.0" "pyparsing==2.2.0" "python-dateutil==2.6.0" "pytz==2017.2" "pyzmq==16.0.2" "qtconsole==4.3.0" "requests==2.13.0" "setuptools==28.8.0" \
    "simplegeneric==0.8.1" "six==1.10.0" "sqlparse==0.2.3" "terminado==0.6" "testpath==0.3.1" "tornado==4.5.1" "traitlets==4.3.2" "wcwidth==0.1.7" \
    "webencodings==0.5.1" "websockets==3.3" "werkzeug==0.12.2" "widgetsnbextension==2.0.0"

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
