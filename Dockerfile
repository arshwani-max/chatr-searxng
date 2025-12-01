FROM searxng/searxng:latest
COPY searxng/settings.yml /etc/searxng/settings.yml
COPY chatr_categories.delhi_ncr.json /etc/searxng/chatr_categories.delhi_ncr.json
EXPOSE 8080
CMD ["/usr/local/searxng/dockerfiles/start.sh"]
