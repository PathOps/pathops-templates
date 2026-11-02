# The application image: the static files of app/ served by BusyBox httpd as a
# non-root user on port 8080 (GET /healthz answers "ok"). Context = the
# repository root:
#   docker build -f .pathops/build/Dockerfile .
FROM docker.io/library/busybox:1.37.0@sha256:a7dbc319b1438115a207e11930dc4bb3e643dcb3ec0bdd694bb36cd8fad289ec
COPY app/ /www/
USER 65532:65532
EXPOSE 8080
ENTRYPOINT ["httpd", "-f", "-v", "-p", "8080", "-h", "/www"]
