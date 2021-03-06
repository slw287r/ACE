# ACE

Absolute Copy number Estimation using low-coverage whole genome sequencing data

This readme only contains an executive summary of ACE. You can read the accompanying paper as soon as its published. For now, some info is in here, and tons of info is in the R documentation. Additionally, a vignette is available which is written more or less as a guide and walkthrough. 

### Installation

ACE is an R package. It will become available via Bioconductor. If it is, the following commands will install ACE into R:

if (!requireNamespace("BiocManager", quietly=TRUE))
    install.packages("BiocManager")

BiocManager::install("ACE")

If it is not yet available, or you wish to use the development version, you can install ACE directly using the devtools package:

devtools::install_github("tgac-vumc/ACE")

Required dependencies for ACE are **Biobase**, **QDNAseq**, and **ggplot2**.

### Citation

ACE is described in the following publication:

ACE: Absolute Copy number Estimation from low-coverage whole-genome sequencing data.
Poell JB, Mendeville M, Sie D, Brink A, Brakenhoff RH, Ylstra B.
Bioinformatics. 2018 Dec 28. doi: 10.1093/bioinformatics/bty1055

Please cite this paper when using ACE!

### What is ACE?

ACE is a an absolute copy number estimator that scales copy number data to fit with integer copy numbers. For this it uses segmented data from the QDNAseq package, which in turn uses a number of dependencies to turn mapped reads (in bam-files) into segmented data. Note: make sure QDNAseq fetches the bin annotations from the same genome build as the one used for aligning the sequencing data! On with ACE! In brief: ACE will run QDNAseq or use its output rds-file of segmented data. It will subsequently run through all samples in the object(s), for which it will create individual subdirectories. For each sample, it will calculate how well the segments fit (the relative error) to integer copy numbers for each percentage of "tumor cells" (cells with divergent segments). Note that it does not estimate for a lower percentage than 5. ACE will produce a graph with relative errors (all errors relative to the largest error). Said graph can be used to quickly identify the most likely fit. ACE selects all "minima" and saves the corresponding copy number plots. The "best fit" (lowest error) is not by definition the most likely fit! ACE will run models for a general tumor ploidy of 2N, but you can expand this to include any ploidy of your choosing. The program needs to make one assumption: the median bin segment value corresponds with the tumor's general ploidy. If none of the fits are to your liking, there are several functions to help you out. This is extensively covered in the vignette.

### ACE has arrived!

There are a number of core functions: **runACE**, **ploidyplotloop**, **objectsampletotemplate**, **singlemodel**, **squaremodel**, **singleplot**, **getadjustedsegments**, **linkvariants**, **postanalysisloop**, **analyzegenomiclocations**. I have also added the **multiplot** function for making summary sheets.

**runACE** takes a folder with rds-files (default, make sure all represent segmented QDNAseqCopyNumbers objects) or bam-files and returns plots for the most likely errors in convenient subfolders. In case of bam-files it will run binsizes 30, 100, 500 and 1000 kbp as default, but a vector of desired binsizes can be used as input. Binsizes available are 1, 5, 10, 15, 30, 50, 100, 500, and 1000 kbp. Note that output will be larger and programs will run longer with the smaller binsizes (1 kbp is pretty hardcore). <br>*ploidies* specifies for which ploidies fits will be made: default is 2 but you can input a vector with all desired ploidies, e.g. c(2,4). <br>Beggers be choosers! **runACE** likes pdf-files, but for large datasets or small binsizes you might want to go with *imagetype* = 'png'. <br>*method*: A standard method for error calculation is the root mean squared error (RMSE), but you can argue you should actually punish more the long segments that are a little bit off compared to the short segments that are way off. 'MAE' weighs every error equally, whereas 'SMRE' does the latter; these will generally generate more fits (I see that as a downside), but it is more likely that the segments of which you are sure are sticking tighter to the integer ploidy in the best fit. <br>The parameter *penalty* sets a penalty for the error calculated at lower cellularity: errors are divided by the cellularity to the power of the penalty: default = 0 (no penalty). Adding a penalty (0.5 is usually decent) comes at a cost. At high cellularities it has reduced precision (especially when minima are not sharp). And to state the obvious: you don't want to penalize fits at low cellularities when you expect them (e.g. you know your samples have a very low tumor cell percentage).<br>Functionality for large data sets (many samples!): fits will always have to be chosen manually, but you can open the file with all errorlists to pick the most likely fit without looking at the copy number profile. Use the generated tab-delimited file to fill in the column with the likely fit. <br>*trncname* (truncate name) which truncates the name to everything before the first instance of _ - set TRUE if applicable, or specify regular expression, e.g. "-.*" to REMOVE everything after and including the first dash found in a sample name. <br>*printsummaries*: superbig summary files may crash the program, so you can set this argument to FALSE, or 2 if you still want the error plots.

**ploidyplotloop** is the meat of **ACE**, and it can be run as a separate function as well. It takes a QDNAseq-object as input and also needs a folder to write the files to. This function is particularly handy if you want to analyze a whole QDNAseq-object that is already loaded in your R environment.

**objectsampletotemplate** is pretty much there to parse QDNAseqobjects into the dataframe structure used by the **singlemodel** and **singleplot** functions. These latter functions call **objectsampletotemplate** itself when necessary, but it can be handy to make a template if you expect some repeated use of the functions or if you want to make the template and then do your own obscure manipulations to it (you know you want to!)

**singlemodel**: like the name implies it runs the fitting algorithm on a single sample and spits out the info you want! Not strictly necessary to save it to a variable, but that might still be handy. It returns a list with the model parameters, data, and errorplot. **singlemodel** comes with the awesomeness of manual input: you can restrain the model to the ploidy you expect (default 2, but hey, ploidy 5 happens, right?) and you can tell the program if you think there is a different standard (this should only be necessary when the median segment happens to be a subclonal variant; very rare).

**squaremodel**: this function runs the algorithm over a range of ploidies. If you feel you are doing too much tinkering with variables using the **singlemodel** function, then try this! You can choose the range of ploidies it should test; the default being all ploidies between 5 and 1 in 100 decrements of 0.04. Like **singlemodel**, the function returns a list, which you can save to a variable. Even though this function was mainly developed for troubleshooting difficult samples, users may want to use it more systematically (for instance if the majority of their samples are difficult). I have made two add-on functions for this: **squaremodelsummary** creates a summary of the squaremodel, and **loopsquaremodel** loops through all samples of an object (and requires the summary function as well) to return summaries of all samples. 

**singleplot**: again, you already know what it does! It offers an extra degree of customization, for instance to change the chart title, the error, choose a subset of chromosomes, limit the y-axis. Don't believe the cellularities the algorithm calculated for you? You don't have to! Just fill in the cellularity you believe to be true, and singleplot will take your word for it! Since all graphs created by ACE use ggplot2, you can do a lot of customizations on the plots after making them. 

**getadjustedsegments**: get info of the actual segments in a handy data frame! Contains start and end location, "number of probes" (number of bins supporting the segment value), value of the segment (Segment_Mean is the value from QDNAseq, Segment_Mean2 is calculated from adjustedcopynumbers within the segment), and the nearest ploidy with the chance (log10 p-value) that the segment has this ploidy. A very low p-value indicates a high chance of subclonality, although this value should be approached with extreme caution (and is at the moment not corrected for multiple testing).

**linkvariants**: now we're talking! Give a tab-delimited file with variant data, and this function will tell you what the copy number is at that genomic location (again, check the genome build used for alignment!), and it will guess how many copies are mutant! Read more about the options for this function in the function documentation.

**postanalysisloop**: you've run **ACE**, you've picked your models, you have your mutation data ... Now if you could only ... say no more! This function combines the power of all above functions. Your go-to-function for batch analysis of all samples in an object.

**analyzegenomiclocations**: a sort of simplified version of **linkvariants**, you can manually input a single genomic location as specified by chromosome and position. You can also input multiple locations using vectors of the same length. The output will be a data frame. You can also enter frequencies to quickly calculate mutant copies, but then you also need to enter cellularity! Note: the function requires the data frame with adjusted segments (output of **getadjustedsegments**). Obviously, you should enter the same cellularity as you've used for the **getadjustedsegments** function.

Additional functions are available in accessory_functions.R. Check out their documentation for usage.

There are some more snippets of advice in the code, and tons more in the function documentation. For a walkthrough ... try the walkthrough in the vignette! 

That's pretty much it for now, let us know if you run into some errors or oddities: j.poell@amsterdamumc.nl and rh.brakenhoff@amsterdamumc.nl

P.s. ACE uses the ggplot2-package for output plots. If you wish to use ACE-functions that return plots in a loop or a function of your own and save these plots to file, you need to feed the plots into the graphics device with the print() function. This is a peculiarity of ggplot2.
