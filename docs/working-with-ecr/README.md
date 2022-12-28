# Working with Elastic Container Registry

When you've configured the TAP install to interact with Elastic Container Registry, you will need to routinely update the login password.  This is because the password is actually an expiring token.

You can fetch a new token by executing

```
export ECR_LOGIN_PASSWORD="$(aws ecr get-login-password)"
```

However, you'll then need to update the password in the `tap-full` secret in the `tap-full` namespace.  Here's how you fetch the secret and decode the data.

```
kubectl get secret tap-full -n tap-full -o 'go-template={{index .data "tap-secrets.yml"}}' | base64 -d
```

To update the secret

```
export values=$(kubectl get secret tap-full -n tap-full -o 'go-template={{index .data "tap-secrets.yml"}}' | base64 -d | ecr_password="$ECR_LOGIN_PASSWORD" yq '.tap.credentials.registry.password = env(ecr_password)' | base64 -w 0) && kubectl get secret tap-full -n tap-full -o json | jq --arg tapsecrets "$(echo $values)" '.data["tap-secrets.yml"] = $tapsecrets' | kubectl apply -f -
```

We also manage the ECR password as a key in a Secrets Manager instance.  If you want to keep that value in sync too, then

```
export AWS_PAGER=
SECRETS_MANAGER_NAME={secret-manager-name}
aws secretsmanager get-secret-value --secret-id $SECRETS_MANAGER_NAME --query 'SecretString' | sed -e 's/\\"/'\"'/g' | sed -e 's/^"//' -e 's/"$//' | jq > secret.json
yq -P '.' secret.json > secret.yaml
cat secret.yaml | yq '.ecr-admin-password = env(ECR_LOGIN_PASSWORD)' > updated-secret.yaml
yq -o=json '.' updated-secret.yaml > updated-secret.json
aws secretsmanager put-secret-value --secret-id $SECRETS_MANAGER_NAME --secret-string "$(cat updated-secret.json)"
```
> Replace `{secrets-manager-name}` with the name of the Secrets Manager instance.

## Related resources

* [Amazon ECR private registry](https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html)
* [Keeping AWS Registry pull credentials fresh in Kubernetes](https://medium.com/@xynova/keeping-aws-registry-pull-credentials-fresh-in-kubernetes-2d123f581ca6)