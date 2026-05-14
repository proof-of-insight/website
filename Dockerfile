FROM caddy:2-alpine

COPY Caddyfile /etc/caddy/Caddyfile
COPY index.html /srv/index.html
COPY step.schema.json /srv/step.schema.json

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
