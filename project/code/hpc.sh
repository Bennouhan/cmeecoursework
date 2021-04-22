# Submit a job with the following command:
# qsub your_job_script
 

# Once a job is submitted, you can follow its progress with qstat command. 
# qstat


# If you need to delete a job, ether while it is still queuing, or running, use the command:
# qdel [jobid]


# The image below shows an example of a job script being submitted on CX1.  The job script is called blastp.pbs, it starts a BLAST job on 16 cores on one node.  The job is started with qsub blastp.pbs. This will return a unique id for the job (9582789). 

# Jobs belonging to one user can be monitored with qstat. In the example below, the first ivocation shows the job waiting in the queue (status "S" is "Q"). The second time, it shows that the job is running "R".  You can also monitor the state of jobs via the web.

# When a job finishes, it disappears from the queue. Any text output is captured by the system and returned to the submission directory,in two files named after the jobscript and with the job id as suffix.

# https://www.imperial.ac.uk/admin-services/ict/self-service/research-support/rcs/support/getting-started/





### Array jobs: 

# Often you may find that you want to run a large number of very similar jobs. Rather than directly submitting each task as a separate job, please consider using an array job. Having created the jobscript as you would do normally, add in the additional directive

#              #PBS -J 1-N
# where N is the number of copies of the job you want to run. You may then qsub the jobscript once, and the system will run N instances of it. Each of these subjobs run independently of all of the others, and are identical  except for the value of the environment variable PBS_ARRAY_INDEX. This will contain a unique value in the range 1-N, allowing you to select the particular input for that subjob.

# You do not need to change the resource selection,  that continues to specify the resources needed by the individual subjobs, not the whole array.

# The system will run individual subjobs as soon as resources become available. Occasionally the system may re-queue running subjobs to free resources for larger jobs. Always write your jobscripts with this in mind. For example, consider what would happen if the re-run subjob detects partial output from a previous run. 

# When execution of the subjobs of an array job has begun, the qstat listing will show the state of the array job as "B" rather than "R". To see the progress through the array, use "qstat -t [jobid]" or look at the comment field in the output of "qstat -f [jobid]"




### Array Example script:

# cat ~/templates/throughput-array


#PBS -lselect=1:ncpus=1:mem=1gb
#PBS -lwalltime=24:0:0
#PBS -J 1-22

## Run 10 copies of this job (-J 1-10)
## The environment variable $PBS_ARRAY_INDEX gives each
## subjob's index within the array

## All subjobs run independently of one another


# Load modules for any applications

module load anaconda3/personal

# Change to the submission directory
cd $HOME/project/code

# Run program, passing the index of this subjob within the array
bash shapeit4_array.sh $PBS_ARRAY_INDEX


#copy scripts
#scp ~/cmeecoursework/project/code/shapeit4_*  bjn20@login.cx1.hpc.ic.ac.uk:~/project/code/