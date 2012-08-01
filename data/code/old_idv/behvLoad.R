library(gdata)
library(foreach)
library(doMC)

filelist<-read.table('beh_xls_filelist.txt')
names(filelist)<-"path"


registerDoMC(12)

bad="/Users/lncd/rcn/bea_res/Data/Tasks/BarsBehavioral/Basic/10595/20080718/Scored/Run02/finalscoring_10595_rpn2.xls"
bad2="/Users/lncd/rcn/bea_res/Data/Tasks/BarsBehavioral/Basic/10604/20111119/Scored/Run02/fs_10604_bars2.xls"
#e=filelist$path[1]
eyedata_beh <- foreach(e=filelist$path[!filelist$path %in% c(bad,bad2)], .inorder=TRUE) %dopar% {
 e<-as.character(e)
 library(gdata)
 edat <- read.xls(e,sheet=1,pattern="Target")
 Subject  <- as.numeric(sub(".*Basic/(\\d+)/(\\d+)/Scored/Run(\\d+)/.*", "\\1", e, perl=TRUE))
 Date     <- as.numeric(sub(".*Basic/(\\d+)/(\\d+)/Scored/Run(\\d+)/.*", "\\2", e, perl=TRUE))
 Run      <- as.numeric(sub(".*Basic/(\\d+)/(\\d+)/Scored/Run(\\d+)/.*", "\\3", e, perl=TRUE))

 cat(e,Subject,Date,Run,"\n")

 if ("Latency" %in% names(edat)) edat <- subset(edat, Latency > 0) #filter saccades before target onset

 drop.trials <- which(!1:42 %in% unique(edat$Trial))

 # return out of loop if cannot read 
 if(!'Start' %in% names(edat) ) { 
     cat("bad:",Subject)
     return(list(subject=Subject,run=Run,date=Date,exp="barsBehave", raw.data=list(), correct=list(), error=list(), drop.trials=list(), error.trials=list(), correct.trails=list()) )
  }

 edat$valence <- edat$Start
 edat$valence[] = "Neu"
 edat$valence[edat$Start <200]  = "Loss"
 edat$valence[edat$Start <60]   = "Rew"
 edat$valence<-as.factor(edat$valence)

 # codes are given in blocks of 4, 2 left then 2 right, 5 blocks
 #(111,112) + 4*(0..11), 201, 202 # left target codes
 #(113,114) + 4*(0..11), 203, 204 # right target codes
 edat$side <- edat$Target
 edat$side[edat$Target %in% c(sapply(c(111,112),function(x){x+rep(4,11)*c(0:10)}),201,202) ] <- "Left"
 edat$side[edat$Target %in% c(sapply(c(113,114),function(x){x+rep(4,11)*c(0:10)}),203,204) ] <- "Right"
 edat$side <- as.factor(edat$side);
  
 # anything that has a 1 (either lat or acc) is a correct saccad
 correct <- subset(edat, Define.Lat==1 | Define.Acc==1,  select=c(Start, Target, Trial, Latency, Define.Lat, Define.Acc, Notes, valence, side))
 # get latancy for first correct saccade by:
 #correct$Latency[!duplicated(correct$Trial)]
 # remove duplicate
 #correct[duplicated(correct$Trial)] <- NULL
 
 error <- subset(edat, Define.Lat %in% c(2,4,5), select=c(Start, Target, Trial, Latency, Define.Lat, Define.Acc, Notes, valence, side))
 #error[duplicated(error$Trial)] <- NULL
 # or better subset on Define.Lat==2
 
 error.trials <- unique(error$Trial)
 corr.trials <- unique(correct$Trial)

 # this returned value builds eyeData list
 list(subject=Subject,run=Run,date=Date,exp="barsBehave", raw.data=edat, correct=correct, error=error, drop.trials=drop.trials, error.trials=error.trials, correct.trials=corr.trials)
 
}

save(eyedata_beh, file="eyeDataList_behv_20120727.Rdata")
