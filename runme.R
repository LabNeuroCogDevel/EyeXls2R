# if save files DNE 
# cd('data')
# code/xls2Rdat.R # for exp type, all output will be saved as eyedata
# cd('..')
source('accuracy.R')

# ANTI
load('data/eyeDataList_anti_20120727.Rdata');
write.csv(eyedat.acc(eyedata_anti) ,file="data/export/ANTI_accuracy.csv")

# BARS BEHAVE
load('data/eyeDataList_behv_20120727.Rdata');
write.csv(eyedat.acc(eyedata_beh),file="data/export/barsBehave_accuracy.csv")

# BARS  SCAN
load('data/eyeDataList_barsScan31Jul2012.Rdata');
write.csv(eyedat.acc(eyedata_behScan),file="data/export/barsScan_accuracy.csv")
