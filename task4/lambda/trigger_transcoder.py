import json
import urllib.parse
import os
import boto3
import uuid

PIPELINE_ID = os.environ['PIPELINE_ID']
PRESET_ID = os.environ['PRESET_ID']
OUTPUT_PREFIX = os.environ['OUTPUT_PREFIX']

transcoder = boto3.client('elastictranscoder')

def lambda_handler(event, context):
    print("Received event: " + json.dumps(event))

    key = event["ExecutionContext"]["Execution"]["Input"]["key"]

    filename = os.path.splitext(key)[0] + '-' + str(uuid.uuid4())
    extension = os.path.splitext(key)[1]

    job = transcoder.create_job(
        PipelineId=PIPELINE_ID,
        Input={
            'Key': key
        },
        OutputKeyPrefix=OUTPUT_PREFIX,
        Outputs=[
            {
                'Key': filename + extension,
                'ThumbnailPattern': filename + '-{resolution}-{count}',
                'PresetId': PRESET_ID
            }
        ]
    )

    print("Transcoder Job: {}".format(job))
