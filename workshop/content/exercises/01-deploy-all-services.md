First of all we're going to deploy all the services that make our application:

- Customer
- Preference
- Recommendation

Customer ==> Preference ==> Recommendation

Pay attention to this annotation:

```yaml
serving.knative.dev/visibility: "cluster-local"
```

This is the descriptor:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: customer
data:
  application.properties: |
    com.redhat.developer.demos.customer.rest.PreferenceService/mp-rest/url=http://preference.$NAMESPACE:80
---
apiVersion: serving.knative.dev/v1alpha1 # Current version of Knative
kind: Service
metadata:
  name: customer
spec:
  template:
    metadata:
      name: customer-v1
      annotations:
        autoscaling.knative.dev/target: "10"
    spec:
      containers:
        - image: quay.io/dsanchor/customer:quarkus
          env:
            - name: VERSION
              value: "v1"
          volumeMounts:
            - name: configuration
              mountPath: /deployments/config
      volumes:
        - name: configuration
          configMap:
            name: customer
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: preference
data:
  application.properties: |
    org.eclipse.microprofile.rest.client.propagateHeaders=baggage-user-agent
    com.redhat.developer.demos.customer.rest.RecommendationService/mp-rest/url=http://recommendation.$NAMESPACE:80
---
apiVersion: serving.knative.dev/v1alpha1 # Current version of Knative
kind: Service
metadata:
  name: preference 
  labels:
     serving.knative.dev/visibility: "cluster-local"
spec:
  template:
    metadata:
      name: preference-v1
      annotations:
        autoscaling.knative.dev/target: "10"
    spec:
      containers:
        - image: quay.io/dsanchor/preference:quarkus
          volumeMounts:
            - name: configuration
              mountPath: /deployments/config
      volumes:
        - name: configuration
          configMap:
            name: preference
---
apiVersion: serving.knative.dev/v1alpha1 # Current version of Knative
kind: Service
metadata:
  name: recommendation 
  labels:
     serving.knative.dev/visibility: "cluster-local"
spec:
  template:
    metadata:
      name: recommendation-v1
      annotations:
        autoscaling.knative.dev/target: "10"
    spec:
      containers:
        - image: quay.io/dsanchor/recommendation:vertx
          env:
            - name: VERSION
              value: "v1"

```

Instead of deploying all these elements directly with `apply -f` we're going to use a shell script to substitute some variables before applying.

```execute-1
bash ./scripts/deploy-all-services.sh labs-%userid% %cluster_subdomain%
```

Previous command creates all the object needed to deploy 3 serverless services.

Whenever you create a service (knative) a revision is created, let's have a look:

```execute-2
oc get revisions -n labs-%userid%
```

You should see something like:

```shell
NAME                CONFIG NAME      K8S SERVICE NAME    GENERATION   READY   REASON
customer-v1         customer         customer-v1         1            True
preference-v1       preference       preference-v1       1            True
recommendation-v1   recommendation   recommendation-v1   1            True
```

Also have a look to the routes generated:

```execute-2
kn route list -n labs-%userid%
```

Let's test the customer service:

> Be patient, some times it takes a bit for the service mesh to be set up... so if you get an error like:
> ```
> **HTTP/1.0 503 Service Unavailable**, wait and try again later ;-)
> ```

```execute-1
curl -v http://customer.labs-%userid%.%cluster_subdomain%
```

And have a look to the pods created automagically by knative.

```execute-2
watch oc get pod -n labs-%userid%
```

Ctrl+C to stop the watch command.

```execute-2
<ctrl+c>
```