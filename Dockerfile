FROM searxng/searxng:latest

EXPOSE 8080

CMD ["/usr/local/searxng/dockerfiles/start.sh"]
