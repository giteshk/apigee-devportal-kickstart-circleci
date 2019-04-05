#!/bin/sh

if [ -z "$1" ]
  then
    PANTHEON_ENV="ci-latest"
   else
    PANTHEON_ENV=$1
fi

if [ -z "$2" ]
  then
       echo "setting the org to $APIGEE_ORG"
   else
    APIGEE_ORG=$2
fi

# Setup Git
git config --global user.email "$GIT_EMAIL" && git config --global user.name "Circle CI" && git config --global core.fileMode false

#Authenticate using terminus
terminus auth:login --machine-token=${TERMINUS_TOKEN} -q

# StrictHostKeyChecking disabled
touch $HOME/.ssh/config
echo "StrictHostKeyChecking no" >> "$HOME/.ssh/config"

# Backup the environment
terminus backup:create -q ${PANTHEON_SITE}.${PANTHEON_ENV}

# Clone Pantheon Site
git clone `terminus connection:info ${PANTHEON_SITE}.${PANTHEON_ENV} --field=git_url` pantheon_repo

cd pantheon_repo
git checkout -t origin/${PANTHEON_ENV} 

rm -rf vendor composer.lock

# Composer Update
composer update --with-dependencies -o

# Remove the .git files
rm -rf web/modules/contrib/swagger_ui_formatter/.git  web/profiles/contrib/apigee_devportal_kickstart/.git web/themes/contrib/radix/.git

# Change connection mode to Git
echo "Setting the pantheon environment mode to git"
terminus connection:set ${PANTHEON_SITE}.${PANTHEON_ENV} git -q


# Commit the changes and push them to pantheon 
git add . && git commit -m "Rebuilt at `date +%F_%H-%M-%S` EST" && git push origin ${PANTHEON_ENV}

# Change connection mode to SFTP
echo "Setting the pantheon environment mode to sftp"
terminus connection:set ${PANTHEON_SITE}.${PANTHEON_ENV} sftp

# Wipe the environment
echo "Wiping the Pantheon environment"
terminus env:wipe ${PANTHEON_SITE}.${PANTHEON_ENV} -y

# Run Site install
echo "About to start the site install"
terminus drush ${PANTHEON_SITE}.${PANTHEON_ENV} -q -- site-install apigee_devportal_kickstart --account-mail=${DEFAULT_ACCOUNT_MAIL} --account-name=${DEFAULT_ACCOUNT_NAME} --account-pass=${DEFAULT_ACCOUNT_PASS} --site-mail=noreply@apigee.com --site-name="ACME Developer Portal" -y

# Clear Caches
terminus env:clear-cache ${PANTHEON_SITE}.${PANTHEON_ENV} 

# Set the organization information
echo "About to connect portal to the configured org"
export CONNECTION_JSON="{\"auth_type\":\"basic\",\"organization\":\"${APIGEE_ORG}\",\"username\":\"${APIGEE_USER}\",\"password\":\"${APIGEE_PASS}\"}"
terminus drush ${PANTHEON_SITE}.${PANTHEON_ENV} -q -- key-save apigee_edge_connection_default "$CONNECTION_JSON"   --label="Apigee Edge Connection" --key-type=apigee_auth --key-provider=apigee_edge_private_file --key-input=apigee_auth_input --overwrite -y
terminus drush ${PANTHEON_SITE}.${PANTHEON_ENV} -- config:set apigee_edge.auth active_key "apigee_edge_connection_default" -y

echo "Finished installing the latest code and configuring the site"
