import os
import boto3


aws_region = os.environ['aws_region']
tag_name = os.environ['tag_name']
ec2 = boto3.client('ec2', region_name=aws_region)

def stop_instances(event, context):
    reservations = ec2.describe_instances(
                Filters=[
                    {'Name': 'tag:' + tag_name, 'Values': ['true']},
                    {'Name': 'instance-state-name', 'Values': ['running']}
                ]
            )['Reservations']
    if len(reservations) > 0:
        instances = [i for r in reservations for i in r['Instances']]
        instanceIds = [i['InstanceId'] for i in instances]
        ec2.stop_instances(InstanceIds=instanceIds)
        print(f'Instances: {instanceIds} was stopped')
    else:
        print(f"There is no running Instances with tag {tag_name} and value 'true'")

def start_instances(event, context):
    reservations = ec2.describe_instances(
                Filters=[
                    {'Name': 'tag:' + tag_name, 'Values': ['true']},
                    {'Name': 'instance-state-name', 'Values': ['stopped']}
                ]
            )['Reservations']
    if len(reservations) > 0:
        instances = [i for r in reservations for i in r['Instances']]
        instanceIds = [i['InstanceId'] for i in instances]
        ec2.start_instances(InstanceIds=instanceIds)
        print(f'Instances: {instanceIds} was started')
    else:
        print(f"There is no stopped Instances with tag {tag_name} and value 'true'")