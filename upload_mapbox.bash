#!/bin/bash
set -x
set +ue
PYTHONIOENCODING=utf8
MAPBOX_AT="xxxxxxxxxxx"
USER="xxxxxx"
TILESET="$USER.test"
UPLOAD_FILE='db.geojson'
curl https://api.mapbox.com/uploads/v1/${USER}/credentials?access_token=${MAPBOX_AT} > c.json 
cat c.json
BUCKET=($(grep -Po '"bucket":.*?[^\\]",' c.json | awk -F ":" '{print $2 }' | tr -d '",'))
KEY=($(grep -Po '"key":.*?[^\\]",' c.json | awk -F ":" '{print $2 }' | tr -d '",'))
AWS_ACCESS_KEY_ID=($(grep -Po '"accessKeyId":.*?[^\\]",' c.json | awk -F ":" '{print $2 }' | tr -d '",'))
AWS_SECRET_ACCESS_KEY=($(grep -Po '"secretAccessKey":.*?[^\\]",' c.json | awk -F ":" '{print $2 }' | tr -d '",'))
AWS_SESSION_TOKEN=($(grep -Po '"sessionToken":.*?[^\\]",' c.json | awk -F ":" '{print $2 }' | tr -d '",'))
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN
echo "BUCKET:${BUCKET}"
echo "KEY:${KEY}"
echo "AWS_ACCESS_KEY_ID:${AWS_ACCESS_KEY_ID}"
echo "AWS_SECRET_ACCESS_KEY:${AWS_SECRET_ACCESS_KEY}"
echo "AWS_SESSION_TOKEN:${AWS_SESSION_TOKEN}"
AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN" \
aws s3 cp ${UPLOAD_FILE} s3://${BUCKET}/${KEY} --region us-east-1

URL="http://${BUCKET}.s3.amazonaws.com/${KEY}"
START_JSON='{ "url": "'
CENTER_JSON='","tileset": "'
END_JSON='"}'
JSON=$START_JSON$URL$CENTER_JSON$TILESET$END_JSON
curl -X POST -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d "$JSON"  "https://api.mapbox.com/uploads/v1/${USER}?access_token=${MAPBOX_AT}"