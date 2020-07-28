Factor_Model_HB_Back_testing<-function(ns=ns,j=j,dsn=dsn,scheme="mw"){
  file_nm<-paste("Month",j,sep="_")
  file_nm<-paste(file_nm,"RData",sep=".")
  full_file_nm<-paste(path_nm,file_nm,sep="/")
  data<-load(full_file_nm,verbose=TRUE)
  
  k<-length(check$P_a_gt_0)
  k1<-(k-ns)
  w<-sort(check$P_a_gt_0)[k1:k]
  stcks_nm<-names(w)
  dsn$Date<-as.Date(dsn$Date)
  
  ## Markowitz Optimization on CAPM-HB selected stocks
  
  d1<-dsn[,c("Date",stcks_nm)]
  # train data
  d1<-subset(d1,Date>=date.start.month[j] & Date<=date.end.month[j])
  d1<-data.frame(d1[,-1])
  n_length<-apply(d1, 2, function(x)unique(x[!is.na(x)]))
  na_col<-0
  for(j1 in 1:ncol(d1)){
    if(length(n_length[[j1]])<nrow(d1))na_col<-c(na_col,j1)
  }
  na_col<-na_col[-1]
  if(length(na_col)<ncol(d1)) d1<-d1[,-na_col]
  S<-cov(d1)
  stcks_nm<-colnames(S)
  s2<-mean(apply(d1,2,var))
  
  prior<-diag(s2,nrow=nrow(S))
  n<-nrow(d1)
  p<-ncol(d1)
  if(n<=p)n0<-(p-n)+2
  if(n>p)n0<-1
  q<-(n0+n+1)/(n0+n+p)
  Sigma<-q*S+(1-q)*prior
  d1<-as.matrix(d1)
  
  if(scheme=="mw"){
    w_capm_mw<-portfolio.optim(d1,covmat=Sigma)$pw
  }else{
    w_capm_mw<-rep(1/p,p)
  }
  
  ## Test data
  d1<-dsn[,c("Date",stcks_nm)]
  d1<-subset(d1,Date>=tst.dt.start.mnth[j] & Date<=tst.dt.end.mnth[j])
  d1<-d1[,-1]
  
  p_rt_capm_mw<-as.matrix(d1)%*%w_capm_mw
  
  return(p_rt_capm_mw)
}

## Factor_Model_HB_Back_testing()