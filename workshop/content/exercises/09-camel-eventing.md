So far we have tested Camel K alone, also with Knative Serving. So, what's left? Eventing with Camel K.

If you remember we have used Eventing before, specifically we have used a source of events `KafkaSource`. Maybe you're wondering if there is an easy way to know which source are available... Indeed, please execute:

```execute-1
oc api-resources --api-group=sources.eventing.knative.dev
```

Ok, let's get started. As you have already guessed we're going to use a CamelSource.

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  labels:
    contrib.eventing.knative.dev/release: "v0.12.0"
  name: event-display
spec:
  runLatest:
    configuration:
      revisionTemplate:
        spec:
          container:
            image: gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/event_display@sha256:a214514d6ba674d7393ec8448dd272472b2956207acb3f83152d3071f0ab1911
```

Here is the Camel Source we're going to create. It's essentially the same code we used before but embedded in a CamelSource in `spec->source->flow`.

```yaml
apiVersion: sources.eventing.knative.dev/v1alpha1  ①
kind: CamelSource
metadata:
  name: timed-greeter
spec:
  integration: ②
    dependencies:
      - camel:log
  source: ③
    flow:
      from:
        uri: "timer:tick"
        parameters:
          period: "10s"
        steps:
          - set-body:
              constant: "Welcome to Apache Camel-K"
          - set-header:
              name: ContentType
              simple: text/plain
          - transform:
              simple: "${body.toUpperCase()}"
          - log:
              message: "${body}"
  sink: ④
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: logevents
```

1. The CamelSource is provided by the API sources.eventing.knative.dev, it is now available as a result of deploying the CamelSource event source.
2. The CamelSource spec has two main sections: integration and source. The integration block is used to configure the Camel-K integration specific properties such as dependencies, traits, etc. In this example we add the required dependencies such as camel:log, it is the dependency that you earlier passed via kamel CLI.
3. The source block is used to define the Camel-K integration definition. The flow attribute of the source block allows you define the Camel route.
4. The event sink for messages from the Camel event source. The sink could be either a Knative Service, Knative Event Channel or Knative Event Broker. In this case it is configured to be the event-display Knative Service.

Let's deploy the CamelSource.

```execute-1
oc apply -n labs-%userid% -f ./scripts/descriptors/camel-timer-source-to-service.yaml
```

Let's have a look to the CamelSources and check if ours is in Ready status.

```execute-1
watch oc -n labs-%userid% get camelsources
```

When the camel source is successfully running you will see it in "READY" state True:

```sh
NAME            READY   AGE
timed-greeter   True    114s
```

Finally let's have a quick look to the logs:

```execute-2
oc logs -f $(oc get pod -n labs-%userid% | grep logevents | awk '{print $1}') -c user-container -n labs-%userid%
```
