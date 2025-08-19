ARG BUILD_TIMESTAMP

FROM scratch

ADD --chmod=0777 src/attr.sh /usr/local/bin/attr

ARG BUILD_TIMESTAMP
LABEL maintainer="Aleksandar Puharic <aleksandar@puharic.com>" \
      org.opencontainers.image.source="https://github.com/N0rthernL1ghts/attr" \
      org.opencontainers.image.description="Small utility intended to provide chmod/chown the-right-way" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="2.0" \
      org.opencontainers.image.title="attr" \
      org.opencontainers.image.url="https://github.com/N0rthernL1ghts/attr" \
      org.opencontainers.image.documentation="https://github.com/N0rthernL1ghts/attr/README.md" \
      org.opencontainers.image.created="${BUILD_TIMESTAMP}" \
      org.opencontainers.image.authors="Aleksandar Puharic <aleksandar@puharic.com>" \
      org.opencontainers.image.vendor="Northern Lights"

CMD ["/usr/local/bin/attr"]