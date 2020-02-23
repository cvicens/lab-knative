Now let's imagine we want to define an autoscale rule for Customer service based on cpu usage.

- 10 requests maximum
- 1 to 10 pods

Pay attention to these annotations, this time they have to do with cpu usage:

> HPA class is different to the default one!

```yaml
autoscaling.knative.dev/class: hpa.autoscaling.knative.dev
autoscaling.knative.dev/metric: cpu
autoscaling.knative.dev/target: "70"
autoscaling.knative.dev/minScale: "1"
autoscaling.knative.dev/maxScale: "10"
```

This is the descriptor `customer-autoscale-cpu.yml`:

> VERSION environment variable changed to v3

```yaml
apiVersion: serving.knative.dev/v1alpha1 # Current version of Knative
kind: Service
metadata:
  name: customer
spec:
  template:
    metadata:
      name: customer-v3
      annotations:
        # Standard Kubernetes CPU-based autoscaling.
        autoscaling.knative.dev/class: hpa.autoscaling.knative.dev
        autoscaling.knative.dev/metric: cpu
        autoscaling.knative.dev/target: "70"
        autoscaling.knative.dev/minScale: "1"
        autoscaling.knative.dev/maxScale: "10"
    spec:
      containers:
        - image: quay.io/dsanchor/customer:quarkus
          env:
            - name: VERSION
              value: "v3"
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
bash ./scripts/deploy-customer-autoscale-cpu.sh labs-%userid% %cluster_subdomain%
```

Again, as we changed a service (knative) a new revision is created, let's have a look:

```execute-2
oc get revisions -n labs-%userid%
```

Let's generate some load against the customer service:

```execute-1
hey -c 100 -z 20s http://customer.labs-%userid%.%cluster_subdomain%/
```

Check hpa metrics:

> **NOTE** --horizontal-pod-autoscaler-downscale-stabilization: The value for this option is a duration that specifies how long the autoscaler has to wait before another downscale operation can be performed after the current one has completed. The default value is 5 minutes (5m0s).

```execute-2
watch -n2 oc get hpa customer-v3 -n labs-%userid% 
```

Please, Ctrl+C.

```execute-2
<ctrl+c>
```

Finally and have a look to the pods.

```execute-2
watch oc get pod -n labs-%userid%
```

Ctrl+C to stop the watch command.

```execute-2
<ctrl+c>
```