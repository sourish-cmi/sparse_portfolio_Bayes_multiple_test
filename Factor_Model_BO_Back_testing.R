Factor_Model_BO_Back_testing<-function(ns=ns,j=j,dsn=dsn,scheme="equal",x_nm=c("X.GSPC","X.DJI","X.NYA","X.RUT","X.VIX")){
  ### train data
  p <- length(x_nm)
  stck_nm<-colnames(dsn)[-1]
  dsn$Date<-as.Date(dsn$Date)
  d1<-subset(dsn,Date>=date.start.month[j] & Date<=date.end.month[j])
  d1<-d1[,-1]
  n_length<-apply(d1, 2, function(x)unique(x[!is.na(x)]))
  na_col<-0
  for(j1 in 1:ncol(d1)){
    if(length(n_length[[j1]])<nrow(d1)/2)na_col<-c(na_col,j1)
  }
  na_col<-na_col[-1]
  if(length(na_col)<ncol(d1)) d1<-d1[,-na_col]
  
  ## Compute S_i_tilde
  
  n<-nrow(d1)
  Int<-rep(1,n)
  rm <-d1[,x_nm]
  X<-as.matrix(cbind(Int,rm),nrow=n,ncol=(p+1))
  C<-X%*%solve(t(X)%*%X)%*%t(X)
  mu0<-c(0,1,rep(0,(p-1)))
  sigma_i<-S_tilde<-rep(NA,length=(ncol(d1)-p))
  #print(colnames(d1))
  print(ncol(d1)-p)
  c_nm<-colnames(d1)
  
  for(i in 1:(ncol(d1)-p)){
    modl <-paste(c_nm[i],"~",sep = " ")
    modl <- paste(modl,paste(x_nm,collapse = "+"))
    modl <- as.formula(modl)
    
    
    sigma_i[i]<-summary(lm(modl,data = d1))$sigma
    y<-as.matrix(d1[,i],nrow=n,ncol=1)
    S_tilde[i]<-(t(y-X%*%mu0)%*%C%*%(y-X%*%mu0))/sigma_i[i]^2
  }
  S_tilde_idx<-sort.int(S_tilde,index.return = TRUE,decreasing = TRUE)$ix
  stcks_nm1<-stck_nm[S_tilde_idx][1:ns]
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
  
  d1<-dsn[,c("Date",stcks_nm)]
  d1<-subset(d1,Date>=tst.dt.start.mnth[j] & Date<=tst.dt.end.mnth[j])
  d1<-d1[,-1]
  p_rt_mw<-as.matrix(d1)%*%w_mw
  #print(w_mw)
  return(p_rt_mw)
}

#Factor_Model_BO_Back_testing(ns=25,j=9,dsn=dsn)
