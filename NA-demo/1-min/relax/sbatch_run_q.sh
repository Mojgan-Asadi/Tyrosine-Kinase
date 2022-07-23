#!/bin/bash
#SBATCH --job-name=1-min
#SBATCH --output=slurm-%x-%j.out
#SBATCH --constrain=xeon-4116
#SBATCH --time=1:00:00
#SBATCH --partition=main
#SBATCH --mem-per-cpu=1GB
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=16


module load Q6

OK="(\033[0;32m   OK   \033[0m)"
FAILED="(\033[0;31m FAILED \033[0m)"

steps=( $(ls -1v *inp | sed 's/.inp//') )
echo Job Began: `date`

for step in ${steps[@]}
do
  if [ -f "${step}.log" ]; then
    echo "Skipping step ${step}"
  else
    echo "Running step ${step}"
    srun --mpi=pmi2 -n $SLURM_NTASKS Qdyn6p ${step}.inp > ${step}.log
  fi

  if [[ $(grep "terminated normally" ${step}.log) ]]; then 
    echo "OK"
  else
    echo "---  FAILED  ---"
    echo "See ${step}.log for details."
    break
  fi
done

echo Finished: `date`

