#!/bin/sh

echo "now execute script..."

# Optional ENV variables:
# * ADVERTISED_HOST: the external ip for the container, e.g. `docker-machine ip \`docker-machine active\``
# * ADVERTISED_PORT: the external port for Kafka, e.g. 9092
# * ZK_CHROOT: the zookeeper chroot that's used by Kafka (without / prefix), e.g. "kafka"

# * MY_ID: borker.id
# * ZOOKEEPER_SERVERS: zookeeper servers
# * LOG_RETENTION_HOURS: the minimum age of a log file in hours to be eligible for deletion (default is 168, for 1 week)
# * LOG_RETENTION_BYTES: configure the size at which segments are pruned from the log, (default is 1073741824, for 1GB)
# * NUM_PARTITIONS: configure the default number of log partitions per topic
# * AUTO_CREATE_TOPICS: [false|true]
# * REPLICATION_FACTOR: offsets.topic.replication.factor

if [ ! -z "$MY_ID" ]; then
    # configure kafka
    sed -r -i "s/(broker.id)=(.*)/\1=$MY_ID/g" $KAFKA_HOME/config/server.properties
else
    echo "MY_ID env miss, exit"
    exit 1
fi

# Set the zookeeper
if [ ! -z "$ZOOKEEPER_SERVERS" ]; then
    # configure kafka
    sed -r -i "s/(zookeeper.connect)=(.*)/\1=$ZOOKEEPER_SERVERS/g" $KAFKA_HOME/config/server.properties
else
    echo "ZOOKEEPER_SERVERS env miss, exit"
    exit 1
fi

# Allow specification of log retention policies
if [ ! -z "$LOG_RETENTION_HOURS" ]; then
    echo "log retention hours: $LOG_RETENTION_HOURS"
    sed -r -i "s/(log.retention.hours)=(.*)/\1=$LOG_RETENTION_HOURS/g" $KAFKA_HOME/config/server.properties
fi
if [ ! -z "$LOG_RETENTION_BYTES" ]; then
    echo "log retention bytes: $LOG_RETENTION_BYTES"
    sed -r -i "s/#(log.retention.bytes)=(.*)/\1=$LOG_RETENTION_BYTES/g" $KAFKA_HOME/config/server.properties
fi

if [ ! -z "$REPLICATION_FACTOR" ]; then
    echo "offsets.topic.replication.factor: $REPLICATION_FACTOR"
    sed -r -i "s/(offsets.topic.replication.factor)=(.*)/\1=$REPLICATION_FACTOR/g" $KAFKA_HOME/config/server.properties
fi

# Configure the default number of log partitions per topic
if [ ! -z "$NUM_PARTITIONS" ]; then
    echo "default number of partition: $NUM_PARTITIONS"
    sed -r -i "s/(num.partitions)=(.*)/\1=$NUM_PARTITIONS/g" $KAFKA_HOME/config/server.properties
fi

# Enable/disable auto creation of topics
if [ "$AUTO_CREATE_TOPICS" == "true" ]; then
    echo "auto.create.topics.enable: $AUTO_CREATE_TOPICS"
    echo "auto.create.topics.enable=true" >> $KAFKA_HOME/config/server.properties
fi

# Run Kafka
$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties
