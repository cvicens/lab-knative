Now let's imagine we want to define an autoscale rule for Customer service based on number of requests.

- 10 requests maximum
- 1 to 10 pods

Pay attention to these annotations:

```yaml
autoscaling.knative.dev/target: "10"
autoscaling.knative.dev/minScale: "1"
autoscaling.knative.dev/maxScale: "10"
```

This is the descriptor `customer-autoscale-request.yml`:

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

Let's generate some load against the customer service:

```execute-1
ab -n 1000 -c 100 http://customer.labs-%userid%.%cluster_subdomain%/
```

And have a look to the pods.

```execute-2
watch oc get pod -n labs-%userid%
```

Ctrl+C to stop the watch command.