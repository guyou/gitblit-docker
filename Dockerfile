# Basics
#
from debian:wheezy
maintainer Guilhem Bonnefille <guilhem.bonnefille@gmail.com>

run apt-get update

# Install Java 7

# On wheezy, default-jre is 1.6 while gitblit requires 1.7
# run apt-get install -qqy default-jre
run apt-get install -qqy openjdk-7-jre-headless

# Install Gitblit

run apt-get install -q -y curl
run curl -Lks http://dl.bintray.com/gitblit/releases/gitblit-1.6.2.tar.gz -o /root/gitblit.tar.gz
run mkdir -p /opt/gitblit
run tar zxf /root/gitblit.tar.gz -C /opt/gitblit
run rm -f /root/gitblit.tar.gz

# Move the data files to a separate directory
run mkdir -p /var/lib/gitblit/data
run mv /opt/gitblit/data/* /var/lib/gitblit/data

# Adjust the default Gitblit settings to bind to 80, 443, 9418, 29418, and allow RPC administration.
run sed -e "s/server\.httpsPort\s=\s8443/server\.httpsPort=443/" \
        -e "s/server\.httpPort\s=\s0/server\.httpPort=80/" \
        -e "s/server\.redirectToHttpsPort\s=\sfalse/server\.redirectToHttpsPort=true/" \
        -e "s/web\.enableRpcManagement\s=\sfalse/web\.enableRpcManagement=true/" \
        -e "s/web\.enableRpcAdministration\s=\sfalse/web.enableRpcAdministration=true/" \
        -i /var/lib/gitblit/data/gitblit.properties

# Setup the Docker container environment and run Gitblit
workdir /opt/gitblit
expose 80
expose 443
expose 9418
expose 29418
volume ["/var/lib/gitblit/data"]
cmd ["java", "-server", "-Xmx1024M", "-Djava.awt.headless=true", "-jar", "/opt/gitblit/gitblit.jar", "--baseFolder", "/var/lib/gitblit/data"]
