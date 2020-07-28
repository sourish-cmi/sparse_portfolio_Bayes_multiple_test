log_posterior<-function(theta,sigma,theta_hat,Z_inv,Lambda,Lambda_inv,tau,k,p,rho,nu0){
  
  ## log-likelihood
  
  #wrapper_likelihood<-function(idx){
  # S0<- sigma[idx]^2*Z_inv
  # lik<- dmvnorm(x=theta_hat[,idx]
  #          ,mean=theta[,idx]
  #          ,sigma=S0
  #          ,log=TRUE)
  #  return(lik)
  #}
  #lik1<-sfLapply(1:k,wrapper_likelihood)
  #lik<-sum(unlist(lik1))
  
  lik<-0
  for(idx in 1:k){
    S0<- sigma[idx]^2*Z_inv
    lik<- lik + dmvnorm(x=theta_hat[,idx],mean=theta[,idx],sigma=S0,log=TRUE)
  }
 
  ## log-prior
  ## prior on tau
  
  lHC<-dHCauchy(x=tau,log=TRUE)
  
  ## prior on Lambda
  
  #R<-matrix(c(1,0,0,1),nrow=2)
  R<-diag(nrow=(p+1))
  Psi<-(rho*R)
  df<-rho
  
  l_Lambda<-log(dwish(W=Lambda,v=df,S=Psi)+1)
  
  #prior for sigma
  
   #wrapper_prior_sigma<-function(idx){
   #      sc<-sp<-nu0/2
   #     return(dinvGamma(x=sigma[idx],shape=sp,scale=sc,log=TRUE))
   #   }

   #lsigma1<-sfLapply(1:k,wrapper_prior_sigma)
   #lsigma<-sum(unlist(lsigma1))
   
   sc<-sp<-nu0/2
   lsigma<-0
   for(idx in 1:k) lsigma<-lsigma + dinvGamma(x=sigma[idx],shape=sp,scale=sc,log=TRUE)

   ## prior on theta
   #wrapper_prior_theta<-function(idx){
  #    m0<-matrix(c(0,rep(1,p)),nrow=(p+1))
  #    S0<-tau^2*Lambda_inv
  #    return(dmvnorm(theta[,idx],mean=m0,sigma=S0,log=TRUE))
  # }
  #lthet1<-sfLapply(1:k,wrapper_prior_theta)
  #lthet<-sum(unlist(lthet1))
  
   m0<-matrix(c(0,rep(1,p)),nrow=(p+1))
   S0<-tau^2*Lambda_inv
   lthet<-0
   for(idx in 1:k) lthet<-lthet+dmvnorm(theta[,idx],mean=m0,sigma=S0,log=TRUE)
   
   
   #print(c(lik,lHC,l_Lambda,lthet,lsigma))
  #return(lik)
  #return(lHC)
  #return(l_Lambda)
  return(lik+lHC+l_Lambda+lthet+lsigma)
}