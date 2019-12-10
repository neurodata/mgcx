#!/bin/bash
#SBATCH --job-name=mgcxARs
#SBATCH --array=0-17
#SBATCH --time=3-0:0:0
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=48
#SBATCH --mem=750G
#SBATCH --partition=lrgmem
#SBATCH --exclusive
#SBATCH --mail-type=end
#SBATCH --mail-user=jaewonc78@gmail.com

module load python/3.7
source ~/mgcx_experiments/env/bin/activate

echo "My SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID
python3 extinction_rate.py $SLURM_ARRAY_TASK_ID
echo "job complete"
