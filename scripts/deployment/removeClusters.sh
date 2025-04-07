for i in $(seq 1 1 56)
    do 
        pcluster delete-cluster --region us-east-1 --cluster-name uifcweventfinal-cluster-$i
    done
