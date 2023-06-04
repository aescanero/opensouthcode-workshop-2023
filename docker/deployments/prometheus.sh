#!/bin/bash

cat >values.yaml <<EOF
## Create default rules for monitoring the cluster
##
defaultRules:
  create: true
  rules:
    alertmanager: true
    etcd: true
    configReloaders: true
    general: true
    k8s: true
    kubeApiserverAvailability: true
    kubeApiserverBurnrate: true
    kubeApiserverHistogram: true
    kubeApiserverSlos: true
    kubeControllerManager: true
    kubelet: true
    kubeProxy: true
    kubePrometheusGeneral: true
    kubePrometheusNodeRecording: true
    kubernetesApps: true
    kubernetesResources: true
    kubernetesStorage: true
    kubernetesSystem: true
    kubeSchedulerAlerting: true
    kubeSchedulerRecording: true
    kubeStateMetrics: true
    network: true
    node: true
    nodeExporterAlerting: true
    nodeExporterRecording: true
    prometheus: true
    prometheusOperator: true

  ## Prefix for runbook URLs. Use this to override the first part of the runbookURLs that is common to all rules.
  runbookUrl: "https://runbooks.prometheus-operator.dev/runbooks"

  ## Disabled PrometheusRule alerts
  disabled: {}
  # KubeAPIDown: true
  # NodeRAIDDegraded: true


##
global:
  rbac:
    create: true

    ## Create ClusterRoles that extend the existing view, edit and admin ClusterRoles to interact with prometheus-operator CRDs
    ## Ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/#aggregated-clusterroles
    createAggregateClusterRoles: false
    pspEnabled: false
    pspAnnotations: {}
      ## Specify pod annotations
      ## Ref: https://kubernetes.io/docs/concepts/policy/pod-security-policy/#apparmor
      ## Ref: https://kubernetes.io/docs/concepts/policy/pod-security-policy/#seccomp
      ## Ref: https://kubernetes.io/docs/concepts/policy/pod-security-policy/#sysctl
      ##
      # seccomp.security.alpha.kubernetes.io/allowedProfileNames: '*'
      # seccomp.security.alpha.kubernetes.io/defaultProfileName: 'docker/default'
      # apparmor.security.beta.kubernetes.io/defaultProfileName: 'runtime/default'

    ## SecurityContext holds pod-level security attributes and common container settings.
    ## This defaults to non root user with uid 1000 and gid 2000. *v1.PodSecurityContext  false
    ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
    ##
    securityContext:
      runAsGroup: 2000
      runAsNonRoot: true
      runAsUser: 1000
      fsGroup: 2000
      seccompProfile:
        type: RuntimeDefault


## Using default values from https://github.com/grafana/helm-charts/blob/main/charts/grafana/values.yaml
##
grafana:
  enabled: true
  namespaceOverride: ""
  admin:
    existingSecret: "kube-prometheus-stack-grafana"
    userKey: admin-user
    passwordKey: admin-password

  ## ForceDeployDatasources Create datasource configmap even if grafana deployment has been disabled
  ##
  forceDeployDatasources: false

  ## ForceDeployDashboard Create dashboard configmap even if grafana deployment has been disabled
  ##
  forceDeployDashboards: false

  ## Deploy default dashboards
  ##
  defaultDashboardsEnabled: true

  ## Timezone for the default dashboards
  ## Other options are: browser or a specific timezone, i.e. Europe/Luxembourg
  ##
  defaultDashboardsTimezone: utc

  #adminPassword: prom-operator

  rbac:
    ## If true, Grafana PSPs will be created
    ##
    pspEnabled: false

  ingress:
    enabled: true
    ingressClassName: traefik
    annotations:
      kubernetes.io/tls-acme: "true"
    hosts:
       - localhost
    paths:
    - /grafana

    ## For Kubernetes >= 1.18 you should specify the pathType (determines how Ingress paths should be matched)
    ## See https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/#better-path-matching-with-path-types
    # pathType: ImplementationSpecific

    tls:
    - secretName: general-tls
      hosts:
      - localhost

## Deploy a Prometheus instance
##
prometheus:
  enabled: true

  ## Annotations for Prometheus
  ##
  annotations: {}

  ## Configure network policy for the prometheus
  networkPolicy:
    enabled: false

    ## Flavor of the network policy to use.
    #  Can be:
    #  * kubernetes for networking.k8s.io/v1/NetworkPolicy
    #  * cilium     for cilium.io/v2/CiliumNetworkPolicy
    flavor: kubernetes

    # cilium:
    #   endpointSelector:
    #   egress:
    #   ingress:

    # egress:
    # - {}
    # ingress:
    # - {}
    # podSelector:
    #   matchLabels:
    #     app: prometheus

  ## Service account for Prometheuses to use.
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
  ##
  serviceAccount:
    create: true
    name: ""
    annotations: {}

    service:
    annotations: {}
    labels: {}
    clusterIP: ""

    ## Port for Prometheus Service to listen on
    ##
    port: 9090

    ## To be used with a proxy extraContainer port
    targetPort: 9090

    ## List of IP addresses at which the Prometheus server service is available
    ## Ref: https://kubernetes.io/docs/user-guide/services/#external-ips
    ##
    externalIPs: []

    ## Port to expose on each node
    ## Only used if service.type is 'NodePort'
    ##
    nodePort: 30090

    ## Loadbalancer IP
    ## Only use if service.type is "LoadBalancer"
    loadBalancerIP: ""
    loadBalancerSourceRanges: []

    ## Denotes if this Service desires to route external traffic to node-local or cluster-wide endpoints
    ##
    externalTrafficPolicy: Cluster

    ## Service type
    ##
    type: ClusterIP

    ## Additional port to define in the Service
    additionalPorts: []
    # additionalPorts:
    # - name: authenticated
    #   port: 8081
    #   targetPort: 8081

    ## Consider that all endpoints are considered "ready" even if the Pods themselves are not
    ## Ref: https://kubernetes.io/docs/reference/kubernetes-api/service-resources/service-v1/#ServiceSpec
    publishNotReadyAddresses: false

    sessionAffinity: ""

  ## Configuration for creating a separate Service for each statefulset Prometheus replica
  ##
  ## Configure pod disruption budgets for Prometheus
  ## ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/#specifying-a-poddisruptionbudget
  ## This configuration is immutable once created and will require the PDB to be deleted to be changed
  ## https://github.com/kubernetes/kubernetes/issues/45398
  ##
  podDisruptionBudget:
    enabled: false
    minAvailable: 1
    maxUnavailable: ""

  ingress:
    enabled: true
    ingressClassName: traefik
    annotations:
      kubernetes.io/tls-acme: "true"
    hosts:
       - localhost
    paths:
    - /grafana

    ## For Kubernetes >= 1.18 you should specify the pathType (determines how Ingress paths should be matched)
    ## See https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/#better-path-matching-with-path-types
    # pathType: ImplementationSpecific

    tls:
    - secretName: general-tls
      hosts:
      - localhost

EOF

helm install prometheus-stack prometheus-community/kube-prometheus-stack -f values.yaml --namespace monitoring