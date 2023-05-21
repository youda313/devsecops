#!/bin/bash
#cis-etcd.sh
# docker run --pid=host -v $(which kubectl):/usr/local/mount-from-host/bin/kubectl -v ~/.kube:/.kube -e KUBECONFIG=/.kube/config -v /etc:/etc:ro -v /var:/var:ro -it --rm -t aquasec/kube-bench:latest run --targets etcd  --version 1.15 --check 2.2 --json
# total_fail=$(kube-bench run --targets etcd  --version 1.15 --check 2.2 --json | jq .[].total_fail)

total_fail=$(docker run --pid=host -v $(which kubectl):/usr/local/mount-from-host/bin/kubectl -v ~/.kube:/.kube -e KUBECONFIG=/.kube/config -v /etc:/etc:ro -v /var:/var:ro -it --rm -t aquasec/kube-bench:latest run --targets etcd  --version 1.15 --check 2.2 --json | jq .Totals.total_fail)

if [[ "$total_fail" -ne 0 ]];
        then
                echo "CIS Benchmark Failed ETCD while testing for 2.2"
                exit 1;
        else
                echo "CIS Benchmark Passed for ETCD - 2.2"
fi;
