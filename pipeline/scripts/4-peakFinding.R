#!/usr/bin/Rscript

.libPaths(new = "/hpc/local/CentOS7/dbg_mz/R_libs/3.2.2")

# load required packages 
# none 

# define parameters 
cmd_args <- commandArgs(trailingOnly = TRUE)
for (arg in cmd_args) cat("  ", arg, "\n", sep="")

filepath <- cmd_args[1]
outdir <- cmd_args[2]
scanmode <- cmd_args[3]
thresh <- as.numeric(cmd_args[4])
resol <- as.numeric(cmd_args[5])
scripts <- cmd_args[6]

# create output folder
dir.create(paste(outdir, "4-specpks", sep="/"),showWarnings = F)

# load in function scripts
source(paste(scripts, "AddOnFunctions/sourceDir.R", sep="/"))
sourceDir(paste(scripts, "AddOnFunctions", sep="/"))

load(paste(outdir, "breaks.fwhm.RData", sep="/"))
load(filepath)

options(digits=16)
int.factor=1*10^5 # Number of x used to calc area under Gaussian (is not analytic)
scale=2 # Initial value used to estimate scaling parameter
width=1024
height=768

### fit Gaussian estimate mean and integrate to obtain intensity
findPeaks.Gauss.HPC <- function(plist, breaks.fwhm, int.factor, scale, resol, outdir, scanmode, plot, thresh, width, height) {
  sampname <- colnames(plist)[1]
  
  range = as.vector(plist)
  names(range) = rownames(plist)
  
  values = list("mean"=NULL,"area"=NULL,"nr"=NULL,"min"=NULL,"max"=NULL,"qual"=NULL,"spikes"=0)
  
  values = searchMZRange(range,values,int.factor,scale,resol,outdir,sampname,scanmode,plot,width,height,thresh)
  
  outlist.persample=NULL
  outlist.persample=cbind("samplenr"=values$nr, "mzmed.pkt"=values$mean, "fq"=values$qual, "mzmin.pkt"=values$min, "mzmax.pkt"=values$max, "height.pkt"=values$area)

  index=which(outlist.persample[,"height.pkt"]==0)
  if (length(index)>0) {
    outlist.persample=outlist.persample[-index,]
  }
  
  save(outlist.persample, file=paste(outdir, "4-specpks", paste(sampname, "_", scanmode, ".RData", sep=""), sep="/"))
  
  cat(paste("There were", values$spikes, "spikes!"))
}


if (scanmode == "negative") {
  findPeaks.Gauss.HPC(sum_neg, breaks.fwhm, int.factor, scale, resol, outdir, scanmode, FALSE, thresh, width, height)
} else {
  findPeaks.Gauss.HPC(sum_pos, breaks.fwhm, int.factor, scale, resol, outdir, scanmode, FALSE, thresh, width, height)
}
