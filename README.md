# Apache with mod WSGI Docker image

[`ndegardin/apache-wsgi`](https://hub.docker.com/r/ndegardin/apache-wsgi/)

An image of an [Apache HTTP server](https://httpd.apache.org/) running the mod [wsgi](http://modwsgi.readthedocs.io/en/develop/).

The version tagged [`django`](https://hub.docker.com/r/ndegardin/apache-wsgi/tags/) contains the ['Django framework'](https://www.djangoproject.com/) and some other ['Python'](https://www.python.org/) dependencies pre-installed.

## Features

- Mod **wsgi**
- Mod **rewrite** (*.htaccess* files can be used)
- Logs redirected to the *standard/error*  output
- **Python 3.6**

## Usage

### To run the server by mounting the project directory

    docker run -p 80:80 --rm -v $(pwd):/srv ndegardin/apache-wsgi

### To create a container embedding the project

1. In the project folder, create a file `Dockerfile` containing:

    ```
    FROM ndegardin/apache-wsgi
    ```

2. Build the project image by running

    `docker build -t myprojectname`

3. Run the project container by running

    `docker run -p 80:80 --rm myprojectname`

## Notes

Do not run the container with the **Docker** option `-t`. This option will enable propagating the window resizing signal *SIGWINCH* to the **Apache** server, which interprets it as a termination signal. Consequently, the server would stop shortly after having started.

This container was originally designed to reproduce the setup of an online host, and debug the project configuration (embedded *mod_wsgi* over *Apache*, configuration through *.htaccess* files).