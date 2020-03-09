Serverless Operator => Serving => Ingress project with Istio

Eventing Operator


oc new-project labs

oc label namespace labs knative-eventing-injection=enabled ===> Genera default broker

exponger default service

oc expose svc/default-broker -n labs


Primero creamoe el service

oc apply -f knative-files/event-display-ksvc.yml -n labs


curl -v http://default-broker-labs.apps.cluster-kharon-ba75.kharon-ba75.example.opentlc.com/ -H "Ce-specversion: 1.0" -H "Ce-Type: dev.knative.demo" -H "Ce-Id: 45a8b444-3213-4758-be3f-540bf93f85ff" -H "Ce-Source: dev.knative.demo/simplesource" -H 'Content-Type: application/json' -d '{ "message": "Hi there!!" }'

oc logs -f logevents-w855w-deployment-799b4fb6c8-qc5cm -c user-container -n labs

Install knative kafka addon in knarive-eventing

- oerator cluster wide 


Antes instalar kafka

oc new-project kafka

Create kafka - CR in project kafka

Create topic

Kafka eventing to kafka

apiVersion: eventing.knative.dev/v1alpha1
kind: KnativeEventingKafka
metadata:
  name: knative-demo-eventing-kafka
spec:
  bootstrapServers: knative-cluster-kafka-bootstrap.labs-infra:9092
  setAsDefaultChannelProvisioner: yes






oc -n kafka run kafka-producer -ti --image=strimzi/kafka:0.14.0-kafka-2.3.0 --rm=true --restart=Never -- bin/kafka-console-producer.sh --broker-list knative-cluster-kafka-bootstrap.labs-infra:9092 --topic eventing

> {"message" : "Hi guys!!"}


Ojo, el filtro del trigger!!! 

  filter:
    attributes:
       type: dev.knative.demo
       source: dev.knative.demo/simplesource

oc apply -f knative-files/demo-trigger-2.yml -n labs
trigger.eventing.knative.dev/demo-trigger configured

oc get eventtypes -n labs
NAME                            TYPE                      SOURCE                                                        SCHEMA   BROKER    DESCRIPTION   READY   REASON
dev.knative.kafka.event-5lz8k   dev.knative.kafka.event   /apis/v1/namespaces/labs/kafkasources/kafka-source#eventing            default                 True   


Send event from kafka-producer

oc get pod -n labs

oc logs -f logevents.... -n labs




