
eyedat.acc <- function(eyedata) {
   library(plyr)
   accuracy <- ldply(eyedata, function(el) {
         if(!'Define.Lat' %in% names(el$error)) { return() }
         if(!'date' %in% names(el)) { el$date <- 0 }

         # sub set only to get the 2,x 
         error        <- subset(el$error, Define.Lat==2)
         # only get the first correct in each trial
         correct     <-  el$correct[!duplicated(el$correct$Trial),]
         all <- rbind(error,correct)


         tot.correct  <- nrow(correct)
         tot.error    <- nrow(error)
         tot.drop     <- length(el$drop.trials)
         rew.correct  <- length(which(correct$valence=="Rew"))
         neu.correct  <- length(which(correct$valence=="Neu"))
         loss.correct <- length(which(correct$valence=="Loss"))
         rew.error    <- length(which(error$valence=="Rew"))
         neu.error    <- length(which(error$valence=="Neu"))
         loss.error   <- length(which(error$valence=="Loss"))

         data.frame(subject=el$subject,date=el$date, run=el$run, tot.correct=tot.correct, 
                    tot.error=tot.error, tot.acc=tot.correct/(tot.correct+tot.error), 
                    tot.drop=length(el$drop.trials), rew.correct=rew.correct, 
                    percent.drop=tot.drop/(tot.error+tot.correct+tot.drop),
                    neu.correct=neu.correct, loss.correct=loss.correct,
                    rew.error=rew.error, neu.error=neu.error, loss.error=loss.error,
                    rew.acc=rew.correct/(rew.correct+rew.error), 
                    neu.acc=neu.correct/(neu.correct+neu.error), 
                    loss.acc=loss.correct/(loss.correct+loss.error),
                    correct.lat=mean(correct$Latency), 
                    correct.lat.rew=mean(correct$Latency[which(correct$valence=="Rew")]), 
                    correct.lat.neu=mean(correct$Latency[which(correct$valence=="Neu")]), 
                    correct.lat.los=mean(correct$Latency[which(correct$valence=="Loss")]), 
                    error.lat=mean(error$Latency), 
                    error.lat.rew=mean(error$Latency[which(error$valence=="Rew")]), 
                    error.lat.neu=mean(error$Latency[which(error$valence=="Neu")]), 
                    error.lat.los=mean(error$Latency[which(error$valence=="Loss")]), 
                    all.lat=mean(all$Latency), 
                    all.lat.rew=mean(all$Latency[which(all$valence=="Rew")]), 
                    all.lat.neu=mean(all$Latency[which(all$valence=="Neu")]), 
                    all.lat.los=mean(all$Latency[which(all$valence=="Loss")])
         )
   })

   return(accuracy)
}
