#!/usr/bin/env perl
use v5.12.3;
use strict;
use warnings;

my $expType='anti';

# get best spreadsheet file names for each subjs's run
my %location = (
    'anti' => '/Users/lncd/rcn/bea_res/Data/Tasks/Anti/Basic/*/*/Scored/{Run*/,}f*.xls',
    'barsBehave' => '/Users/lncd/rcn/bea_res/Data/Tasks/BarsBehavioral/Basic/*/*/Scored/Run*/f*.xls',
    'barsscan' => ''
);
my %subjDateRun;
for my $xlsfile (glob($location{$expType})){
 next unless $xlsfile =~ m:Basic/(\d+)/(\d+)/Scored/(Run(\d+)/)?:;
 my $subj=$1;
 my $date=$2;
 my $run=$expType eq 'barsBehave' ? int($4) : "";
 push @{ $subjDateRun{join('-',$subj,$date,$run)} }, $xlsfile;
}

for my $keyref (keys %subjDateRun) {
 
 # get edit file if it exists
 my $xlsfile="";
 for (@{$subjDateRun{$keyref}}) {
   $xlsfile=$_;
   if (m/edit/) { last }
 }

 say $xlsfile;
}



