set -x

eksctl create iamserviceaccount \
--cluster=eks-demo-cluster-01 \
--namespace=kube-system \
--name=aws-load-balancer-controller \
--attach-policy-arn=arn:aws:iam::082875242631:policy/AWSLoadBalancerControllerIAMPolicy \
--override-existing-serviceaccounts \
--approve


exit 0
