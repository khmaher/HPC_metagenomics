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
  This HPC tutorial is based largely upon the NEOF Shotgun Metagenomics Workshop written by Sam Haldenby and Matthew R. Gemmell.
  
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
  
  To add our job to the job scheduler, we would submit the shell scripts using 'qsub'
  (don't do this its simply an example).

  ```
  ## EXAMPLE, DON'T RUN
  qsub scripts/example_script.sh
  ```

  We could then view the job that we have submitted to the job queue using 'squeue'.

  ```
  squeue --me

  ```

  The job will then receive the allocated resources, the task will run, and the appropriate output files generated.
  In the following workflow, since the output from a particular step is often the input for the next step, you need
  to wait for each job to finish before submitting the next.


  <br>
  <font size="4"><b>2.6) Passing command line arguments to a script</b></font>
  <br>
  As well as running the standardised scripts there are some parameters which will be unique to you, or
  your project. For example, these might be your genome name.<br>

  To run a script with these extra parameters (termed 'arguments') we supply them on the command line with a 'flag'.
  For example, you might supply your genome file name to a script using the '-g' flag as

  ```
  a_demo_script.sh -g my_orgamism.fa
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

  Create new subdirectories to keep your scripts and raw data organised:
  ```
  mkdir /fastdata/$USER/my_project
  mkdir /fastdata/$USER/my_project/scripts
  mkdir /fastdata/$USER/my_project/raw_data
  mkdir /fastdata/$USER/my_project/genome
  ```
<br>
  <font size="4"><b>3.2) Required data inputs</b></font>
  <br>
  For this workflow, you need to provide the raw, paired-end DNA sequence data
  and also a reference genome to align this data to.
  <br>
  <br>
  <font size="4"><b>3.3) Load required data onto the HPC</b></font>
  <br>
  There are a couple of ways to get access to your data. If you have generated the data/genome
  yourself/through NEOF you will need to copy this over to your raw data folder. 
  
  If this is the case you need to contact NEOF staff and they will be able to tell you 
  where to copy this data from.

  If, for example, your data directory was called 'NEOF_project_010123' and the genome directory 
  'genome_010123', then you would copy it onto your raw_data and genome directories with the following:
  
  ```
  cp -r /fastdata/bo4kma_shared/NEOF_project_010122/* /fastdata/$USER/my_project/raw_data/
  cp -r /fastdata/bo4kma_shared/genome_010123/* /fastdata/$USER/my_project/genome/
  ```

  Alternatively, to copy data from your personal computer onto the HPC you need to use a file transfer
  application such as 'scp' (advanced), MobaXterm, or [FileZilla](https://filezilla-project.org/).
  Ensure to copy the data into your '/fastdata/<user>my_project/raw_data' folder and genome into 
  '/fastdata/<user>my_project/genome' folder.
  
  Another option is to download the data from a data repository such as the [NCBI SRA](https://www.ncbi.nlm.nih.gov/sra). More on this below.

  Run 'ls' on your 'raw_data' folder and you should see something like the following
  
  ```
  ls raw_data
  # sample1_R1_001.fq.gz
  # sample1_R2_001.fq.gz
  # sample2_R1_001.fq.gz
  # sample2_R2_001.fq.gz
  ```
  Make sure that you have removed any `tar.gz` files and any files labelled unclassified, e.g. `Unclassified_R1` `Unclassified_R2`. 
  <br>

  The workflow assumes that the '/fastdata/<user>my_project/raw_data' directory contains sequence data that is:

  * Paired (two files per biological sample)

  * Demultiplexed

  * FASTQ format

  * (optional, but recommended) in the compressed .gz format
  <br>
  
  Run 'ls' on your 'genome' folder and you should see something like the following (if you have copied over a genome file that you have generated with NEOF).

  
  ```
  ls genome
  # genome.fasta
  ```
  If you don't yet have a genome file in this folder do not worry. We will cover downloading publically accessible genomes in the following chapter.
  
 

  <br>
  <br>
  <b><font size="4">3.4) Copy the analysis scripts</b></font>
  <br>
  Download the scripts from this github repository and then copy them into your scripts folder. You can then delete the github download.

  ```
  git clone "https://github.com/ewan-harney/SNPs-discovery-for-Fluidigm"
  cp SNPs-discovery-for-Fluidigm/scripts/* /fastdata/$USER/my_project/scripts
  rm -rf SNPs-discovery-for-Fluidigm
  ```
   </details>
  <br>
 
 <details><summary><font size="6"><b>4)  Download reference genome</b></font></summary>
  <br>
  <br>
  
  Now we are set up we are ready to start preparing your data. The first thing you want to do is to add your reference genome. 
  <br>
  If you have not generated the genome file yourself and it is available on a public repository you can use the 
  '01_download_geome.sh' script. 
  <br>
  This script downloads your genome and then indexes it using [bwa index](https://bio-bwa.sourceforge.net/bwa.shtml) ready for aligning your data later.
    <br><br>
  To download your genome, submit the '01_download_geome.sh' script as shown below. First remember to navigate to your '/fastdata/$USER/my_project' directory
  <br><br>
  <b>The command line arguments you must supply are:</b><br>
  - the download link for your genome (-w)
  - the file name for your genome (-g)
  <br><br>
  
  ``` 
 qsub scripts/01_download_genome.sh \
 -w https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/017/639/245/GCA_017639245.1_MMon_1.0/GCA_017639245.1_MMon_1.0_genomic.fna.gz \
 -g GCA_017639245.1_MMon_1.0_genomic.fna.gz
  ```
 
 When the script has finished running you should have a genome and index files in your genome directory. 
 
 <br>
 If you have added your genome to your genome folder manually you can index it by typing the following into the command line.
 
 <br><br>
  
  ``` 
  source ~/.bash_profile
  bwa index genome/genome_name.fa
  ```
   













</details>
  <br> 
       
 <details><summary><font size="6"><b>6)  QC and data trimming</b></font></summary>
  <br>
  <br>    
 
  The next step is to check the quality of your fastq files and then perform quality trimming.
  
  First you will run the script to generate the quality plots. This first runs [fastqc](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) on each sample separately. 
  [MultiQC](https://multiqc.info) is then run to generate a combined quality plot. Two MultiQC plots are generated, one for all forward reads and one for reverse reads. These 
  can be found in the 'fastqc' folder when the script has finished running.
  <br><br>
  <b>The command line arguments you must supply are:</b><br>
  - the file extension for your forward reads (-f)
  - the file extension for your reverse reads (-r)
  <br><br>
  
   <br>
  
  
  ```   
 qsub scripts/03_fastqc.sh -f _1.fastq.gz -r _2.fastq.gz
  ``` 
  
  <br>
  For most datasets:

- The quality decreases towards the end of the reads
- The R2 reads have poorer quality than the R1 reads
- The read sizes have a range compared to all being one size. However, most of the reads are towards the long end of the range.

  Generally, even if data is looking good we would carry out quality control to get rid of any poor data that is masked by the very good data and to remove any adapter sequences.
   <br>
   <br>
  In the next step we will carry out quality control for the fastq files. 
  
  Quality control generally comes in two forms:

  1. Trimming: This is directly cutting off bits of sequence. This is typical in the form of trimming off low quality bases from the end of reads and trimming off adapters at the start of reads.
  2. Filtering: This occurs when entire reads are removed. A typical occurrence of this is when a read is too short as we do not want reads below a certain length.

  To carry this out, we are going to use [Trimmomatic](http://www.usadellab.org/cms/index.php?page=trimmomatic).

  
  <br>
  To run Trimmomatic we will use the '04_trimmomatic.sh' script. This has many optional parameters you can use for filtering and trimming your data. 
  By default this script assumes you are using paired end daya and the phred quality encoding is phred33 (like most Illumina data).
  <br>
  <b>The command line arguments you must supply are:</b><br>
  
  - the file extension for your forward reads (-f)
  - the file extension for your reverse reads (-r)
  <br><br>
  
  <b>Optionally, you can also supply:</b><br>
  
  - parameters for ILLUMINACLIP (-k).
  - parameters for SLIDINGWINDOW (-s)
  - parameters for LEADING (-l)
  - parameters for TRAILING (-t)
  - parameters for CROP (-c)
  - parameters for HEADCROP (-h)
  - parameters for MINLEN (-m) 
  <br><br>

  More details of the optional parameters can be found below or in the [trimmomatic manual](http://www.usadellab.org/cms/index.php?page=trimmomatic)
  
  - ILLUMINACLIP: These settings are used to find and remove Illumina adapters. First, a fasta file of known adapter sequences is given, followed by the number of mismatches allowed between the adapter and read sequence and then thresholds for how accurate the alignment is between the adapter and read sequence.
  - SLIDINGWINDOW: This specifies to scan the read quality over a 4 bp window, cutting when the average quality drops below 30.
  - LEADING: The minimum quality value required to keep a base at the start of the read.
  - TRAILING: The minimum quality value required to keep a base at the end of the read.
  - CROP: Cut the read to a specified length
  - HEADCROP: Cut the specified number of bases from the start of the read
  - MINLEN: This specifies the minimum length of a read to keep; any reads shorter than 50 bp are discarded.
    <br><br>
  An example of how to run 'trimmomatic' can be found below. Ensure the 'TruSeq3-PE-2.fa' located in the 'scripts' directory is moved to your 'my_project' directory before running this command.
 
  The trimmed files can be found in the 'trim' directory when complete.
 
 <br><br>
 
 ```   
 qsub scripts/04_trimmomatic.sh -f _1.fastq.gz -r _2.fastq.gz \
 -k ILLUMINACLIP:TruSeq3-PE-2.fa:2:30:12 \
 -s SLIDINGWINDOW:4:30 \
 -m MINLEN:80
 ``` 
 <br>
 </details>
 <br>
   
 <details><summary><font size="6"><b>7)  Re-check quality</b></font></summary>
  <br>
  <br> 

  Now we have run trimmomatic we can check how successful our quality control has been but running fastQC and MultiQC again. These 
  can be found in the 'fastqc2' folder when the script has finished running.
   <br><br>
  
   <br> 

  ```   
 qsub scripts/05_fastqc2.sh
  ```   
  <br><br>
  If you are not satisfied with the quality or number of reads retained after filtering you can go back to the trimmomatic step and repeat the quality control but changing the parameters.
  
  </details>
  <br>
  
 <details><summary><font size="6"><b>8) Align short reads to the reference genome</b></font></summary>
  <br>
  <br>  
 
 We are now ready to map our reads to our reference genome. To do this we will use BWA to align our trimmed sequences to our reference genome.
 <br>
 We have already indexed our genome when we downloaded it. You should have index files with the  extensions '.sa', '.pac', '.ann', '.amb' and '.bwt' that will be automatically detected and used in the mapping step below. 
 
 bwa mem is an alignment algorithm well suited to Illumina-length sequences. The default output is a SAM (Sequence Alignment Map format). 
 However, here we pipe the output to samtools, a program for writing, viewing and manipulating alignment files, to sort and generate a BAM format, a binary, compressed version of SAM format.
 <br>
 The following script will first map our paired end data generated from trimmomatic to our reference, it will then combine the single end orphan reads into a single file and map those to the genome. 
 The resulting BAM files are then combined into a single file which will be used in the next step to call SNPs.
 
  <br>
  <b>The command line argument you must supply is:</b><br>
  - the name of your reference genome (-g)
   <br><br>
  
   <br>
 
  ```   
 qsub scripts/06_align.sh -g GCA_017639245.1_MMon_1.0_genomic.fna.gz
  ```  
  
  <br>
  When the 06_align.sh has finished running your BAM files will be located in the 'aligned' folder.
 
  </details>
  <br>
 
