# Creating an IAM User Account with Route53 hosted zone management privileges

## Temporarily assume administrator access

> You're going to need to use an account with [iam:AdministratorAccess](https://console.aws.amazon.com/iam/home#/policies/arn:aws:iam::aws:policy/AdministratorAccess$jsonEditor) policy permissions attached to complete the following steps.

### Create an IAM policy for managing subdomain records in a Route53 hosted zone

Consult the following [documentation](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/access-control-managing-permissions.html#example-permissions-record-owner).

Create policy

```
cat > domain-owner-policy-for-{hosted-zone-id}.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid" : "DomainOwnerPolicyFor{hosted-zone-id}",
            "Effect": "Allow",
            "Action": [
                "route53:GetChange",
                "route53:GetHostedZone",
                "route53:GetHostedZoneCount",
                "route53:ListHostedZones",
                "route53:ListHostedZonesByName",
                "route53:ListResourceRecordSets",
                "route53:ChangeResourceRecordSets",
                "route53:ListHealthChecks",
                "route53:CreateHealthCheck",
                "route53:DeleteHealthCheck",
                "route53:GetHealthCheckStatus",
                "route53:ChangeTagsForResource",
                "route53:ListTagsForResource"
            ],
            "Resource": "arn:aws:route53:::hostedzone/{hosted-zone-id}"
        },
        {
            "Sid": "AllowLookupByZoneName",
            "Effect": "Allow",
            "Action": [
                "route53:GetChange",
                "route53:ListHostedZones",
                "route53:ListHostedZonesByName",
                "route53:ListResourceRecordSets",
                "route53:ListHealthChecks",
                "route53:GetHealthCheckStatus",
                "route53:ListTagsForResource"
            ],
            "Resource": "*"
        }
    ]
}
EOF
```
> Replace `{hosted-zone-id}` above with your own hosted zone id.

Then

```
aws iam create-policy --policy-name domain-owner-access-for-{hosted-zone-id} --policy-document file://domain-owner-policy-for-{hosted-zone-id}.json
```
> Replace `{hosted-zone-id}` above with your own hosted zone id.  Make a note of the `Arn` value in the output.


### Create account, attach policy, and obtain credentials

Create a user account

```
aws iam create-user --user-name {DOMAIN}-owner
```
> Replace `{DOMAIN}` with a domain name substituting occurrences of "." with "-".

Attach policy

```
aws iam attach-user-policy --policy-arn "{ARN}" --user-name {DOMAIN}-owner
```
> Replace `{ARN}` with the value you captured a couple of steps before.  Replace the value of `{DOMAIN}` with what you chose in the prior step.

Obtain credentials for this user account

```
aws iam create-access-key --user-name {DOMAIN}-owner
```
> Replace the value of `{DOMAIN}` with what you chose in the prior step.  Make sure you capture the access key and secret key in the JSON output.  You'll require these values later on when you configure and install external-dns.