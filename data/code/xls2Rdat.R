library(gdata)
library(foreach)
library(doMC)
registerDoMC(12)
#library(doSMP)


##############
# bars scan
bscan <- list(
        exp      = "barsScan",
        numTrials= 42,
        getFiles =                 {grep("OLD_FS_Files", list.files("/Volumes/Connor/bars/data", "fs.*\\.xls$", 
                                    full.names=TRUE, recursive=TRUE), fixed=FALSE, invert=TRUE, ignore.case=TRUE, value=TRUE)
                                   },
        getSubj  = function(path)  { as.numeric(sub("^.*/fs_(\\d+).*_.*\\d{1}.xls$", "\\1", path, perl=TRUE)) },
        getRun   = function(path)  { as.numeric(sub("^.*/fs_\\d+.*_.*(\\d{1}).xls$", "\\1", path, perl=TRUE))},
        getDate  = function(path)  { 0},
        valence  = function(start) { factor(start, levels=c(50, 100, 200), labels=c("Rew", "Loss", "Neu")) },
        side     = function(target){  factor(sapply(target, function(x) {
               switch(EXPR=as.character(x),
                  "127"="Left",
                  "128"="Left",
                  "129"="Right",
                  "130"="Right",
                  "147"="Left",
                  "148"="Left",
                  "149"="Right",
                  "150"="Right",
                  "201"="Left",
                  "202"="Left",
                  "203"="Right",
                  "204"="Right")
            })) }
        )

##############
# bars behave
bbehv <- list(
        exp      = "barsBehv",
        numTrials= 60,
        getFiles = function(){
                     filelist<-read.table('filelist/beh_xls_filelist.txt')
                     names(filelist)<-"path"
                     filelist$path
                     },
        getSubj  = function(path)  { as.numeric(sub(".*Basic/(\\d+)/(\\d+)/Scored.*", "\\1", e, perl=TRUE))},
        getDate  = function(path)  { as.numeric(sub(".*Basic/(\\d+)/(\\d+)/Scored.*", "\\2", e, perl=TRUE))},
        getRun   = function(path)  { as.numeric(sub(".*Basic/(\\d+)/(\\d+)/Scored/Run(\\d+)/.*", "\\3", e, perl=TRUE))},
        valence  = function(start) { 
                valence<-start
                valence[] = "Neu"
                valence[start <200]  = "Loss"
                valence[start <60]   = "Rew"
                as.factor(valence)
         },
        side     = function(target){ 
                side <- target
                # codes are given in blocks of 4, 2 left then 2 right, 5 blocks
                #(111,112) + 4*(0..11), 201, 202 # left target codes
                #(113,114) + 4*(0..11), 203, 204 # right target codes
                side[target %in% c(sapply(c(111,112),function(x){x+rep(4,11)*c(0:10)}),201,202) ] <- "Left"
                side[target %in% c(sapply(c(113,114),function(x){x+rep(4,11)*c(0:10)}),203,204) ] <- "Right"
                as.factor(side)
         }
        )

##############
# anti  (similiar to bars_behv)
anti <- bbehv
anti$exp      <- "anti" 
anti$getRun   <- function(path) { 0 }
anti$getFiles <- function(){
                     filelist<-read.table('filelist/anit_xls_filelist.txt')
                     names(filelist)<-"path"
                     as.vector(filelist$path)
                  }


##############
# one off, find some subjects that just got scored (from bars behave)
bb_oneOff <- bbehv
bb_oneOff$getSubj <- bscan$getSubj
bb_oneOff$getDate <- bscan$getDate
bb_oneOff$getRun  <- bscan$getRun
bb_oneOff$getFiles <- function(){
                        filelist=data.frame(path=c("../fs_10811_bars1.xls","../fs_10811_bars2.xls"))
                        as.vector(filelist$path)
                      }

##############################################


# pick a list to use

expList <- bb_oneOff

# iterate through

eyedata <- foreach(e=expList$getFiles(), .inorder=TRUE) %do% {
#e=expList$getFiles()[1]

  library(gdata)
  
  Subject <- expList$getSubj(e)
  Date    <- expList$getDate(e)
  Run     <- expList$getRun(e)

  cat(e," ",Subject,Date,Run,"\n")
  edat <- read.xls(e, sheet=1, pattern="Target")

  ### couldn't read file!
  if(!'Start' %in% names(edat) ) { 
     cat("bad:",Subject)

     # return out of loop if cannot read 
     return(
        list(subject=Subject,run=Run,date=Date, exp=exp, raw.data=list(), correct=list(),
             error=list(), drop.trials=list(), error.trials=list(), correct.trails=list())
        )
  }

  # filter out saccades occuring before target onset
  if ("Latency" %in% names(edat)) edat <- subset(edat, Latency > 0)


  # valence: Rew, Loss, Neut
  edat$valence <- expList$valence(edat$Start)

  
  # side: Right, Left
  if (length(edat$Target) > 0) { edat$side <- expList$side(edat$Target) 
  } else                       { edat$side <- as.factor(integer(0))     }  #no rows
  
  
  # find error and correct
  # anything that has a 1 (either lat or acc) is a correct saccad
  correct <- subset(edat, Define.Lat==1 | Define.Acc==1,  select=c(Start, Target, Trial, Latency, Define.Lat, Define.Acc, Notes, valence, side))
  error   <- subset(edat, Define.Lat %in% c(2,4,5),       select=c(Start, Target, Trial, Latency, Define.Lat, Define.Acc, Notes, valence, side))
  
  # collect each trail error or correct occurs
  error.trials <- unique(error$Trial)
  corr.trials  <- unique(correct$Trial)

  # check that error and corr trials don't overlap
  if(length(intersect(error.trials,corr.trials))>0) { cat("WARNING: ", Subject, " correct and error overlap!!!") }

  # trials that are neither correct nor error are dropped
  drop.trials=setdiff(1:expList$numTrials, c(error.trials,corr.trials))


  # this returned value builds eyedata list
  list(subject=Subject,run=Run,date=Date, exp=exp, raw.data=edat, correct=correct, 
       error=error, drop.trials=drop.trials, error.trials=error.trials, correct.trials=corr.trials)
}

# save results
save(eyedata_barsScan, file=paste(sep="","export/eyeDataList_",expList$exp,"31Jul2012.Rdata"))

