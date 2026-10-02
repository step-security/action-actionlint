FROM python:3.15.0rc2-alpine3.24@sha256:a73535961d3114b7b2e6948ef2dd8d295b885a76d3c23e87e688856713c1cbac

RUN apk --no-cache add git curl bash jq

COPY scripts scripts

# install pyflakes
RUN ./scripts/install-pyflakes.sh

# install shellcheck
RUN ./scripts/install-shellcheck.sh

# install actionlint
RUN OSTYPE=linux-gnu ./scripts/install-actionlint.sh

# install reviewdog
RUN ./scripts/install-reviewdog.sh

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
