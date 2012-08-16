#!/bin/bash
set -e -x
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
export DEBIAN_FRONTEND=noninteractive

yum -y update

# install as per VMWare 
rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-7.noarch.rpm
yum -y install erlang

rpm --import http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
wget http://www.rabbitmq.com/releases/rabbitmq-server/v2.8.4/rabbitmq-server-2.8.4-1.noarch.rpm
yum -y install ./rabbitmq-server-2.8.4-1.noarch.rpm


# it is important that rabbits eat lettuce 
echo 'rabbitseatlettuce' > /var/lib/rabbitmq/.erlang.cookie
chown rabbitmq:rabbitmq /var/lib/rabbitmq/.erlang.cookie
chmod 400 /var/lib/rabbitmq/.erlang.cookie

# add plugins
wget http://www.rabbitmq.com/releases/plugins/v2.8.2-web-stomp-preview/cowboy-0.5.0-rmq2.8.2-git4b93c2d.ez 
wget http://www.rabbitmq.com/releases/plugins/v2.8.2-web-stomp-preview/sockjs-0.2.1-rmq2.8.2-gitfa1db96.ez 
wget http://www.rabbitmq.com/releases/plugins/v2.8.2-web-stomp-preview/rabbitmq_web_stomp-2.8.2.ez 
wget http://www.rabbitmq.com/releases/plugins/v2.8.2-web-stomp-preview/rabbitmq_web_stomp_examples-2.8.2.ez

cp *.ez /usr/lib/rabbitmq/lib/rabbitmq_server-2.8.4/plugins

#enable plugins
#rabbitmq-plugins enable rabbitmq_shovel
#rabbitmq-plugins enable rabbitmq_management
#rabbitmq-plugins enable rabbitmq_stomp
#rabbitmq-plugins enable rabbitmq_web_stomp
#rabbitmq-plugins enable rabbitmq_web_stomp_examples
# or we could just create the plugins file
echo '[rabbitmq_shovel,rabbitmq_management,rabbitmq_stomp,rabbitmq_web_stomp,rabbitmq_web_stomp_examples].' > /etc/rabbitmq/enabled_plugins

# if we have EBS we should symlink the message store
#/var/lib/rabbitmq/
#/var/logs/rabbitmq/

# either way we have to restart rabbit
/etc/init.d/rabbitmq-server start
#/usr/sbin/rabbitmq-server -detached
# insert some clustering logic here...
sleep 2
/usr/sbin/rabbitmqctl stop_app
sleep 2
/usr/sbin/rabbitmqctl cluster rabbit@server-3569
sleep 2
/usr/sbin/rabbitmqctl start_app

chkconfig rabbitmq-server on

# done
