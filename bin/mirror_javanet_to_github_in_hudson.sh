#!/bin/bash -ex

# Cron spec: "*/10 * * * *"
# Email to: alex.kosowski@oracle.com

# XXX update the following values to match your repositories
JAVA_NET_GIT_DIR=javaee-security-spec~spec-api
JAVA_NET=git://java.net/$JAVA_NET_GIT_DIR
# GITHUB=git@github.com:alexkosowski/javaee-security-spec--spec-api.git
GITHUB=git@github.com:javaee-security-spec/spec-api.git

GITOUT=$WORKSPACE/gitout.txt


# Ensure a clean directory
rm -f $GITOUT
rm -fr $JAVA_NET_GIT_DIR.git

# Exit if subcommand has error
set +e

# Clone java.net repo
git clone --bare $JAVA_NET 2>&1 | tee -a $GITOUT

# Into the repo clone directory
cd $JAVA_NET_GIT_DIR.git

# Push to GitHub
git push --mirror $GITHUB 2>&1 | tee -a $GITOUT

# Restore
EXIT_CODE=$?
set -e

CLOSED_BY_REMOTE_HOST_ERROR=`grep 'ssh_exchange_identification: Connection closed by remote host' $GITOUT | wc -l | awk '{print $1}'`
CLOSED_BY_ERROR=`grep 'ERROR:' $GITOUT | wc -l | awk '{print $1}'`

echo "EXIT_CODE="$EXIT_CODE
echo "GITOUT contains: "`cat $GITOUT`
echo "CLOSED_BY_REMOTE_HOST_ERROR="$CLOSED_BY_REMOTE_HOST_ERROR
echo "CLOSED_BY_ERROR="$CLOSED_BY_ERROR

if [[ $EXIT_CODE -eq 0 && $CLOSED_BY_REMOTE_HOST_ERROR -eq 0 && $CLOSED_BY_ERROR -eq 0 ]];
then
  echo SUCCESS > $WORKSPACE/status.txt
else
  echo FAILURE > $WORKSPACE/status.txt
fi