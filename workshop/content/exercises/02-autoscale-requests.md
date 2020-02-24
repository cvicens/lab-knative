Now let's imagine we want to define an autoscale rule for Customer service based on number of requests.

- 10 requests maximum
- 1 to 10 pods

Pay attention to these annotations:

```yaml
autoscaling.knative.dev/target: "10"
autoscaling.knative.dev/minScale: "1"
autoscaling.knative.dev/maxScale: "10"
```

This is the descriptor `customer-autoscale-requests.yml`:

> VERSION environment variable changed to v2

```yaml
apiVersion: serving.knative.dev/v1alpha1 # Current version of Knative
kind: Service
metadata:
  name: customer
spec:
  template:
    metadata:
      name: customer-v2
      annotations:
        # Target 10 in-flight-requests per pod.
        autoscaling.knative.dev/target: "10"
        autoscaling.knative.dev/minScale: "1"
        autoscaling.knative.dev/maxScale: "10"
    spec:
      containers:
        - image: quay.io/dsanchor/customer:quarkus
          env:
            - name: VERSION
              value: "v2"
          volumeMounts:
            - name: configuration
              mountPath: /deployments/config
      volumes:
        - name: configuration
          configMap:
            name: customer

```

As we did before, let's apply this descriptor using a shell script.

```execute-1
bash ./scripts/deploy-customer-autoscale-requests.sh labs-%userid% %cluster_subdomain%
```

Everytime we change a service (knative) a new revision is created, let's have a look:

```execute-2
oc get revisions -n labs-%userid%
```

Let's test the customer service:

> Be patient, some times it takes a bit for the service mesh to be set up... so if you get an error like:
> ```
> **HTTP/1.0 503 Service Unavailable**, wait and try again later ;-)
> ```

```execute-1
curl -v http://customer.labs-%userid%.%cluster_subdomain%
```

Now, let's generate some load against the customer service:

```execute-1
hey -c 70 -z 20s http://customer.labs-%userid%.%cluster_subdomain%/
```

And have a look to the pods.

```execute-2
watch oc get pod -n labs-%userid%
```

Ctrl+C to stop the watch command.

```execute-2
<ctrl+c>
```