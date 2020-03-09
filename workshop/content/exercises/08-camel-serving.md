This time we want to use Camel to create Knative Services. In order to do so, Camel-K needs to be intalled in our cluster, this is done by using its operator. You can use the Operator Hub in OpenShift webconsole to install the Camel-K operator, don't worry this has already been done for you.

After intalling the required operator, we still have to prepare the namespace, as follows:

```execute-1
kamel install --cluster-setup --skip-operator-setup -n labs-%userid%
```

Let's speed up the building time...

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app: camel-k
  name: camel-k-maven-settings
  namespace: labs-%userid%
data:
  settings.xml: |-
    <?xml version="1.0" encoding="UTF-8"?>
    <settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
https://maven.apache.org/xsd/settings-1.0.0.xsd">
      <localRepository></localRepository>
      <mirrors>
        <mirror>
          <id>central</id>
          <name>central</name>
          <url>http://nexus.lab-infra:8081/nexus/content/groups/public</url> 
          <mirrorOf>*</mirrorOf>
        </mirror>
      </mirrors>
      ...
    </settings>
```

If you want to edit the configuration to point to your Nexus edit the ConfigMap as explained as follows:

```copy
oc edit -n labs-%userid% cm camel-k-maven-settings
```

## Camel K Basics

At the end of this chapter you will be able to:

* Understand Camel-K deployment
* How to create Camel-K integration
* How to run using development mode
* How to add dependencies to Camel-K
* How to run your Camel-K integration in serverless mode

### Deploy a Camel K integration

What follows is a working Camel K integration sample defined with YAML. You can code integrations using also: XML, JS and Java.

```yaml
- from:
    uri: "timer:tick"  #1 Camel producer URI
    parameters:        #2 Setting up the producer
      period: "10s"
    steps:             #3 Flow 
      - set-body:      #4 Sets the body of the OUT message
          constant: "Welcome to Apache Camel K"
      - set-header:    #5 Sets headers
          name: ContentType
          simple: text/plain
      - transform:     #6 Apply transformations to the body
          simple: "${body.toUpperCase()}"
      - to:            #7 Sends out the message
          uri: "log:info?multiline=true&showAll=true"
```

Now let's deploy our Camel K integration by running:

> **NOTE:** We'll see the logs becauser we're running the integration in `dev` mode

```execute-1
kamel run --dev --dependency 'camel:log' ./scripts/descriptors/camel-timer.yaml
```

Watch the different phases executed before actually running the code:

* Initialization
* Building Kit (if no Integration Kit available for our integration)
* Deploying the integration
* Running the integration

```shell
kamel run --dev --dependency 'camel:log' ./scripts/descriptors/camel-timer.yaml
integration "camel-timer" created
Progress: integration "camel-timer" in phase Initialization
Progress: integration "camel-timer" in phase Building Kit
...
No IntegrationKitAvailable for Integration camel-timer: creating a new integration kit
Integration camel-timer in phase Building Kit
...
[1] 2020-03-09 11:28:50.786 INFO  [main] ApplicationRuntime - Listener org.apache.camel.k.listener.RoutesDumper@1c93084
c executed in phase Started
[1] 2020-03-09 11:28:51.851 INFO  [Camel (camel-k) thread #1 - timer://tick] info - Exchange[
[1]   Id: ID-camel-timer-6c4554f9bb-4qk2l-1583753331793-0-1
[1]   ExchangePattern: InOnly
[1]   Properties: {CamelCreatedTimestamp=Mon Mar 09 11:28:51 GMT 2020, CamelExternalRedelivered=false, CamelMessageHist
ory=[DefaultMessageHistory[routeId=route1, node=setBody1], DefaultMessageHistory[routeId=route1, node=setHeader1], Defa
ultMessageHistory[routeId=route1, node=transform1], DefaultMessageHistory[routeId=route1, node=to1]], CamelTimerCounter
=1, CamelTimerFiredTime=Mon Mar 09 11:28:51 GMT 2020, CamelTimerName=tick, CamelTimerPeriod=10000, CamelToEndpoint=log:
//info?multiline=true&showAll=true}
[1]   Headers: {ContentType=text/plain, firedTime=Mon Mar 09 11:28:51 GMT 2020}
[1]   BodyType: String
[1]   Body: WELCOME TO APACHE CAMEL K
[1] ]
...
```

Let's change the message and see how the change is hot reloaded!

```execute-2
sed -i 's/Camel K/Kamel/g' ./scripts/descriptors/camel-timer.yaml
```

Excerpt of the log after applying the change:

```sh
[2] 2020-03-09 11:45:40.316 INFO  [Camel (camel-k) thread #1 - timer://tick] info - Exchange[
[2]   Id: ID-camel-timer-5446c59f95-9jhtn-1583754220320-0-25
[2]   ExchangePattern: InOnly
[2]   Properties: {CamelCreatedTimestamp=Mon Mar 09 11:45:40 GMT 2020, CamelExternalRedelivered=false, CamelMessageHist
ory=[DefaultMessageHistory[routeId=route1, node=setBody1], DefaultMessageHistory[routeId=route1, node=setHeader1], Defa
ultMessageHistory[routeId=route1, node=transform1], DefaultMessageHistory[routeId=route1, node=to1]], CamelTimerCounter
=13, CamelTimerFiredTime=Mon Mar 09 11:45:40 GMT 2020, CamelTimerName=tick, CamelTimerPeriod=10000, CamelToEndpoint=log
://info?multiline=true&showAll=true}
[2]   Headers: {ContentType=text/plain, firedTime=Mon Mar 09 11:45:40 GMT 2020}
[2]   BodyType: String
[2]   Body: WELCOME TO APACHE KAMEL
[2] ]
```

You can also see the POD running your shiny integration.

```execute-2
oc get pod -n labs-%userid% | grep camel-timer
```

Ctrl+C to stop the integration and go on with the guide.

```execute-1
<ctrl+c>
```

## Deploy Camel-K Knative Integration

Any Camel-K integration can be converted into a serverless service using Knative. For an integration to be deployed as a Knative Service you need to use the Camel-K’s `knative` component.

The Camel-K Knative component provides two consumers: knative:endpoint and knative:channel. The former is used to deploy the integration as Knative Service, while the later is used to handle events from a Knative Event channel.

The Knative endpoints can be either a Camel producer or consumer depending on the context and need.

We wil now deploy a knative:endpoint consumer as part of your integration, that will add the serverless capabilities to your Camel-K integration using Knative.

The following listing shows a simple echoer Knative Camel-K integration, that will simply respond to your Knative Service call with same body that you sent into it in uppercase form. If there is no body received the service will respond with "no body received":

Echoer Integration

```yaml
- from:
    uri: "knative:endpoint/echoer" #1 Knative URI
    steps:
      - log:
          message: "Got Message: ${body}"
      - convert-body: "java.lang.String" 
      - choice:
          when:
            - simple: "${body} != null && ${body.length} > 0"
              steps:
                - set-body:
                    simple: "${body.toUpperCase()}"
                - set-header:
                    name: ContentType
                    simple: text/plain
                - log:
                    message: "${body}"
          otherwise:
            steps:
              - set-body:
                  constant: "no body received"
              - set-header:
                  name: ContentType
                  simple: text/plain
              - log:
                  message: "Otherwise::${body}"
```

Let's deploy our Camel K integration:

```execute-1
kamel run --wait --dependency camel:log --dependency camel:bean \
    ./scripts/descriptors/camel-echoer.yaml
```

Let's find out which is the knative url assigned to our integration. The url we're interested in is the one for the service named as the yaml file containing the code of the integration `camel-echoer`.

```execute-1
kn service list
```

Let's test it:

```execute-1
curl -v -X POST -d "Hello World" $(kn service describe camel-echoer -o json | jq -r .status.url)
```

While you wait have a look to the pods and see the pod being created.

```execute-2
watch oc get pod -n labs-%userid%
```

Once you're done testing it, please delete it.

```execute-1
kamel delete camel-echoer
```

Ctrl+C to stop watching and go on with the next step.

```execute-2
<ctrl+c>
```
