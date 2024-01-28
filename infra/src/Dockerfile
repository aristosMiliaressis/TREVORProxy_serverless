FROM alpine:latest

ARG SSH_KEY

RUN mkdir -p /root/.ssh \
    && chmod 0700 /root/.ssh

RUN apk add --update --no-cache openssh \
    && echo "$SSH_KEY" > /root/.ssh/authorized_keys \
    && echo -e "PasswordAuthentication no" >> /etc/ssh/sshd_config \
    && sed -i 's/GatewayPorts no/GatewayPorts yes/' /etc/ssh/sshd_config \ 
    && sed -i 's/AllowTcpForwarding no/AllowTcpForwarding yes/' /etc/ssh/sshd_config \
    && ssh-keygen -A

EXPOSE 22

CMD /usr/sbin/sshd -D -e "$@"
