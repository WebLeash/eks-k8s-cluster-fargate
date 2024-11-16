import json
import gzip
import boto3
from datetime import datetime
from io import BytesIO

s3 = boto3.client('s3')
bucket_name = "emirates-private-store"
prefix = "staging/daily-logs/"

def lambda_handler(event, context):
    try:
        # Extract and decode CloudWatch logs data
        cw_data = event['awslogs']['data']
        cw_data_decoded = gzip.GzipFile(fileobj=BytesIO(cw_data))
        cw_data_decoded_content = json.loads(cw_data_decoded.read())
        
        # Extract the log events
        log_data = json.dumps(cw_data_decoded_content['logEvents'])
        
        # Create a filename with date and time
        filename = prefix + "log_" + datetime.now().strftime("%Y-%m-%dT%H-%M-%S") + ".json"
        
        # Store log data in S3 bucket
        s3.put_object(Bucket=bucket_name, Key=filename, Body=log_data)
        
        return {
            'statusCode': 200,
            'body': json.dumps('Logs stored in S3 successfully!')
        }

    except Exception as e:
        print(f"Error processing logs: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error processing logs: {str(e)}")
        }
