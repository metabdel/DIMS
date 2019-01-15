#!/bin/bash

$INDIR=$1
$OUTDIR=$2
$SCRIPTS=$3
$JOBS=$4
$ERRORS=$5
$MAIL=$6

scanmode=$7
thresh=$8
label=$9
adducts=$10

. $INDIR/settings.config

find "$OUTDIR/specpks_all_rest" -iname "${scanmode}_*" | while read file;
 do
     qsub -l h_rt=01:00:00 -l h_vmem=8G -N "grouping2_$scanmode" -m as -M $MAIL -o $JOBS -e $ERRORS $SCRIPTS/11-runPeakGroupingRest.sh $file $OUTDIR $SCRIPTS/R $scanmode $resol
     #Rscript peakGrouping.2.0.rest.R $file $SCRIPTS $OUTDIR $resol $scanmode
 done

qsub -l h_rt=01:00:00 -l h_vmem=8G -N "queueFillMissing_$scanmode" -hold_jid "grouping2_$scanmode" -m as -M $MAIL -o $JOBS -e $ERRORS $SCRIPTS/12-queuefillMissing.sh $INDIR $OUTDIR $SCRIPTS $JOBS $ERRORS $MAIL $scanmode $thresh $label $adducts