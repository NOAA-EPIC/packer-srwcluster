sudo mkdir /lustre
sudo chmod -R 777 /lustre
cd /lustre
mkdir LandDA
cd LandDA
export LANDDAROOT=`pwd`
wget https://noaa-ufs-land-da-pds.s3.amazonaws.com/current_land_da_release_data/landda-input-data-2016.tar.gz
tar xvfz landda-input-data-2016.tar.gz
export LANDDA_INPUTS=/lustre/LandDA/inputs
singularity build --force ubuntu20.04-intel-landda.img docker://noaaepic/ubuntu20.04-intel-landda:release-public-v1.0.0
export img=/lustre/LandDA/ubuntu20.04-intel-landda.img
module use /opt/spack-stack/spack/share/spack/modules/linux-*
module avail intel
module load intel-oneapi-compilers/2022.1.0
module load intel-oneapi-mpi/2021.6.0
singularity exec -B /lustre:/lustre $img cp -r /opt/land-offline_workflow .
cd $LANDDAROOT/land-offline_workflow
export USE_SINGULARITY=yes

##Complete last 3 commands after build
#vim do_submit_cycle.sh #Line 155 change sbatch submit_cycle.sh to sh submit_cycle.sh
#./do_submit_cycle.sh settings_DA_cycle_gdas
#ls -ls ../landda_expts/DA_GHCN_test/mem000/restarts/vector
