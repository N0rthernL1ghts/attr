FROM scratch

ADD --chmod=0777 src/attr.sh /usr/local/bin/attr

CMD ["/usr/local/bin/attr"]