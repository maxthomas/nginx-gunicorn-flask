# nginx-gunicorn-flask

FROM python:3

ENV DEBIAN_FRONTEND noninteractive

RUN python --version
RUN pip --version

RUN apt-get update -qq
RUN apt-get install -q -y nginx supervisor

# Setup flask application
RUN mkdir -p /deploy/app
COPY app /deploy/app

RUN pip install -r /deploy/app/requirements.txt
RUN pip install gunicorn

# Setup nginx
RUN rm /etc/nginx/sites-enabled/default
COPY flask.conf /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/flask.conf /etc/nginx/sites-enabled/flask.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Setup supervisord
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY gunicorn.conf /etc/supervisor/conf.d/gunicorn.conf

# Start processes
CMD ["/usr/bin/supervisord"]
