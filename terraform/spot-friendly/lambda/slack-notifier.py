import json
import urllib.request
import os

def lambda_handler(event, context):
    webhook_url = os.environ.get("SLACK_WEBHOOK_URL")
    if not webhook_url:
        print("SLACK_WEBHOOK_URL not set")
        return

    # Extract instance ID(s) from SNS event
    try:
        message = event['Records'][0]['Sns']['Message']
        message_json = json.loads(message)
        instance_id = message_json['detail']['instance-id']
        time = message_json['time']
    except Exception as e:
        print(f"Failed to parse message: {e}")
        print(json.dumps(event))
        return

    slack_payload = {
        "text": f"\U0001F6A8 *Spot 인스턴스 중단 감지!*
• Instance ID: `{instance_id}`
• Time: `{time}`"
    }

    try:
        req = urllib.request.Request(
            webhook_url,
            data=json.dumps(slack_payload).encode("utf-8"),
            headers={"Content-Type": "application/json"}
        )
        with urllib.request.urlopen(req) as res:
            res.read()
        print("Slack notification sent.")
    except Exception as e:
        print(f"Slack notification failed: {e}")
