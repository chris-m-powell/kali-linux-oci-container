# #####################################################
# change the ssh port in /etc/ssh/sshd_config
# When you use the bridge network, then you would
# not have to do that. You could rather add a port
# mapping argument such as -p 2022:22 to the 
# docker create command. But we might as well
# use the host network and port 22 might be taken
# on the docker host. Hence we change it 
# here inside the container
# #####################################################

FROM docker.io/kalilinux/kali-rolling

ARG SSH_PORT
ARG RDP_PORT

ENV DEBIAN_FRONTEND noninteractive

RUN apt update -q --fix-missing \
  && apt upgrade -y \
  && apt install -y --no-install-recommends sudo wget curl dbus-x11 xinit openssh-server kali-desktop-xfce \
  && echo "#!/bin/bash" > /startkali.sh \
  && echo "/etc/init.d/ssh start" >> /startkali.sh \
  && chmod 755 /startkali.sh \
  && apt install -y --no-install-recommends kali-linux-core \
  && useradd -m -s /bin/bash -G sudo kali \
  && echo 'kali:kali' | chpasswd \
  && echo "Port $SSH_PORT" >>/etc/ssh/sshd_config \
  && apt -y install --no-install-recommends xorg xorgxrdp xrdp \
  && echo "/etc/init.d/xrdp start" >> /startkali.sh \
  && sed -i s/^port=3389/port=${RDP_PORT}/ /etc/xrdp/xrdp.ini \
  && echo "/bin/bash" >> /startkali.sh

EXPOSE ${SSH_PORT} ${RDP_PORT}
WORKDIR "/root"
ENTRYPOINT ["/bin/bash"]
CMD ["/startkali.sh"]
