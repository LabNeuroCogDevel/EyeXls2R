#!/usr/bin/env perl
use v5.12.3;
use strict;
use warnings;
use Spreadsheet::Read;

say join("\t", qw(subj run start target trial count sacc score lat lat? acc acc? note logic));

# get each spreadsheet
for my $xlsfile (glob('/Volumes/Connor/bars/data/1*/eye_scoring/fs*.xls')){

 # match subject and run number, extract
 next unless $xlsfile =~ m:data/(\d+)/eye_scoring/fs.*(\d).xls:;
 my $subj=$1;
 my $run=$2;

 say "\t$subj $run\n";

 # read in xls file
 say "reading $xlsfile";
 my $wb = ReadData($xlsfile);
 
 say "done";
 last;

 for my $cells ($wb->[1]{cell}) {
  say join("\t",$subj,$run,@$cells),"\n" if $cells->[1] =~ m/50|100|200/ 
                                         && ($cells->[6] == 1 || $cells->[8] ==1);
 }
 last;
}



