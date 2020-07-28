CAPM_Fang_Back_testing<-function(ns=ns,j=j,dsn=dsn,scheme="equal"){
  library(lars)
  ### train data
  dsn$Date<-as.Date(dsn$Date)
  d1<-subset(dsn,Date>=date.start.month[j] & Date<=date.end.month[j])
  d1<-d1[,-c(1,ncol(d1))]
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
  prior<-diag(s2,nrow=nrow(S))
  n<-nrow(d1)
  p<-ncol(d1)

  if(n<=p)n0<-(p-n)+2
  if(n>p)n0<-1
  q<-(n0+n+1)/(n0+n+p)
  Sigma<-q*S+(1-q)*prior
  d1<-as.matrix(d1)
  w_mw<-portfolio.optim(d1,covmat=Sigma)$pw
  Y<-d1%*%w_mw
  X<- matrix(0,nrow=n,ncol=p)
  
  for(j1 in 1:n){   ## j: day
    for(k in 1:p){ ## k: stocks
      X[j1,k]<- Y[j1]-d1[j1,k] 
      ## X[j,k] is the difference between j^th day portfolio return and j^th day's k^th stock return for i^th risk-profile
    }
  }
  
  model.lasso<-lars(x=X,y=Y,type="lasso",use.Gram = F)
  w_optim<-coef(model.lasso)[nrow(coef(model.lasso)),1:p]
  names(w_optim)<-stcks_nm[1:p]
  #final selection
  w_select<-w_optim[w_optim!=0]
  stcks_nm1<-names(w_select)
  
  ## weight 
  d2<-d1[,stcks_nm1]
  S<-cov(d2)
  s2<-max((apply(d2,2,var)))
  prior<-diag(s2,nrow=nrow(S))
  n<-nrow(d2)
  p<-ncol(d2)
  if(n<=p)n0<-(p-n)+2
  if(n>p)n0<-1
  q<-(n0+n+1)/(n0+n+p)
  Sigma<-q*S+(1-q)*prior
  d2<-as.matrix(d2)
  if(scheme=="mw"){
    w_mw<-w_mw<-portfolio.optim(d2,covmat=Sigma)$pw
  }else{
    w_mw<-rep(1/p,p)
  }
  #print(w_mw)
  
  ###### Test data
  d3<-dsn[,c("Date",stcks_nm1)]
  
  d3<-subset(d3,Date>=tst.dt.start.mnth[j] & Date<=tst.dt.end.mnth[j])
  d3<-d3[,-1]
  p_rt_L1<-as.matrix(d3)%*%w_mw
  
  return(p_rt_L1)
  
}
#CAPM_Fang_Back_Testing(ns=ns,j=168,dsn=dsn)