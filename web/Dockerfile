FROM centos:7

COPY server.py  /home/app/

RUN adduser app && \
    yum -y install python3-pip python36 && \
    yum -y clean all && \
    rm -Rf /var/cache/yum && \
    pip3 install --no-cache-dir bottle && \
    chmod +x /home/app/server.py && \
    chown -R app:app /home/app

# run container as user app
USER app

# tell the port number the container should expose
EXPOSE 5000

# run the application
ENTRYPOINT ["/home/app/server.py"]
