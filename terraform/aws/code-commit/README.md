# Terraform a new AWS Code Commit Repository

Based on the following Terraform [example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codecommit_repository).

Assumes:

* AWS credentials are passed as environment variables
  * See `AWS_*` arguments [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#environment-variables)


## Local testing

### Copy sample configuration

```
cp terraform.tfvars.sample terraform.tfvars
```

### Edit `terraform.tfvars`

Amend the values for

* `repository_name`
* `repository_description`


### Specify environment variables

```
export AWS_ACCESS_KEY_ID="xxx"
export AWS_SECRET_ACCESS_KEY="xxx"
export AWS_SESSION_TOKEN="xxx"
export AWS_DEFAULT_REGION="xxx"
```
> Replace occurrences of `xxx` above with appropriate values

### Create AWS Code Commit repository

```
./create-code-commit-repo.sh
```

### Teardown AWS Code Commit repository

```
./destroy-code-commit-repo.sh
```

### Authentication

You will need to set up authentication. There several ways to do this, but here's the most expedient:

* Add AWS credential helper to Git global configuration

  ```bash
  cat >> $HOME/.gitconfig << EOF
  [credential]
    helper = !aws --profile cloudgate codecommit credential-helper $@
    UseHttpPath = true
  EOF
  ```

* Update AWS configuration and credentials file to activate based on profile
  * in the case below the profile is named `cloudgate`

  ```bash
  cat >> $HOME/.aws/credentials << EOF
  [cloudgate]
  aws_access_key_id=XXX
  aws_secret_access_key=YYY
  aws_session_token=ZZZ
  EOF

  cat >> $HOME/.aws/config << EOF
  [profile cloudgate]
  region=us-west-2
  output=json
  EOF
  ```
  > Be sure to replace the values of `aws_*` properties above with valid credentials

### Usage

Use the [git](https://git-scm.com/downloads) CLI and [clone](https://git-scm.com/docs/git-clone) the repository you just created with

```bash
git clone $(terraform output --raw code_commit_clone_url_http)
```
