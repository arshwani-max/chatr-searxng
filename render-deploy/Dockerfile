FROM searxng/searxng:latest

COPY settings.yml /etc/searxng/settings.yml

RUN chmod 644 /etc/searxng/settings.yml

EXPOSE 8080

CMD ["granian", "--interface", "searxng.webapp.app", "--host", "0.0.0.0", "--port", "8080"]
