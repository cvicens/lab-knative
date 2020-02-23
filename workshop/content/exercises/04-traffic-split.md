Now let's imagine you want deploy a new version and split traffic between the old one and the new one.

Pay attention to these annotations they define howwe want to splif traffic:

> **EXPLAIN!!!!**

```yaml
traffic:
- tag: current
  revisionName: customer-v3
  percent: 50
- tag: candidate
  revisionName: customer-v4
  percent: 50
- tag: latest
  latestRevision: true
  percent: 0
```

This is the descriptor `customer-traffic-split.yml`:

> VERSION environment variable changed to v4

```yaml
apiVersion: serving.knative.dev/v1alpha1 # Current version of Knative
kind: Service
metadata:
  name: customer
spec:
  template:
    metadata:
      name: customer-v4
    spec:
      containers:
        - image: quay.io/dsanchor/customer:quarkus
          env:
            - name: VERSION
              value: "v4"
          volumeMounts:
            - name: configuration
              mountPath: /deployments/config
      volumes:
        - name: configuration
          configMap:
            name: customer
  traffic:
  - tag: current
    revisionName: customer-v3
    percent: 50
  - tag: candidate
    revisionName: customer-v4
    percent: 50
  - tag: latest
    latestRevision: true
    percent: 0
```

As usual, let's apply this descriptor using a shell script.

```execute-1
bash ./scripts/deploy-customer-traffic-split.sh labs-%userid% %cluster_subdomain%
```

Again, as we changed a service (knative) a new revision is created, let's have a look:

```execute-2
oc get revisions -n labs-%userid%
```

Let's have a look to the different objects we have created, directly or indirectly...

> Kubernetes native objects: pay attention to how many of these are there... and we didn't create them ourselves ;-)

```execute-2
oc get services -n labs-%userid%
```

> Knative Routes: pay special attention to the customer route

```execute-2
kn route list -n labs-%userid%
```

Let's have a look to the istio virtual services in our namespace... we didn't create these either... cool, right?

You'll find the next virtual services:

- customer
- customer-mesh
- preference
- preference-mesh
- recommendation
- recommendation-mesh

```execute-2
oc get virtualservices -n labs-%userid%
```

Customer virtual service:

> Pay attention to spec->gateways, you'll find that there are two of them:
> 
> * knative-serving/cluster-local-gateway <== This one **IS NOT** exposed
> * knative-serving/knative-ingress-gateway <== This one **IS** exposed

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  annotations:
    networking.knative.dev/ingress.class: istio.ingress.networking.knative.dev
    serving.knative.dev/creator: user1
    serving.knative.dev/lastModifier: user1
  labels:
    serving.knative.dev/route: customer
    serving.knative.dev/routeNamespace: labs-1
  name: customer
  namespace: labs-1
spec:
  gateways:
  - knative-serving/cluster-local-gateway
  - knative-serving/knative-ingress-gateway
  hosts:
  - candidate-customer.labs-1
  - candidate-customer.labs-1.apps.cluster-kharon-ba75.kharon-ba75.example.opentlc.com
  - candidate-customer.labs-1.svc
  - candidate-customer.labs-1.svc.cluster.local
  - current-customer.labs-1
  - current-customer.labs-1.apps.cluster-kharon-ba75.kharon-ba75.example.opentlc.com
  - current-customer.labs-1.svc
  - current-customer.labs-1.svc.cluster.local
  - customer.labs-1
  - customer.labs-1.apps.cluster-kharon-ba75.kharon-ba75.example.opentlc.com
  - customer.labs-1.svc
  - customer.labs-1.svc.cluster.local
  - latest-customer.labs-1
  - latest-customer.labs-1.apps.cluster-kharon-ba75.kharon-ba75.example.opentlc.com
  - latest-customer.labs-1.svc
  - latest-customer.labs-1.svc.cluster.local
  http:
  - headers:
      request:
        add:
          K-Network-Hash: 0c76f9b0437ffc645948c5dc08403800
    match:
    - authority:
        prefix: customer.labs-1.apps.cluster-kharon-ba75.kharon-ba75.example.opentlc.com
      gateways:
      - knative-serving/knative-ingress-gateway
    - authority:
        prefix: customer.labs-1
      gateways:
      - knative-serving/cluster-local-gateway
    retries:
      attempts: 3
      perTryTimeout: 600s
    route:
    - destination:
        host: customer-v3.labs-1.svc.cluster.local
        port:
          number: 80
      headers:
        request:
          add:
            Knative-Serving-Namespace: labs-1
            Knative-Serving-Revision: customer-v3
      weight: 50
    - destination:
        host: customer-v4.labs-1.svc.cluster.local
        port:
          number: 80
      headers:
        request:
          add:
            Knative-Serving-Namespace: labs-1
            Knative-Serving-Revision: customer-v4
      weight: 50
    timeout: 600s
    websocketUpgrade: true
  - headers:
      request:
        add:
          K-Network-Hash: 0c76f9b0437ffc645948c5dc08403800
    match:
    - authority:
        prefix: candidate-customer.labs-1.apps.cluster-kharon-ba75.kharon-ba75.example.opentlc.com
      gateways:
      - knative-serving/knative-ingress-gateway
    - authority:
        prefix: candidate-customer.labs-1
      gateways:
      - knative-serving/cluster-local-gateway
    retries:
      attempts: 3
      perTryTimeout: 600s
    route:
    - destination:
        host: customer-v4.labs-1.svc.cluster.local
        port:
          number: 80
      headers:
        request:
          add:
            Knative-Serving-Namespace: labs-1
            Knative-Serving-Revision: customer-v4
      weight: 100
    timeout: 600s
    websocketUpgrade: true
  - headers:
      request:
        add:
          K-Network-Hash: 0c76f9b0437ffc645948c5dc08403800
    match:
    - authority:
        prefix: current-customer.labs-1.apps.cluster-kharon-ba75.kharon-ba75.example.opentlc.com
      gateways:
      - knative-serving/knative-ingress-gateway
    - authority:
        prefix: current-customer.labs-1
      gateways:
      - knative-serving/cluster-local-gateway
    retries:
      attempts: 3
      perTryTimeout: 600s
    route:
    - destination:
        host: customer-v3.labs-1.svc.cluster.local
        port:
          number: 80
      headers:
        request:
          add:
            Knative-Serving-Namespace: labs-1
            Knative-Serving-Revision: customer-v3
      weight: 100
    timeout: 600s
    websocketUpgrade: true
  - headers:
      request:
        add:
          K-Network-Hash: 0c76f9b0437ffc645948c5dc08403800
    match:
    - authority:
        prefix: latest-customer.labs-1.apps.cluster-kharon-ba75.kharon-ba75.example.opentlc.com
      gateways:
      - knative-serving/knative-ingress-gateway
    - authority:
        prefix: latest-customer.labs-1
      gateways:
      - knative-serving/cluster-local-gateway
    retries:
      attempts: 3
      perTryTimeout: 600s
    route:
    - destination:
        host: customer-v4.labs-1.svc.cluster.local
        port:
          number: 80
      headers:
        request:
          add:
            Knative-Serving-Namespace: labs-1
            Knative-Serving-Revision: customer-v4
      weight: 100
    timeout: 600s
    websocketUpgrade: true
```

*Maybe* you overlooked that there are as many routes in this virtual service as traffic tags we defined in the Customer Knative Service (plus one!) we defined to split traffic. Handy right?

- current
- candidate
- latest

> Check spec->match->authority->prefix in Customer Virtual Service you'll find there's another one, the general entry point, the URL we should use...
> `customer.labs-1.apps.cluster-kharon-ba75.kharon-ba75.example.opentlc.com`

Let's try out this *virtual* routes:

```execute
curl -v http://current-customer.labs-%userid%.%cluster_subdomain%/
```

```execute
curl -v http://candidate-customer.labs-%userid%.%cluster_subdomain%/
```

```execute
curl -v http://latest-customer.labs-%userid%.%cluster_subdomain%/
```

Now, why don't we generate some load against the customer service. Pay attention because if the split is 50/50 between v3 and v4 there should be equal number of v3's and v4's among the answers.

```execute-1
for i in $(seq 1 10); do curl -v http://customer.labs-%userid%.%cluster_subdomain%/; done
```

In the meantime have a look to the pods, you'll see pods of both versions v3 and v4 of our Customer service.

```execute-2
watch oc get pod -n labs-%userid%
```

Ctrl+C to stop the watch command.

```execute-2
<ctrl+c>
```