#!/bin/bash
set -e -x
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
export DEBIAN_FRONTEND=noninteractive

apt-get update && apt-get upgrade -y

# update sources to include rabbit's latest releases
cat <<EOF > /etc/apt/sources.list.d/rabbitmq.list
deb http://www.rabbitmq.com/debian/ testing main
EOF

curl http://www.rabbitmq.com/rabbitmq-signing-key-public.asc -o /tmp/rabbitmq-signing-key-public.asc
apt-key add /tmp/rabbitmq-signing-key-public.asc
rm /tmp/rabbitmq-signing-key-public.asc

apt-get -qy update
apt-get -qy install rabbitmq-server

# shh we are hunting wabbits
sleep 5
pkill -u rabbitmq

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
#/etc/init.d/rabbitmq-server start
/usr/sbin/rabbitmq-server -detached

# done
