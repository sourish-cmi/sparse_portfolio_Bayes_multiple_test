CAPM_MLE_Back_testing<-function(ns=ns,j=j,dsn=dsn,scheme="equal"){
  ### train data
  dsn$Date<-as.Date(dsn$Date)
  d1<-subset(dsn,Date>=date.start.month[j] & Date<=date.end.month[j])
  d1<-d1[,-1]
  n_length<-apply(d1, 2, function(x)unique(x[!is.na(x)]))
  na_col<-0
  
  for(j1 in 1:ncol(d1)){
    if(length(n_length[[j1]])<nrow(d1))na_col<-c(na_col,j1)
  }
  na_col<-na_col[-1]
  if(length(na_col)<ncol(d1)) d1<-d1[,-na_col]
  
  a_hat<-rep(NA,length=(ncol(d1)-1))
  for(i in 1:(ncol(d1)-1)){
    a_hat[i]<-coef(lm(d1[,i]~d1[,"X.GSPC"]))[1]
  }
  names(a_hat)<-colnames(d1)[1:(ncol(d1)-1)]
  a_hat<-sort(a_hat)
  k<-length(a_hat)
  k1<-(k-ns)
  stcks_nm1<-names(a_hat)[k1:k]
  d1<-dsn[,c("Date",stcks_nm1)]
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
  s2<-max((apply(d1,2,var)))
  prior<-diag(1,nrow=nrow(S))
  n<-nrow(d1)
  p<-ncol(d1)
  if(n<=p)n0<-(p-n)+2
  if(n>p)n0<-1
  q<-(n0+n+1)/(n0+n+p)
  Sigma<-q*S+(1-q)*prior
  d1<-as.matrix(d1)
  
  if(scheme=="mw"){
    w_mw<-portfolio.optim(d1,covmat=Sigma)$pw
  }else{
    w_mw<-rep(1/p,p)
  }
  
  ## test data
  
  d1<-dsn[,c("Date",stcks_nm1)]
  d1<-subset(d1,Date>=tst.dt.start.mnth[j] & Date<=tst.dt.end.mnth[j])
  d1<-d1[,-1]
  p_rt_mw<-as.matrix(d1)%*%w_mw
  
  return(p_rt_mw)
}