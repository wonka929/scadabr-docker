# ██████╗  ██████╗ █████╗
# ██╔══██╗██╔════╝██╔══██╗
# ██║  ██║██║     ███████║
# ██║  ██║██║     ██╔══██║
# ██████╔╝╚██████╗██║  ██║
# ╚═════╝  ╚═════╝╚═╝  ╚═╝
# DEPARTAMENTO DE ENGENHARIA DE COMPUTACAO E AUTOMACAO
# UNIVERSIDADE FEDERAL DO RIO GRANDE DO NORTE, NATAL/RN
#
# (C) 2024 CARLOS M D VIEGAS
# https://github.com/cmdviegas

### Description:
# This script installs ScadaBR v1.2 with all requirements (Apache Tomcat 9 + JDK 8 + Python 3.10 + pyModbusTCP 0.2.1)

# Import base image
FROM ubuntu:22.04

# Label
LABEL org.opencontainers.image.authors="(C) 2024 CARLOS M D VIEGAS https://github.com/cmdviegas"

# Use bash as shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

## Update system and install required packages
# Local mirror
#RUN sed -i -e 's/http:\/\/archive\.ubuntu\.com\/ubuntu\//mirror:\/\/mirrors\.ubuntu\.com\/mirrors\.txt/' /etc/apt/sources.list

# BR Mirror
RUN sed --in-place --regexp-extended "s/(\/\/)(archive\.ubuntu)/\1br.\2/" /etc/apt/sources.list

RUN apt-get update -qq 
RUN DEBIAN_FRONTEND=noninteractive DEBCONF_NOWARNINGS=yes \
apt-get install -qq --no-install-recommends \
nano \
wget \
openjdk-8-jdk-headless \
python3.10-minimal \
python3-pip < /dev/null > /dev/null

# Clear apt cache and lists to reduce size
RUN apt clean && rm -rf /var/lib/apt/lists/*

# Creates symbolic link to make 'python' and 'python3' recognized as a system command
RUN ln -sf /usr/bin/python3.10 /usr/bin/python
RUN ln -sf /usr/bin/python /usr/bin/python3

# Set working dir
ENV MYDIR /root
WORKDIR ${MYDIR}

# Copy all files from local folder to container, except the ones in .dockerignore
COPY . .

# Download Tomcat 9
RUN wget -q -nc --no-check-certificate https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.104/bin/apache-tomcat-9.0.104.tar.gz
RUN tar -zxf apache-tomcat-*.tar.gz -C ${MYDIR} && rm -rf apache-tomcat-*.tar.gz
RUN ln -sf apache-tomcat-* tomcat

# Download ScadaBR
RUN wget -q -nc --no-check-certificate https://github.com/ScadaBR/ScadaBR/releases/download/v1.2/ScadaBR.war -P ${MYDIR}/tomcat/webapps/

# Install pyModbusTCP
RUN pip install pyModbusTCP==0.2.2

# Cleaning
RUN rm -rf /tmp/* /var/tmp/*

# Setting permission
RUN chmod 0700 start-services.sh

# Command to run at container start
ENTRYPOINT ${MYDIR}/start-services.sh
#CMD ["tomcat/bin/catalina.sh", "run"]
