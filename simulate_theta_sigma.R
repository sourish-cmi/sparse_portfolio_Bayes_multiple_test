## Globar parameters D, Z, Sigma_c, X, rt, ni, nu0, mu_c
simulate_theta_sigma<-function(idx){
  library(tseries)
  d1<-na.omit(data.frame(cbind(X,rt[,names(ni[idx])])))
  
  
  X1<-as.matrix(d1[,1:(p+1)])
  #print(head(X1))
  y<-d1[,(p+2)]
  m1<-D%*%(t(X1)%*%y+Sigma_c %*% mu_c)
  
  ## Update theta
  theta<-rmvnorm(1,mean=m1,sigma=D*sigma[idx]^2)
  
  ## Update sigma
  b<-matrix(theta,nrow=(p+1),ncol=1)
  diff<-y-X1 %*% b
  diff<-na.omit(diff)
  
  sc<-0.5*(t(diff) %*% (diff)+nu0)
  sp<-(ni[idx]+nu0)/2
  sigma1<-1/rgamma(1,shape=sp,scale=sc)
  
 return(list(theta=theta,sigma=sigma1))
}