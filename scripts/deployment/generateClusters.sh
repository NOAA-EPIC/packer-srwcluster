for i in $(seq 1 1 1)
    do 
        pcluster create-cluster --region us-east-1 --cluster-name srwv22-cluster-$i --cluster-configuration srwcluster_nodeconfig_v1.yaml --rollback-on-failure false --debug
    done
