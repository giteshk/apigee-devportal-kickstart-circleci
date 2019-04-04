# apigee-devportal-kickstart-circleci

Define the following environment variables in your circle CI project :
- PANTHEON_SITE:  Name of the Pantheon site to rebuild
- PANTHEON_ENV:  Name of the environment on the Pantheon site to rebuild
- TERMINUS_TOKEN: The Pantheon machine token
- GIT_EMAIL:      The email address to use when making commits
- DEFAULT_ACCOUNT_PASS:    The admin password to use when installing.
- DEFAULT_ACCOUNT_MAIL:    The email address to give the admin when installing.
- DEFAULT_ACCOUNT_NAME:    The email address to give the admin when installing.
- APIGEE_ORG: Name of the apigee organization to connect to
- APIGEE_USER: Apigee username to use to connect
- APIGEE_PASS: Apigee user password


Additionally you will need to change the fingerprint value in the config.yml once you upload your key into circleci

Status of Build : [![CircleCI](https://circleci.com/gh/giteshk/apigee-devportal-kickstart-circleci.svg?style=svg&circle-token=2c475c0d73a2d66649b6691000029b9eb58f219a)](https://circleci.com/gh/giteshk/apigee-devportal-kickstart-circleci)
