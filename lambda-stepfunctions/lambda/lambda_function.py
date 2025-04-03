import boto3
import os

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    bucket_name = os.environ['S3_BUCKET']
    
    file_name = "hello_world.txt"
    content = "Hello, World!"
    
    s3.put_object(Bucket=bucket_name, Key=file_name, Body=content)
    
    return {"statusCode": 200, "body": "File uploaded to S3"}
