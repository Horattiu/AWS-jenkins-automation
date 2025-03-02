import boto3

# Configurare boto3 SES
ses_client = boto3.client("ses", region_name="eu-west-1")

response = ses_client.send_email(
    Source="horatiu.oltn@gmail.com", 
    Destination={
        "ToAddresses": ["dev.horatiu@gmail.com"],  

    },
    Message={
        "Subject": {"Data": "Site-ul este live!"},
        "Body": {"Text": {"Data": "Acesta este un email de test trimis cu Amazon SES și boto3."}},
    },
)

print("Email trimis! Message ID:", response["MessageId"])
