Now, let's point our Kafka as a Source to the default broker instead of directly to a Knative Service.

Have another look to the next diagram this time pay attention to path ③.

![Lab Diagram](./images/lab-diagram.png "Lab Diagram")

First we need to update the KafkaSource we used before so that it point to the default broker.

> **Pay special attention to:**
> 
> * **spec->sink:** because now it's pointing to the `default` broker
> * **spec-> bootstrapServers and topics:** no changes with regards to the previous lab


```yaml
apiVersion: sources.eventing.knative.dev/v1alpha1
kind: KafkaSource
metadata:
  name: kafka-source
spec:
  consumerGroup: knative-group
  bootstrapServers: knative-cluster-kafka-bootstrap.labs-infra:9092 #note the kafka namespace
  topics: eventing
  sink:
    apiVersion: eventing.knative.dev/v1alpha1
    kind: Broker
    name: default
```

```execute-1
oc apply -f ./scripts/descriptors/kafka-source-to-channel.yml -n labs-%userid%
```

Let's test it by sending messages to our topic in kafka:

```execute-1
oc -n labs-%userid% delete pod kafka-producer
oc -n labs-%userid% run kafka-producer -ti --image=strimzi/kafka:0.14.0-kafka-2.3.0 --rm=true --restart=Never -- bin/kafka-console-producer.sh --broker-list knative-cluster-kafka-bootstrap.labs-infra:9092 --topic eventing
```

Now you can send events from the prompt. Copy the next text and paste it in the console where the kafka-producer is running.

```copy
{"message" : "Hi guys from kafka source through channel for user%userid%!!"}
```

Let's check if there's a new pod being created...

```execute-2
oc get pod -n labs-%userid% | grep logevents
```

Nope? That's because our trigger has a filter.

```yaml
filter:
  attributes:
      type: dev.knative.demo
      source: dev.knative.demo/simplesource
```

Let's update our trigger so that it has no filter.

```execute-2
oc apply -f ./scripts/descriptors/demo-trigger-no-filter.yml -n labs-%userid%
```

Now, go back to the kafka-producer and try again, this time you should see new pod being created...

```execute-2
oc get pod -n labs-%userid% | grep logevents
```

Finally let's have a quick look to the logs:

> Paste new messages at the kafka-producer prompt

```execute-2
oc logs -f $(oc get pod -n labs-%userid% | grep logevents | awk '{print $1}') -c user-container -n labs-%userid%
```

Ctrl+C (both consoles) when you're done with testing the trigger.

Upper:

```execute-1
<ctrl+c>
```
Lower:

```execute-2
<ctrl+c>
```