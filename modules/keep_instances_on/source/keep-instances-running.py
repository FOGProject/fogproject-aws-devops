import boto3
import smtplib

from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

import os
import time
import json

region = "" #This is set from the event.

cloudwatch_log_group_name = os.environ['cloudwatch_log_group_name']
cloudwatch_log_stream_name = os.environ['cloudwatch_log_stream_name']
log_stream_name = "app_log_stream"

timestamp = int(round(time.time() * 1000))

def send_email(message):
    secretsmanager = boto3.client('secretsmanager')
    response = secretsmanager.get_secret_value(SecretId=os.environ['secrets_manager_email_creds_arn'],VersionStage='AWSCURRENT')
    email_creds = json.loads(response["SecretString"])

    body = "The below instance was found in the 'stopped' state.\n It has been started as a corrective measure.\n\n" + json.dumps(message,indent=4)
    msg = MIMEMultipart()
    msg['From'] = email_creds["fromaddr"]
    msg['To'] = ", ".join(message["recipients"])
    msg['Subject'] = message["name"] + " was started"
    msg.attach(MIMEText(body, 'plain'))
    try:
        server = smtplib.SMTP(email_creds["server_fqdn"], int(email_creds["server_port"]))
        server.starttls()
        server.login(email_creds["login_username"], email_creds["login_password"])
        text = msg.as_string()
        server.sendmail(email_creds["login_username"], message["recipients"], text)
        server.quit()
    except Exception as e:
        error = {}
        error["Exception"] = str(e)
        error["Message"] = "Failed to send email about event."
        log(error)
        pass



def log(message):
    logs = boto3.client('logs', region_name=region)

    response = logs.describe_log_groups()
    logGroups = response["logGroups"]
    while True:
        if "NextToken" in response.keys():
            if response["NextToken"] is not None:
                nexttoken = response["NextToken"]
                response = logs.describe_log_groups(NextToken=nexttoken)
                logGroups.extend(response["logGroups"])
            else:
                break
        else:
            break

    createGroup = True
    for logGroup in logGroups:
        if logGroup["logGroupName"] == cloudwatch_log_group_name:
            createGroup = False
            break
    if createGroup:
        response = logs.create_log_group(logGroupName=cloudwatch_log_group_name)

    response = logs.describe_log_streams(logGroupName=cloudwatch_log_group_name)
    logStreams = response["logStreams"]
    while True:
        if "NextToken" in response.keys():
            if response["NextToken"] is not None:
                nexttoken = response["NextToken"]
                response = logs.describe_log_streams(logGroupName=cloudwatch_log_group_name,NextToken=nexttoken)
                logStreams.extend(response["logStreams"])
            else:
                break
        else:
            break

    createStream = True
    uploadSequenceToken = None
    for logStream in logStreams:
        if logStream["logStreamName"] == cloudwatch_log_stream_name:
            createStream = False
            uploadSequenceToken = logStream["uploadSequenceToken"]
            break
    if createStream:
        response = logs.create_log_stream(logGroupName=cloudwatch_log_group_name,logStreamName=cloudwatch_log_stream_name)

    if uploadSequenceToken:
        response = logs.put_log_events(logGroupName=cloudwatch_log_group_name,logStreamName=cloudwatch_log_stream_name,sequenceToken=uploadSequenceToken,logEvents=[{'timestamp': timestamp,'message': json.dumps(message)}])
    else:
        response = logs.put_log_events(logGroupName=cloudwatch_log_group_name,logStreamName=cloudwatch_log_stream_name,logEvents=[{'timestamp': timestamp,'message': json.dumps(message)}])
    return


def handler(event, context):
    global region
    region = event["region"]
    instance_id = event["detail"]["instance-id"]
    ec2 = boto3.client('ec2', region_name=region)
    response = ec2.describe_instances(InstanceIds=[instance_id])
    Reservations = response["Reservations"]

    instances = []
    for reservation in Reservations:
        instances.extend(reservation["Instances"])

    for instance in instances:
        if instance["State"]["Name"] == "stopped":
            name = "NotAvailable"
            keep_running = False
            recipients = []
            for tag in instance["Tags"]:
                if tag["Key"] == "Name":
                    name = tag["Value"]
                if tag["Key"] == "keep-instances-running-recipients":
                    recipients.extend(tag["Value"].split(","))
                if tag["Key"] == "keep-instance-running":
                    if tag["Value"] == "True" or tag["Value"] == "true":
                        keep_running = True
            if keep_running:
                # recipients.extend(os.environ['extended_recipients'].split(","))
                message = {}
                message["instance_id"] = instance_id
                message["name"] = name
                # message["recipients"] = recipients
                message["region"] = region
                ec2.start_instances(InstanceIds=[instance_id])
                log(message)
                # send_email(message)


if __name__ == "__main__":
    handler("","")
