<img src="images/shef_logo.png"
     alt="Sheffield University Icon"
     style="left; margin-right: 30px;" />
<img src="images/NEOF.png"
    alt="NEOF Icon"
    style="left; margin-right: 10px;" />
<br>
<br>
## Metagenomics Workflow using UoS BESSEMER.
<br>
<font size="4">
<details><summary><font size="6"><b>1) About, credits, and other information</b></font></summary>
  <br>
  <br>
  This HPC tutorial is based largely upon the NEOF Shotgun Metagenomics written by Sam Haldenby and Matthew R. Gemmell.
  
  Whilst it has been written for use with The University of Sheffield's
  [BESSEMER](https://docs.hpc.shef.ac.uk/en/latest/bessemer/index.html) system,
  the below should be applicable to any GNU/Linux based HPC system, with
  appropriate modification (your mileage may vary).

  Code which the user (that's you) must run is highlighted in a code block like this:
  ```
  I am code - you must run me
  ```
  Sometimes the desired output from a command is included in the code block as a comment.
  For example:
  ```
  Running this command
  # Should produce this output
  ```

  Filepaths within normal text are within single quote marks, like this:

  '/home/user/a_file_path'
  <br><br>
  Contact: Katy Maher //  kathryn.maher@sheffield.ac.uk
  </details>
<br>
<details><summary><font size="6"><b>2) Getting started on the HPC.</b></font></summary>
  <br>
  <br>
  <font size="4"><b>2.1) Access the HPC</b></font>
  <br>
  To access the BESSEMER high-performance computer (HPC) you must be connected
  to the university network - this can be achieved remotely by using the
  virtual private network (VPN) service.

  [Please see the university IT pages for details on how to connect to the VPN.](https://students.sheffield.ac.uk/it-services/vpn)

  Once connected to the VPN you also need to connect to the HPC using a secure shell (SSH)
  connection. This can be achieved using the command line on your system or a software package
  such as [MobaXterm](https://mobaxterm.mobatek.net/).

  [See the university pages for guidance on how to connect to the VPN](https://docs.hpc.shef.ac.uk/en/latest/hpc/index.html).

  <br>
  <font size="4"><b>2.2) Access a worker node on BESSEMER</b></font>
  <br>
  Once you have successfully logged into BESSEMER, you need to access a worker node:

  ```
  srun --pty bash -l
  ```
  You should see that the command prompt has changed from

  ```
  [<user>@bessemer-login2 ~]$
  ```
  to
  ```
  [<user>@bessemer-node001 ~]$
  ```
  ...where \<user\> is your The University of Sheffield (TUoS) IT username.

  
  <br>
  <font size="4"><b>2.3) Load the Genomics Software Repository</b></font>
  <br>
  The Genomics Software Repository contains several pre-loaded pieces of software
  useful for a range of genomics-based analyses, including this one.
  
  Type:
  ```
  source ~/.bash_profile
  ```
  
  Did you receive the following message when you accessed the worker node?
  ```
  Your account is set up to use the Genomics Software Repository
  ```

  If so, you are set up and do not need to do the following step.
  If not, enter the following:
  ```
  echo -e "if [[ -e '/usr/local/extras/Genomics' ]];\nthen\n\tsource /usr/local/extras/Genomics/.bashrc\nfi" >> $HOME/.bash_profile
  ```
  ...and then re-load your profile:
  ```
  source ~/.bash_profile
  ```
  Upon re-loading, you should see the message relating to the Genomics Software Repository above.

  
  <br>
  <font size="4"><b>2.4) Set up your conda profile</b></font>
  <br>
  If you have never run conda before on the Bessemer you might have to initialise your conda, to do this type:
  
  ```
  conda init bash
  ```
  
  You will then be asked to reopen your current shell. Log out and then back into Bessemer and then continue. 
  <br>
  
  <font size="4"><b>2.5) Running scripts on the HPC cluster</b></font>
  <br>
  Each step in the following workflow consist of two separate scripts; an R script (file extension: .R)
  and a shell script (file extension: .sh).
  <br>
  The R script contains the instructions to perform the dada2 analysis and by submitting it as a
  script rather than individual commands, as you may be used to doing in RStudio, we can run lots
  of steps in succession without requiring any additional input.
  <br>
  In order to submit a job to the high performance computing (HPC) cluster we need to wrap the R script
  up in a shell script - this script requests resources and adds our job into the queue.

  An example of a pair of these scripts can be seen in the 'scripts' directory

  ```
  ls scripts/01*
  scripts/01_remove_Ns.R  scripts/01_run_remove_Ns.sh
  ```

  To add our 'remove Ns' job to the job scheduler, we would submit the shell script using 'qsub'
  (don't do this yet, simply an example).

  ```
  ## EXAMPLE, DON'T RUN
  qsub scripts/01_run_remove_Ns.sh
  ```

  We could then view the job that we have submitted to the job queue using 'squeue'.

  ```
  squeue --me

  ```

  The job will then receive the allocated resources, the task will run, and the appropriate output files generated.
  In the following workflow, since the output from a particular step is often the input for the next step, you need
  to wait for each job to finish before submitting the next.
  You have the option to provide an email address to receive a notification when each job is complete.


  <br>
  <font size="4"><b>2.6) Passing command line arguments to a script</b></font>
  <br>
  As well as running the standardised dada2 scripts there are some parameters which will be unique to you, or
  your project. For example, these might be your primer sequences or trimming parameters.<br>

  To run a script with these extra parameters (termed 'arguments') we supply them on the command line with a 'flag'.
  For example, you might supply your email address to a script using the '-E' flag as

  ```
  a_demo_script.sh -E <user>@university.ac.uk
  ```
  </details>
  <br>

  <details><summary><font size="6"><b>3) Load data and access scripts</b></font></summary>
  <br>
  <br>
  <font size="4"><b>3.1) Create a working directory and load your data</b></font>
  <br>
  You should work in the directory '/fastdata' on BESSEMER as this allows shared access to your files
  and commands, useful for troubleshooting.

  Check if you already have a directory in '/fastdata' by running the command exactly as it appears below.

  ```
  ls /fastdata/$USER
  ```

  If you receive the message
  ```
  ls: cannot access /fastdata/<user>: No such file or directory
  ```
  Then you need to create a new folder in '/fastdata' using the command exactly as it appears below:

  ```
  mkdir -m 0755 /fastdata/$USER
  ```

  Create new subdirectories to keep your scripts, data files, and R objects organised:
  ```
  mkdir /fastdata/$USER/my_project
  mkdir /fastdata/$USER/my_project/scripts
  mkdir /fastdata/$USER/my_project/raw_data
  mkdir /fastdata/$USER/my_project/working_data
  mkdir /fastdata/$USER/my_project/R_objects
  ```
  <br>
  <font size="4"><b>3.2) Required data inputs</b></font>
  <br>
  For this workflow, you need to provide the raw, paired-end DNA sequence data
  and also a suitably formatted reference database applicable to your choice of metabarcoding
  marker.
  The dada2 authors maintain some correctly formatted databases at (https://benjjneb.github.io/dada2/training.html)
  although these are (currently) only suitable for 16S markers.
  <br>
  <br>
  <font size="4"><b>3.3) Load required data onto the HPC</b></font>
  If you have sequenced your samples with NEOF, and have been notified that your data
  has been received, then you should be able to find your data on the HPC server.

  Please talk to us about where you should copy your data from.

  If, for example, your data directory was called 'NBAF_project_010122', then you would
  copy it onto your raw_data directory with the following:
  ```
  cp -r /fastdata/bo4kma_shared/NBAF_project_010122/ /fastdata/$USER/my_project/raw_data/
  ```

  Alternatively, to copy data from your personal computer onto the HPC you need to use a file transfer
  application such as 'scp' (advanced), MobaXterm, or [FileZilla](https://filezilla-project.org/).
  Ensure to copy the data into your '/fastdata/<user>my_project/raw_data folder'.

  Run 'ls' on your 'raw_data' folder and you should see something like the following
  ```
  ls raw_data
  # sample1_S1_R1_001.fq.gz
  # sample1_S1_R2_001.fq.gz
  # sample2_S2_R1_001.fq.gz
  # sample2_S2_R2_001.fq.gz
  ```
  
  Make sure that you have removed any `tar.gz` files and any files labelled unclassified, e.g. `Unclassified_R1` `Unclassified_R2` 
  <br>

  <font size="4"><b>3.4) Data file naming convention</b></font>
  <br>
  The workflow assumes that the '/fastdata/<user>my_project/raw_data' directory contains sequence data that is:

  * Paired (two files per biological sample)

  * Demultiplexed

  * FASTQ format

  * (optional, but recommended) in the compressed .gz format

  Each pair of files relating to each biological sample should ideally have the following naming convention:
  <br>
  <i>(although any convention with consistent naming of R1 and R2 files is acceptable).</i>
  ```
  <sample_ID>_S<##>_R1_001.fastq.gz

  <sample_ID>_S<##>_R2_001.fastq.gz
  ```

  Where \<sample_ID\> is a unique identifier, and S<##> is a sample number (generally assigned by the sequencer itself).

  For example, a pair of files might look like this:

  ```
  SoilGB_S01_R1_001.fastq.gz

  SoilGB_S01_R2_001.fastq.gz
  ```

  <br><br>
  <font size="4"><b>3.5) Automatic detection of file extensions</b></font>
  <br>
  The scripts below attempt to determine which are your paired 'R1' files and
  which are the paired 'R2' files automatically based on their file names. During the
  first step (N-removal), a log file named something
  like "01_run_remove_Ns.o2658422" will be generated which contains the automatically
  detected extensions.
  <br><br>
  If the extensions automatically detected are correct, you do not need to do
  anything. If they are incorrect then you can override the automatic process
  by specifying the R1 extensions (-W) and the R2 (-P) extensions.
  <br><br> This automatic detection occurs throughout the workflow but you can
  specify the extensions at steps where they are required using -W and -P if necessary.
  <br>
  <br>
  <b><font size="4">3.6) Copy the dada2 R scripts</b></font>
  <br>
  Download the scripts from this github repository and then copy them into your scripts folder. You can then delete the github download.

  ```
  git clone "https://github.com/khmaher/HPC_dada2"
  cp HPC_dada2/scripts/* /fastdata/$USER/my_project/scripts
  rm -r HPC_dada2
  ```
  <br>
  </details>
<br>
<details><summary><font size="6"><b>4) Check required files and perform preliminary filtering.</font></b></summary>
  <br>
  <br>
  <font size="4"><b>4.1) Check files and activate R environment</b></font>
  <br>
  Ensure that:

  * you are in the 'my_project' directory

  * you have the 'raw_data', 'scripts', 'working_data', and 'R objects' directories present

  * the 'raw_data' directory contains your sequence files

  * the 'scripts' directory contains the R (.R files) and shell scripts (.sh files).

  ```
  pwd
  # /fastdata/$USER/my_project

  ls
  # raw_data  scripts   working_data  R_objects

  ls raw_data/
  # raw_input_file_S01_001_R1.fastq.gz
  # raw_input_file S01_001_R2.fastq.gz
  # [.... lots more data files here....]

  ls scripts/
  #00_run_full_pipeline.sh  
  #01_remove_Ns.R
  #01_run_remove_Ns.sh
  # [.... lots more data scripts here....]


  ```
  You should also be able to load the R environment without seeing any error messages:
  ```
  source ~/.bash_profile
  conda activate /usr/local/extras/Genomics/apps/mambaforge/envs/metabarcoding
  ```
  
  You should see the environment "metabarcoding" at the start of your terminal prompt, e.g. `(metabarcoding) [USERNAME@bessemer-node001]` 
  <br>
  If any of this is missing, go back to section 3 above and double check everything.
  <br>
  <br>
  <font size="4"><b>4.2 Remove reads with Ns</b></font>
  <br>
  Dada2 requires reads which do not contain any N characters. An N may be introduced
  into a sequence read when the sequencing software is unable to confidently basecall
  that position. This will likely be a small proportion of the sequence reads in the input
  files.

  <br><br>
