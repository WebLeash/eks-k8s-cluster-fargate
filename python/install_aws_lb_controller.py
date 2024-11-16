import boto3
import subprocess
import os

os.environ["KUBECONFIG"] = "/root/.kube/config"

VPC_NAME = "eks-demo-vpc-01"
CLUSTER_NAME = "eks-demo-cluster-01"
REGION = "eu-west-2"
SERVICE_ACCOUNT_NAME = "aws-load-balancer-controller"
NAMESPACE = "kube-system"

ec2_client = boto3.client('ec2', region_name=REGION)

def get_vpc_id_by_name(vpc_name):
    response = ec2_client.describe_vpcs(
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': [vpc_name]
            }
        ]
    )
    vpcs = response.get('Vpcs', [])
    if len(vpcs) > 0:
        return vpcs[0]['VpcId']
    else:
        raise ValueError(f"No VPC found with name {vpc_name}")

def run_helm_install(vpc_id):
    helm_command = [
        "helm", "install", "aws-load-balancer-controller", "eks/aws-load-balancer-controller",
        "--set", f"clusterName={CLUSTER_NAME}",
        "--set", "serviceAccount.create=false",
        "--set", f"region={REGION}",
        "--set", f"vpcId={vpc_id}",
        "--set", f"serviceAccount.name={SERVICE_ACCOUNT_NAME}",
        "-n", NAMESPACE
    ]
    result = subprocess.run(helm_command, capture_output=True, text=True)
    if result.returncode == 0:
        print("Helm install command executed successfully.")
        print(result.stdout)
    else:
        print("Helm install command failed.")
        print(result.stderr)

def main():
    try:
        vpc_id = get_vpc_id_by_name(VPC_NAME)
        print(f"VPC ID for '{VPC_NAME}' is {vpc_id}")
        run_helm_install(vpc_id)
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()
