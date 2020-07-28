dHCauchy<-function(x,sigma=1,log=TRUE){
  f<-2*sigma/(pi*(x^2+sigma^2))
  if(log=="TRUE"){
    f<-log(2)+log(sigma)-log(pi)-log(x^2+sigma^2)
  }
  return(f)
}