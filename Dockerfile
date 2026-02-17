# Single base image as requested
FROM golang:1.25.5-alpine3.23@sha256:26111811bc967321e7b6f852e914d14bede324cd1accb7f81811929a6a57fea9

# Versions
ENV SHELLCHECK_VERSION=v0.11.0 \
    REVIEWDOG_VERSION=v0.21.0 \
    ACTIONLINT_VERSION=v1.7.11

# System deps: build tools, git, curl, wget, xz for .tar.xz, python & pip
RUN set -eux; \
    apk add --no-cache \
      git curl wget xz \
      build-base \
      python3 py3-pyflakes

# Install ShellCheck (prebuilt tarball matching arch)
RUN set -eux; \
    arch="$(uname -m)"; \
    echo "arch is ${arch}"; \
    if [ "${arch}" = "armv7l" ]; then arch='armv6hf'; fi; \
    url_base='https://github.com/koalaman/shellcheck/releases/download'; \
    tar_file="${SHELLCHECK_VERSION}/shellcheck-${SHELLCHECK_VERSION}.linux.${arch}.tar.xz"; \
    wget -q "${url_base}/${tar_file}" -O - | tar xJf -; \
    mv "shellcheck-${SHELLCHECK_VERSION}/shellcheck" /usr/local/bin/; \
    rm -rf "shellcheck-${SHELLCHECK_VERSION}"; \
    /usr/local/bin/shellcheck --version

# Build reviewdog from exact tag
RUN set -eux; \
    git clone --depth 1 --branch "${REVIEWDOG_VERSION}" https://github.com/reviewdog/reviewdog.git /tmp/reviewdog; \
    cd /tmp/reviewdog; \
    go mod edit -require=golang.org/x/crypto@v0.45.0; \
    go mod edit -require=golang.org/x/oauth2@v0.27.0 || true; \
    go mod tidy; \
    go build -trimpath -ldflags "-s -w" -o /usr/local/bin/reviewdog ./cmd/reviewdog; \
    /usr/local/bin/reviewdog -version || true; \
    rm -rf /tmp/reviewdog

# Build actionlint from exact tag
RUN set -eux; \
    git clone --depth 1 --branch "${ACTIONLINT_VERSION}" https://github.com/rhysd/actionlint.git /tmp/actionlint; \
    cd /tmp/actionlint; \
    go build -trimpath -ldflags "-s -w" -o /usr/local/bin/actionlint ./cmd/actionlint; \
    /usr/local/bin/actionlint --version; \
    rm -rf /tmp/actionlint

# Add entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
