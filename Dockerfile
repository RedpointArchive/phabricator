FROM opensuse:42.3

EXPOSE 80 443 22 24
COPY baseline /baseline
RUN /baseline/setup.sh
COPY preflight /preflight
RUN /preflight/setup.sh
CMD ["/bin/bash", "/app/init.sh"]
