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

    key = urllib.parse.unquote_plus(
        event['Records'][0]['s3']['object']['key'], encoding='utf-8')

    filename = os.path.splitext(key)[0] + '-' + str(uuid.uuid4())

    job = transcoder.create_job(
        PipelineId=PIPELINE_ID,
        Input={
            'Key': key
        },
        OutputKeyPrefix=OUTPUT_PREFIX,
        Outputs=[
            {
                'Key': filename + '-720p.mp4',
                'ThumbnailPattern': filename + '-{resolution}-{count}',
                'PresetId': PRESET_ID
            }
        ]
    )

    print("Transcoder Job: {}".format(job))
