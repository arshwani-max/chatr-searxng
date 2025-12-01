FROM searxng/searxng:latest

COPY ./settings.yml /etc/searxng/settings.yml
COPY ./uwsgi.ini /etc/searxng/uwsgi.ini

ENV UWSGI_HTTP=:8080
EXPOSE 8080
