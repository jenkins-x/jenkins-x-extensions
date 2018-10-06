FROM scratch
EXPOSE 8080
ENTRYPOINT ["/jenkins-x-extensions"]
COPY ./bin/ /