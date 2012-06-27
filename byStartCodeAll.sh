#!/usr/bin/env bash

##
# * aggregate by start code across all scored runs
# * write ${startcode}.tsv
#    * subj,run,row#,xls row(start,target....)
# * from /Volumes/Connor/bars/data/1*/eye_scoring/fs*.xls
#
#
#       The first column in each file has a number 50,100 or 200 corresponding
#       to different trial types. for each trial type, grab the entire row that
#       has a "1" under the define lat OR define acc columns. 
#
#       Make a different file for each trial type (50,100,200), concatenate
#       across runs and subjects within these files.
#
#
#

# write header
echo -e "subj\trun\tstart\ttarget\ttrial\tcount\tsacc\tscore\tlat\tlat?\tacc\tacc?\tnote\tlogic" > all.tsv

# for all the final scored files
# TODO: expand wildcard glob to match newly scored data
for f in /Volumes/Connor/bars/data/1*/eye_scoring/fs*.xls; do
   # get subject id from filename
   subj=$f                                 # set equal to path of file
   subj=${subj#/Volumes/Connor/bars/data/} # strip off leading path
   subj=${subj%/eye_scoring*}              # strip off trailing path
   export subj                             # export to env. so perl can see it
  
   #get run, should always be the number 5th to last place on the path (ie *#.xls)
   export run=${f:(-5):1}
  
  
   # append matching rows to the start code file
   #   ENV{subj,run} are file specific
   #   @F has the xls row as an array
   #   print these seperated by tabs
   #   only if the first col is the start code and lat or acc is defined
   #   check worksheet (expect sheet1) to speed up a bit (already super slow)
   XLSperl -lane 'last if $WS ne "Sheet1"; 
   print join("\t",@ENV{subj,run},@F) if( $F{A} =~ m/^(50|100|200)$/ && $F{H}+$F{J} >= 1);' $f | tee -a all.tsv


done