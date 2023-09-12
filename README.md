# Understanding k-mers and ploidy using Smudgeplot

This session is part of [**Biodiversity Genomics Academy 2023**](https://BGA23.org)

## Session Leader(s)

Kamil S. Jaron; Amjad Khalaf

Tree of Life, Wellcome Sanger Institute

Website: <https://www.sanger.ac.uk/group/jaron-group/>  
K-mer learning materials: <https://github.com/KamilSJaron/oh-know/wiki/Characterization-of-polyploid-genomes-using-k-mer-spectra-analysis>

## Description

By the end of this session you will be able to:

1. Understand how Smudgeplot estimates ploidy
2. Appreciate strengths and weakness of Smudgeplot
3. Run Smudgeplot and understand the input parameters
4. Critically evaluate a Smudgeplot

## Prerequisites

1. Understanding of linux command line basics
2. Knowledge of basic genome biology
3. (optional) read the smudgeplot sections of <https://www.nature.com/articles/s41467-020-14998-3>

!!! warning "Please make sure you MEET THE PREREQUISITES and READ THE DESCRIPTION above"

    You will get the most out of this session if you meet the prerequisites above.

    Please also read the description carefully to see if this session is relevant to you.
    
    If you don't meet the prerequisites or change your mind based on the description or are no longer available at the session time, please email tol-training at sanger.ac.uk to cancel your slot so that someone else on the waitlist might attend.

## Tutorial


Have you ever sequenced something not-well studied? Something that might show strange genomic signatures? Smudgeplot is a visualisation technique for whole-genome sequencing reads from a single individual. The visualisation techique is based on the idea of het-mers. Het-mers are k-mer pairs that are exactly one nucleotide pair away from each other, while forming a unique pair in the sequencing dataset. These k-mers are assumed to be mostly representing two alleles of a heterozygous, but potentially can also show pairing of imperfect paralogs, or sequencing errors paired up with a homozygous genomic k-mer. Nevertheless, the predicted ploidy by smudgeplot is simply the ploidy with the highest number of k-mer pairs (if a reasonable estimate must be evaluated for each individual case!).

### Installing the software & detting some data

Open gitpod. And install the development version of smudgeplot (branch sploidyplot) & FastK. 

```
mkdir src bin && cd src # create directories for source code & binaries
git clone -b sploidyplot https://github.com/KamilSJaron/smudgeplot
git clone https://github.com/thegenemyers/FastK
```

Now smudgeplot make install smudgeplot R package, compiles the C kernel for searching for k-mer pairs and copy all the executables to `workspace/bin/` (which will be our dedicated spot for executables). 

```
cd smudgeplot && make -s INSTALL_PREFIX=/workspace && cd ..
smudgeplot.py -h # test the installation worked out nice
cd FastK && make
install -c FastK Fastrm Fastmv Fastcp Fastmerge Histex Tabex Profex Logex Vennex Symmex Haplex Homex Fastcat /workspace/bin/
FastK # test the installation worked out nice
cd ..
```

Now the software we need is installed, all we need is to download some data; There are 8 datasets for the 8 breakout session, here is a [table of accessions](https://docs.google.com/document/d/13SEd0cIx8BATqDtbLFHnwUwRrSfDYmVniVCqXptK6d0/edit?usp=sharing), we will use the same document to upload our results too; Pick the one that is corresponding to your breakout room, and replace the example one by one of yours. Fetch the data using `wget` command. E.g.

```
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR926/SRR926341/SRR926341_[12].fastq.gz
```

### Constructing a database

The whole process operates with raw, or trimmed sequencing reads. From those we generate a k-mer database using [FastK](https://github.com/thegenemyers/FASTK). FastK is currently the fastest k-mer counter out there and the only supported by the lastest version of smudgeplot*. This database contains an index of all the k-mers and their coverages in the sequencing readset. Within this set user must chose a theshold for excluding low frequencing k-mers that will be considered errors. That choice is not too difficult to make by looking at the k-mer spectra. Of all the retained k-mers we find all the het-mers. Then we plot a 2d histogram. 


*Note: The previous versions of smudgeplot (up to 2.5.0) were operating on k-mer "dumps" flat files you can generate with any counter you like. You can imagine that text files are very inefficient to operate on. The new version is operating directly on the optimised k-mer database instead.

So construct the datavase using FastK. This will take some minutes (15-20):

```
FastK -v -t4 -k31 -M16 -T4 SRR926341_[12].fastq.gz -NSRR926341
```

Now, that you have a database, you can search for k-mer pairs, but I would advice to take a moment and look at a k-mer spectra first. You can get k-mer spectra from the database using `Histex`, a different tool from the same suite.

```
Histex -G SRR8495097 > SRR8495097_k31.hist
```

You can visualize this histogram in anyway, one faily easy one is uploading it to genomescope2 webserver: http://qb.cshl.edu/genomescope/genomescope2.0/ (use default ploidy parameter)

Looking at a k-mer histogram; you should be able to see what is the coverage of the possible genomic k-mers. Also, upload your histogram to [the document](https://docs.google.com/document/d/13SEd0cIx8BATqDtbLFHnwUwRrSfDYmVniVCqXptK6d0/edit?usp=sharing) for our shared results, please. If we look at this example

![example](
http://qb.cshl.edu/genomescope/genomescope2.0/user_data/QQbW8zXct8FErXPSt9Mw/linear_plot.png)

In this example, a meaningful error threshold would be 40x. As a rule of thumb, no dataset should have this threshold <10, and it is not the end of the world if we lose a bit of the real genomic k-mers (as long as there is enough signal). However these are just some gudances, what is sensible really depends on each individual datasets!

### Run smudgeplot

The error threshold is sepcified by the '-L' parameter. We have 4 cores in the GitPod, so you can also run the k-mer pair search in paralel (parameter `-t`). This command will interanlly call a C-kernel optimised for the searched designed by Gene Myers. When executing, don't forget to use names of YOUR sample, not the example one.

```
smudgeplot.py hetmers -L 30 -t 4 --verbose -o SRR926341_k31_pairs SRR926341.ktab
```

and finally, once the k-mer pairs are done (look at the first few lines of the output file to be sure it makes sense), you can finally plot the smudgeplot

```
smudgeplot.py plot -t SRR926341 -o SRR926341_k31_smudgeplot SRR926341_k31_pairs_text.smu
``

How does it look? If the plot looks off, rerun with '-n' and provide a number corresponding to the 1n peak in your genomeplot such as '-n 50'
