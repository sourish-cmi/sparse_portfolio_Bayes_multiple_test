Factor_Model_HB_selection<-function(start,end,nmc=100,burn=50,month_id,x_nm=c("X.GSPC","X.DJI","X.NYA","X.RUT","X.VIX")){
  ## library required
  library(snowfall)
  library(mvtnorm)
  library(MCMCpack)
  
  rt<-subset(dsn, Date>=start & Date<=end )
  p<-length(x_nm)
  
 
  n_length<-apply(rt, 2, function(x)unique(x[!is.na(x)]))
  na_col<-0
  for(j1 in 1:(ncol(rt)-p)){
    if(length(n_length[[j1]])<(nrow(rt)/2))na_col<-c(na_col,j1)
  }
  na_col<-na_col[-1]
  
  
  rt<-rt[,-na_col]
  tckk_rt<-colnames(rt)
  rt[,2:ncol(rt)]<-rt[,2:ncol(rt)]*100
  
  ## Calculate Z
  
  X<-matrix(NA,nrow=nrow(rt),ncol=(p+1))
  colnames(X)<-c("Intercept",x_nm)
  X[,1]<-1
  X[,x_nm]<-as.matrix(rt[,x_nm])
  Z<-t(X)%*%X
  Z_inv<-solve(Z)
  theta_hat<-matrix(NA,nrow=(p+1),ncol=(ncol(rt)-(p+1)))
  
  for(j1 in 2:(ncol(rt)-p)){
    dum_dat<-cbind.data.frame(rt[,tckk_rt[j1]],rt[,x_nm])
    colnames(dum_dat)<-c(tckk_rt[j1],x_nm)
    model<-as.formula(paste(tckk_rt[j1],"~."))
    model<-lm(model,data = dum_dat)
    theta_hat[,(j1-1)]<-coefficients(model)  
    if(j1 %% 50 == 0) cat("j1 = ",j1, "\n")
  }
  
  
  
  colnames(theta_hat)<-tckk_rt[2:(ncol(rt)-p)]
  rownames(theta_hat)<-names(coefficients(model))
  
  k<-ncol(theta_hat) #No of Stocks
  ni<-rep(NA,ncol(rt))
  for(j1 in 1:ncol(rt))ni[j1]<-length(na.omit(rt[,j1]))
  
  names(ni)<-colnames(rt)
  
  ni<-ni[names(ni)!="Date"]
  for(j1 in 1:length(x_nm))ni<-ni[names(ni)!=x_nm[j1]]
  
  ### Hyper-prior Specification
  
  rho<-(p+1)
  nu0<-1
  mu_c<-matrix(c(0,rep(1,p)),nrow=(p+1))
  
  ## Initialize
  
  
  sigma<-rep(1,k)
  Sigma_c<-diag((p+1))
  
  theta<-matrix(NA,nrow=(p+1),ncol=k)
  tau<-1 ## Global shrinkage
  
  
  R<-diag(nrow=(p+1))
  
  sigma_save<-matrix(0,nrow=nmc, ncol=k)
  theta_save<-array(0,dim=c((p+1),k,nmc))
  Sigma_save<-array(0,dim=c((p+1),(p+1),nmc))
  tau_save<-rep(NA,length=nmc)
  
  ## parallelization 
  sfInit(parallel=TRUE,cpus=15,type="SOCK")

  sfExport("Z")
  sfExport("Z_inv")
  sfExport("X")
  sfExport("rt")
  sfExport("ni")
  sfExport("nu0")
  sfExport("rho")
  sfExport("mu_c")
  sfExport("k")
  sfExport("p")
  sfExport("theta_hat")
  sfExport("theta")
  sfExport("sigma")
  sfExport("Sigma_c")

  sfLibrary(mvtnorm)
  sfLibrary(MCMCpack)

  sfSource("log_posterior_parallel.R")
  sfSource("dinvGamma.R")
  sfSource("dHCauchy.R")
  sfSource("proposal_4_HC.R")
  sfSource("simulate_theta_sigma.R")

 
#### GIBBS Sampling
sfClusterSetupRNG()
cat("Gibbs sampling starts", "\n")
for(t in 1:(nmc+burn)){
  if(t %% 10 == 0) cat("Month ID = ",month_id,", Iteration = ",t, "\n")
  D<-solve(Z+Sigma_c)
  Sigma_inv<-solve(Sigma_c)


  sfExport("D")
  sfExport("Sigma_c")

  ## Update theta & sigma using parallel processor

  #simulate_theta_sigma(idx=1)
  result<-sfLapply(1:k,simulate_theta_sigma)
  
  ## extract simulated values
  for(j1 in 1:k){
    theta[,j1]<-result[[j1]]$theta
    sigma[j1]<-result[[j1]]$sigma
  }

  # Update Sigma_c
  
  Psi<-matrix(0,nrow=(p+1),ncol=(p+1))

  for(j1 in 1:k){
    Psi<-Psi+(theta[,j1]-mu_c)%*%t(theta[,j1]-mu_c)  
  }

  Psi_post<-(Psi+rho*R)
  df<-k+rho
  Sigma_c<-rwish(v=df,S=Psi_post)
  Sigma_inv<-solve(Sigma_c)
  


  # Update tau
  sfExport("theta")
  sfExport("Sigma_inv")
  sfExport("Sigma_c")
  tau_proposal<-proposal_4_HC(param=tau)


  ## Metropolis Hastings step 
  probab = exp(log_posterior(theta=theta,sigma=sigma 
                             ,theta_hat=theta_hat,Z_inv=Z_inv
                             ,Lambda=Sigma_c 
                             ,Lambda_inv=Sigma_inv,tau=tau_proposal
                             ,k=k,p=p,rho=rho,nu0=nu0)
               -log_posterior(theta=theta ,sigma=sigma 
                              ,theta_hat=theta_hat,Z_inv=Z_inv
                              ,Lambda=Sigma_c 
                              ,Lambda_inv=Sigma_inv,tau=tau
                              ,k=k,p=p,rho=rho,nu0=nu0))
  

  if(runif(1) < probab){
    tau = tau_proposal
  }else{
    tau = tau
  }

  if(t > burn){
    theta_save[,,(t-burn)]<-theta
    sigma_save[(t-burn),]<-sigma
    Sigma_save[,,(t-burn)]<-Sigma_c
    tau_save[(t-burn)]<-tau
  }
} 


  sfStop() 

  P_a_gt_0<-rep(NA,ncol(sigma_save))
  names(P_a_gt_0)<-names(ni)
  beta<-matrix(NA,nrow = k,ncol=(p+1))
  colnames(beta)<-c("alpha",x_nm)
  rownames(beta)<-names(ni)
  ## k is number of stocks
  for(j1 in 1:k){
      for(i in 1:(p+1))beta[j1,i]<-mean(theta_save[i,j1,])
      #b[j]<-mean(theta_save[2,j,])
      dummy<-theta_save[1,j1,]
      P_a_gt_0[j1]<-length(dummy[dummy>0])/length(dummy)
   } 
   

   simulated_samples<-list(theta_save=theta_save
                        ,sigma_save=sigma_save
                        ,Sigma_save=Sigma_save
                        ,tau_save=tau_save
                        ,beta=beta
                        ,P_a_gt_0=P_a_gt_0
                        ,ni=ni)

  return(simulated_samples)
}