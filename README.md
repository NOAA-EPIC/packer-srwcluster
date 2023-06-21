# packer-srwcluster

### AWS SRW configuration:
packer build srw-cluster.pkr.hcl -var "date=4May2023"


### AWS LandDA configuration:
vi srw-cluster.pkr.hcl #edit line 141: from srw-cluster-start-script.sh to landda-cluster-container-start-script.sh
packer build srw-cluster.pkr.hcl -var "date=4May2023"
