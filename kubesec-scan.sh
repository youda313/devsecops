#!/bin/bash

#kubesec-scan.sh

#Removed the service definition from the YAML file as not recognized by kubesec
awk '/---/{exit} 1' k8s_deployment_service.yaml > K8s_deployment_only.yaml

# using kubesec v2 api
# scan_result=$(curl -sSX POST --data-binary @"K8s_deployment_only.yaml" https://v2.kubesec.io/scan)
# scan_message=$(curl -sSX POST --data-binary @"K8s_deployment_only.yaml" https://v2.kubesec.io/scan | jq .[0].message -r ) 
# scan_score=$(curl -sSX POST --data-binary @"K8s_deployment_only.yaml" https://v2.kubesec.io/scan | jq .[0].score ) 


# using kubesec docker image for scanning
scan_result=$(docker run -i kubesec/kubesec:512c5e0 scan /dev/stdin < K8s_deployment_only.yaml)
scan_message=$(docker run -i kubesec/kubesec:512c5e0 scan /dev/stdin < K8s_deployment_only.yaml | jq .[].message -r)
scan_score=$(docker run -i kubesec/kubesec:512c5e0 scan /dev/stdin < K8s_deployment_only.yaml | jq .[].score)

rm -rf K8s_deployment_only.yaml
	
    # Kubesec scan result processing
    # echo "Scan Score : $scan_score"

	if [[ "${scan_score}" -ge 5 ]]; then
	    echo "Score is $scan_score"
	    echo "Kubesec Scan $scan_message"
	else
	    echo "Score is $scan_score, which is less than or equal to 5."
	    echo "Scanning Kubernetes Resource has Failed"
	    exit 1;
	fi;