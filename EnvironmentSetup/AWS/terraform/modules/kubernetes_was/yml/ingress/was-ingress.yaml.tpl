apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${namespace}-ingress
  namespace: ${namespace}
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "360"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "360"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "360"

    cert-manager.io/cluster-issuer: ${domain}

    # add sticky sessions
    # ---------------------
    nginx.ingress.kubernetes.io/affinity: "cookie"
    nginx.ingress.kubernetes.io/session-cookie-name: "${namespace}_sticky_session"
    nginx.ingress.kubernetes.io/session-cookie-expires: "172800"
    nginx.ingress.kubernetes.io/session-cookie-max-age: "172800"

    # force ssl redirect
    # ---------------------
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"

spec:
  tls:
  - hosts:
    - "${domain}"
    - "*.${domain}"
    secretName: ${domain}-tls
  rules:
  - host: ${domain}
    http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: active-web-elements-server
                port:
                  number: 8080

          - path: /endpoints/?(.*)
            pathType: Prefix
            backend:
              service:
                name: endpoint-manager
                port:
                  number: 8085

          - path: /.applicationserver/kernel/restart
            pathType: Prefix
            backend:
              service:
                name: endpoint-manager
                port:
                  number: 8085

          - path: /endpoints/?(.*)
            pathType: Prefix
            backend:
              service:
                name: endpoint-manager
                port:
                  number: 8085

          - path: /nodefiles/?(.*)
            pathType: Prefix
            backend:
              service:
                name: resource-manager
                port:
                  number: 9090

          - path: /resources/?(.*)
            pathType: Prefix
            backend:
              service:
                name: resource-manager
                port:
                  number: 9090
