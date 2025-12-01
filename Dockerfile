FROM python:3.11

WORKDIR /app

COPY src /app
COPY searxng/settings.yml /etc/searxng/settings.yml
COPY chatr_categories.delhi_ncr.json /etc/searxng/chatr_categories.delhi_ncr.json

RUN pip install --upgrade pip && \
    pip install -r requirements.txt

EXPOSE 8080

CMD ["python3", "-m", "searx.webapp"]
