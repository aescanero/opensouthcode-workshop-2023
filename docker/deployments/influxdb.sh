#!/bin/bash

cat > values.yaml <<EOF
image:
  repository: influxdb
  tag: 2.3.0-alpine
  pullPolicy: IfNotPresent

## Configure resource requests and limits
## ref: http://kubernetes.io/docs/user-guide/compute-resources/
##
resources:
  limits:
  cpu: 100m
  memory: 128Mi
  requests:
  cpu: 100m
  memory: 128Mi

securityContext: {}

## Customize liveness, readiness and startup probes
## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
##
livenessProbe: {}
  # path: "/health"
  # scheme: "HTTP"
  # initialDelaySeconds: 0
  # periodSeconds: 10
  # timeoutSeconds: 1
  # failureThreshold: 3

readinessProbe: {}
  # path: "/health"
  # scheme: "HTTP"
  # initialDelaySeconds: 0
  # periodSeconds: 10
  # timeoutSeconds: 1
  # successThreshold: 1
  # failureThreshold: 3

startupProbe:
  enabled: false
  # path: "/health"
  # scheme: "HTTP"
  # initialDelaySeconds: 30
  # periodSeconds: 5
  # timeoutSeconds: 1
  # failureThreshold: 6


adminUser:
  existingSecret: influxdb-auth

## Persist data to a persistent volume
##
persistence:
  enabled: true
  accessMode: ReadWriteOnce
  size: 1Gi
  mountPath: /var/lib/influxdb2
  subPath: ""

## Allow executing custom init scripts
## If the container finds any files with the .sh extension inside of the
## /docker-entrypoint-initdb.d folder, it will execute them.
## When multiple scripts are present, they will be executed in lexical sort order by name.
## For more details see Custom Initialization Scripts in https://hub.docker.com/_/influxdb
initScripts:
  enabled: false
  scripts:
    init.sh: |+
      #!/bin/bash
      influx apply --force yes -u https://raw.githubusercontent.com/influxdata/community-templates/master/influxdb2_operational_monitoring/influxdb2_operational_monitoring.yml

service:
  type: LoadBalancer
  port: 8086
  targetPort: 8086
  annotations: {}
  labels: {}
  portName: http

serviceAccount:
  create: true

ingress:
  enabled: true
  # For Kubernetes >= 1.18 you should specify the ingress-controller via the field ingressClassName
  # See https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/#specifying-the-class-of-an-ingress
  className: traefik
  tls: true
  secretName: my-tls-cert
  hostname: localhost

  annotations:
    # kubernetes.io/ingress.class: "nginx"
    kubernetes.io/tls-acme: "true"
  path: /influxdb

pdb:
  create: true
  minAvailable: 1
  maxUnavailable: 1
EOF

helm install influxdb influxdata/influxdb \
  --namespace monitoring \
  --values values.yaml
