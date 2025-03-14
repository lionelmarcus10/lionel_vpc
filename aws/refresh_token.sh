# list mfa device ( select lionel cli for username )
arn=$(aws iam list-mfa-devices --profile no-mfa-profile | jq -r '.MFADevices[] | select(.UserName == "lionel-cli") | .SerialNumber')
otpsecret=$(awk -F'=' '{print $2}' ~/.aws/otpsecrets)
code=$(oathtool $otpsecret )
# get session token
creds="$(aws sts get-session-token --serial-number $arn --token-code $code --profile no-mfa-profile)"

# config mfa device
aws configure set aws_access_key_id $(echo $creds | jq -r '.Credentials.AccessKeyId') --profile default
aws configure set aws_secret_access_key $(echo $creds | jq -r '.Credentials.SecretAccessKey') --profile default
aws configure set aws_session_token $(echo $creds | jq -r '.Credentials.SessionToken') --profile default

# config mfa device
aws configure set aws_access_key_id $(echo $creds | jq -r '.Credentials.AccessKeyId') --profile mfa-profile
aws configure set aws_secret_access_key $(echo $creds | jq -r '.Credentials.SecretAccessKey') --profile mfa-profile
aws configure set aws_session_token $(echo $creds | jq -r '.Credentials.SessionToken') --profile mfa-profile
