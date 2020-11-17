import json
import urllib.parse
import boto3
import os

STEP_FUNCTION_ARN = os.environ['STEP_FUNCTION_ARN']
sfn = boto3.client('stepfunctions')

def lambda_handler(event, context):
    print("Received event: " + json.dumps(event))
    action = urllib.parse.unquote(event["query"]["action"], encoding='utf-8')
    taskToken = urllib.parse.unquote(event["query"]["taskToken"], encoding='utf-8')

    if action == "approve":
        message = json.dumps({"Status": "Approved"})
    elif action == "reject":
        message = json.dumps({"Status": "Rejected"})
    else:
        message = json.dumps({"Status": "Failed to process the request. Unrecognized Action."})

    response = sfn.send_task_success(
        taskToken=taskToken,
        output=message
    )

    print("SFN send_task_success response: {}".format(response))

    return json.dumps({
        "statusCode": "200",
        "message": message
    })
