 #!/bin/bash
 
cat >values.yaml <<EOF
EOF

helm install my-release --namespace cert-manager --version v1.12.1 jetstack/cert-manager