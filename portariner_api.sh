#!/bin/sh
token=`http POST :9000/api/auth Username="admin" Password="adminpassword" |grep -i jwt|awk -F \" {'print $4'}`
#echo $token
#Get Endpoint ID from local endpoint
ID=`http --form POST :9000/api/endpoints "Authorization: Bearer $token" Name="test-local" EndpointType=1 |grep -i Id|awk -F : {'print $2'}|awk -F , {'print $1'}`
#List containers in portainer
http GET :9000/api/endpoints/$ID/docker/containers/json "Authorization: Bearer $token" all==true > clist.out
#Create nginx Container, Image should be availabe locally
CONT_ID=`http POST :9000/api/endpoints/$ID/docker/containers/create "Authorization: Bearer $token" name=="web02" Image="nginx:latest" ExposedPorts:='{ "80/tcp": {} }' HostConfig:='{ "PortBindings": { "80/tcp": [{ "HostPort": "8080" }] } }' | awk -F \" {'print $4'}`

http POST :9000/api/endpoints/$ID/docker/containers/$CONT_ID/start "Authorization: Bearer $token"

http GET :9000/api/endpoints/$ID/docker/containers/json "Authorization: Bearer $token" all==true > clist.out2

#diff clist.out*

