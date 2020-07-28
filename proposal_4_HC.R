proposal_4_HC<-function(param){
  min1<-param*0.95
  max1<-param*1.05
  return(runif(1,min=min1,max=max1))
}
