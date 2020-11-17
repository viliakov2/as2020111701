import json
import urllib.parse
import os
import boto3
import uuid

STEP_FUNCTION_ARN = os.environ['STEP_FUNCTION_ARN']

sfn = boto3.client('stepfunctions')

def lambda_handler(event, context):
    print("Received event: " + json.dumps(event))

    bucket = urllib.parse.unquote(event['Records'][0]['s3']['bucket']['name'], encoding='utf-8')
    key = urllib.parse.unquote(event['Records'][0]['s3']['object']['key'], encoding='utf-8')

    videoprocessing = sfn.start_execution(
        stateMachineArn=STEP_FUNCTION_ARN,
        name="processing-" + str(uuid.uuid4()),
        input=json.dumps(
            {
                "bucket": bucket,
                "key": key
            }
        )
    )

    print("Step function: {}".format(videoprocessing))
