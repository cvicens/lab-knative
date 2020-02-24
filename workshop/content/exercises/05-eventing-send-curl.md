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

```ececute-1
oc expose svc default-broker -n labs-%userid%
```


```execute-2
<ctrl+c>
```

Have a closer look to the diagram, we're going to follow path ①. But before we can send a message using *curl* we need to expose the broker.


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

```ececute-1
oc apply -f ./scripts/descriptors/event-display-ksvc.yml -n labs-%userid%
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

```ececute-1
oc apply -f ./scripts/descriptors/demo-trigger-filter-simplesource -n labs
```

Test our serverless service sending events directly to the default broker:

```ececute-1
curl -v http://default-broker-labs-%userid%.%cluster_subdomain%/ -H "Ce-specversion: 1.0" -H "Ce-Type: dev.knative.demo" -H "Ce-Id: 45a8b444-3213-4758-be3f-540bf93f85ff" -H "Ce-Source: dev.knative.demo/simplesource" -H 'Content-Type: application/json' -d '{ "message": "Hi there!!" }'
```

Let's check if there's a new pod being created...

```execute-2
oc get pod -n labs-%userid% | grep logevents
```


