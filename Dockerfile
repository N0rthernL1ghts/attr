FROM --platform=${TARGETPLATFORM} alpine:3.14

COPY src/attr.sh /usr/local/bin/attr
RUN chmod +x /usr/local/bin/attr

CMD ["/usr/local/bin/attr"]