rm(list=ls())
source("log_posterior_parallel.R")
source("dinvGamma.R")
source("dHCauchy.R")
source("proposal_4_HC.R")
source("simulate_theta_sigma.R")
source("CAPM_HB_selection.R")
source("Factor_Model_HB_selection.R")
library(snowfall)
library(mvtnorm)
library(MCMCpack)


load("yahoo_snp500_adj_close_return_20181101.RData",verbose=TRUE)

dsn<-adj_close_return[["ret"]]
dsn$Date<-as.Date(dsn$Date)


date.start.month <- seq(as.Date("2001-12-01"),length=200,by="months")
date.end.month <- seq(as.Date("2002-01-01"),length=200,by="months")-1

tst.dt.start.mnth <- seq(as.Date("2002-01-01"),length=200,by="months")
tst.dt.end.mnth <- seq(as.Date("2002-02-01"),length=200,by="months")-1

## Test
#check<-Factor_Model_HB_selection(start=date.start.month[j],end=date.end.month[j],nmc=100,burn=50,month_id=j)


path_nm<-"/Horse_Shoe_Prior/CAPM_HB"

process_start_time<-Sys.time()
for(j in 1:200){
  iteration_start_time<-Sys.time()
  check<-Factor_Model_HB_selection(start=date.start.month[j],end=date.end.month[j],nmc=1000,burn=500,month_id=j)
  file_nm<-paste("Month",j,sep="_")
  file_nm<-paste(file_nm,"RData",sep=".")
  full_file_nm<-paste(path_nm,file_nm,sep="/")
  save(check,file=full_file_nm)
  iteration_end_time<-Sys.time()
  cat(iteration_end_time-iteration_start_time,"\n")
}
process_end_time<-Sys.time()
process_end_time-process_start_time

