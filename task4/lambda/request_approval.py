import json
import urllib.parse
import boto3
import os

SNS_APPROVAL_ARN = os.environ['SNS_APPROVAL_ARN']

sns = boto3.client('sns')

def lambda_handler(event, context):
    print("Received event: " + json.dumps(event))

    executionContext = event["ExecutionContext"]
    apigwEndpint = urllib.parse.unquote(event["APIGatewayEndpoint"], encoding='utf-8')
    taskToken = urllib.parse.quote_plus(executionContext["Task"]["Token"], encoding='utf-8')
    approveEndpoint = apigwEndpint + "/execution?action=approve&taskToken=" + taskToken
    rejectEndpoint = apigwEndpint + "/execution?action=reject&taskToken=" + taskToken
    bucket = urllib.parse.unquote(event['Input']['bucket'], encoding='utf-8')
    key = urllib.parse.unquote(event['Input']['key'], encoding='utf-8')
    video_url = "https://{0}.s3.amazonaws.com/{1}".format(bucket, urllib.parse.quote_plus(key))
    message = """
The new video has been uploaded {0}
Approval link - {1}
Rejection link - {2}
""".format(video_url, approveEndpoint, rejectEndpoint)

    response = sns.publish(
        TopicArn=SNS_APPROVAL_ARN,
        Message=message,
        Subject='A new video has been uploaded. Screening is needed'
    )

    print("SNS publish: {}".format(response))
