Knative Eventing is meant to help you defining Event Sources that can trigger your serverless workloads easily.

Next diagram shows the key elements in Knative Eventing architecture and the lab itself.

![Lab Diagram](./images/lab-diagram.png "Lab Diagram")

In this first part we're going to use the default broker which persistency is `in memory` (IMC - In Memory Channel). Instead of deploying a broker ourselves we're going to label our namespace so that the Knative Eventing Operator deploys it on our behalf.

```execute-1
oc label namespace labs-%userid% knative-eventing-injection=enabled
```

Let's watch how the default broker is created.

```execute-2
watch oc get pod -n labs-%userid%
```

Once the default broker is up and running you should see this.

```
default-broker-filter-b944cfc76-7ssxh     1/1     Running   0          2m49s
default-broker-ingress-5ccfb6bb74-5mtwf   1/1     Running   0          2m49s
```

Ctrl+C to stop watching and go on with the next step.

```execute-2
<ctrl+c>
```

Have a closer look to the diagram, we're going to follow path ①. But before we can send a message using *curl* we need to expose the broker.

```execute-1
oc expose svc default-broker -n labs-%userid%
```

Now we have to deploy a new Knative Service (*logevents*).

```yaml
apiVersion: serving.knative.dev/v1alpha1 
kind: Service
metadata:
  name: logevents
spec:
  template:
    spec:
      containers:
      - image: docker.io/matzew/event-display 
```

```execute-1
oc apply -f ./scripts/descriptors/event-display-ksvc.yml -n labs-%userid%
```

Let's check if our service has been created.

```execute-1
oc get ksvc/logevents -n labs-%userid%
```

Next we have to create a Trigger so that link events of type *dev.knative.demo* and source *dev.knative.demo/simplesource* to our service *logevents*.

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  name: demo-trigger
spec:
  broker: default
  filter:
    attributes:
       type: dev.knative.demo
       source: dev.knative.demo/simplesource
  subscriber:
    ref:
      apiVersion: v1
      kind: Service
      name: logevents
```

Create trigger (*subscription*):

```execute-1
oc apply -f ./scripts/descriptors/demo-trigger-filter-simplesource.yml -n labs-%userid%
```

Test our serverless service sending events directly to the default broker:

```execute-1
curl -v http://default-broker-labs-%userid%.%cluster_subdomain%/ -H "Ce-specversion: 1.0" -H "Ce-Type: dev.knative.demo" -H "Ce-Id: 45a8b444-3213-4758-be3f-540bf93f85ff" -H "Ce-Source: dev.knative.demo/simplesource" -H 'Content-Type: application/json' -d '{ "message": "Hi there!!" }'
```

You should receive a 202 response code as in here.

```
...
> Ce-Type: dev.knative.demo
> Ce-Id: 45a8b444-3213-4758-be3f-540bf93f85ff
> Ce-Source: dev.knative.demo/simplesource
> Content-Type: application/json
> Content-Length: 27
>
* upload completely sent off: 27 out of 27 bytes
< HTTP/1.1 202 Accepted
< Content-Length: 0
< Date: Mon, 24 Feb 2020 12:10:08 GMT
< Set-Cookie: 6a644d0f586293fab89b4811360fd917=216e7609768a9605b309620f70f420a0; path=/; HttpO
nly
<
* Connection #0 to host default-broker-labs-1.apps.cluster-kharon-ba75.kharon-ba75.example.ope
ntlc.com left intact
...
```

Let's check if there's a new pod being created...

```execute-2
oc get pod -n labs-%userid% | grep logevents
```

Finally let's have a quick look to the logs:

> Go back and run the `curl` command as many times as you want.

```execute-2
oc logs -f $(oc get pod -n labs-%userid% | grep logevents | awk '{print $1}') -c user-container -n labs-%userid%
```

Ctrl+C when you're done with testing the trigger.

```execute-2
<ctrl+c>
```