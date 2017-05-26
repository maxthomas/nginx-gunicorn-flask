# nginx-gunicorn-flask

FROM cabeceo/debunk

RUN apt-get update -qq && \
    apt-get install -qq -y python python-pip python-virtualenv nginx supervisor

# Setup flask application
RUN mkdir -p /deploy/app && virtualenv /deploy/venv
COPY app /deploy/app
RUN source /deploy/venv/bin/activate && \
    pip install --upgrade pip && \
    pip install -r /deploy/app/requirements.txt

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
