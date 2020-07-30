rm(list = ls())
library(tseries)
library(xts)
library(lubridate)
library(xtable)

## Back testing from 01 Jan 2006

date.start.month <- seq(as.Date("2005-12-01"),length=154,by="months")
date.end.month <- seq(as.Date("2006-01-01"),length=154,by="months")-1

tst.dt.start.mnth <- seq(as.Date("2006-01-01"),length=154,by="months")
tst.dt.end.mnth <- seq(as.Date("2006-02-01"),length=154,by="months")-1



### Set the working directories
path_nm<-"/path/to/working/directories/"
setwd(path_nm)

load("yahoo_snp500_adj_close_return_20181101.RData"
     ,verbose=TRUE)

dsn<-adj_close_return$ret

dsn$Date<-as.Date(dsn$Date)

source("Factor_Model_HB_Back_testing.R")
source("CAPM_HB_Back_testing.R")
source("CAPM_MLE_Back_testing.R")
source("CAPM_Fang_Back_testing.R")
source("CAPM_BO_Back_testing.R")
source("Factor_Model_BO_Back_testing.R")

portfolio_rt<-data.frame(matrix(NA,nrow=1,ncol=6))
colnames(portfolio_rt)<-c("Date","X.GSPC","p_rt_capm_mle_mw","p_rt_capm_fang_mw","p_rt_factor_hb_mw","p_rt_factor_BO_mw")

ns<-25
scheme<-"equal" ## equal weight portfolio 
# scheme<-"mw" ## Markowitz's weight portfolio

for(j in 1:length(tst.dt.end.mnth)){
  cat("Iteration = ",j,"\n")
  
  ### Markowitz/Equal weight Portfolio on CAPM-MLE selected stocks
  ### and return on test month
  
  p_rt_capm_mle_mw<-CAPM_MLE_Back_testing(ns=ns,j=j,dsn=dsn,scheme=scheme)
  
  ### Markowitz/Equal weight Portfolio on CAPM-Fang selected stocks
  ### and return on test month
  
  p_rt_capm_fang_mw<-CAPM_Fang_Back_testing(ns=ns,j=j,dsn=dsn,scheme=scheme)
  
  
  ### Markowitz/Equal Portfolio on Factor model with Hierarchical Bayes selected stocks and return on test month
  
  p_rt_factor_hb_mw<-Factor_Model_HB_Back_testing(ns=ns,j=j,dsn=dsn,scheme=scheme)
  
  ### Markowitz-Portfolio Optimization on Factor Model-Bayes-Oracle selected stocks
  ### and return on test month
  
  p_rt_factor_BO_mw<-Factor_Model_BO_Back_testing(ns=ns,j=j,dsn=dsn,scheme=scheme)
  
  
  gspc_rt<-subset(dsn[,c("Date","X.GSPC")] ,Date>=tst.dt.start.mnth[j] & Date<=tst.dt.end.mnth[j])
  port_rt<-cbind(gspc_rt,p_rt_capm_mle_mw,p_rt_capm_fang_mw,p_rt_factor_hb_mw,p_rt_factor_BO_mw)
  
  portfolio_rt<-rbind(portfolio_rt,port_rt)
}

portfolio_rt<-na.omit(portfolio_rt)

Vol.t<-portfolio_rt
for(i in 2:6){
  fit<-garch(portfolio_rt[,i],order=c(1,1))
  Vol.t[,i]<-fit$fitted.values[,1]*100*sqrt(252)
  
}

P<-portfolio_rt
P[1,2:6]<-100
for(i in 2:nrow(P)){
  P[i,2:6]<-P[(i-1),2:6]*exp(portfolio_rt[i,2:6])
}


Value<-xts(x=P[,2:6],order.by=as.Date(rownames(P)))
Voltality<-xts(x=Vol.t[,2:6],order.by=as.Date(rownames(P)))
colnames(Value)<-colnames(Voltality)<-c("S&P 500","CAPM","LARS-LASSO Model","Factor Model with Horse Shoe Prior","Factor Model with Bayes Oracle")


jpeg(filename = 'portfolio_value_eq.jpg')
par(mfrow=c(2,1))
plot.xts(Value,plot.type="s",at="pretty",cex.axis=0.75,lty=rep(1,5),lwd=rep(1,5),col=c("black","red","blue","green","orange"),legend.loc="topleft");title(main = "", xlab = "",ylab="Portfolio Value")
plot.xts(Voltality,plot.type="s",at="pretty",cex.axis=0.75,lty=rep(1,5),lwd=rep(1,5),col=c("black","red","blue","green","orange"),legend.loc="topleft");title(main = "", xlab = "",ylab="Annualized Volatility")
dev.off()


apply(Voltality,2,median,na.rm=TRUE)
apply(Voltality,2,mean,na.rm=TRUE)


CAGR=(P[nrow(P),2:6]/P[1,2:6])^(1/(2018-2001))-1
risk_adj_ratio<-CAGR*100/apply(Voltality,2,median,na.rm=TRUE)

##----- Detail Performance Analysis ---

date <-  as.Date(rownames(portfolio_rt),'%Y-%m-%d')
P$year<-portfolio_rt$year <- as.numeric(format(date,'%Y'))

uniq_yrs<-unique(portfolio_rt$year )
anual_ret<-anual_vol<-annual_risk_adj_ret<-value_at_risk<-matrix(NA,nrow=length(uniq_yrs),ncol=5)
colnames(anual_ret)<-colnames(anual_vol)<-colnames(value_at_risk)<-colnames(annual_risk_adj_ret)<-c("S&P 500","CAPM","LARS-LASSO Model","Factor Model with HS","Factor Model with BO")
for(i in 1:length(uniq_yrs)){
  print(i)
  port_sub<-subset(portfolio_rt,year==uniq_yrs[i])
  P_sub<-subset(P,year==uniq_yrs[i])
  P_sub_ret<-apply(P_sub, 2, log)
  P_sub_ret<-apply(P_sub_ret, 2, diff)
  nt<-nrow(P_sub)
  anual_ret[i,1:5]<-as.numeric(((P_sub[nt,2:6]/P_sub[1,2:6])-1)*100)
  anual_vol[i,]<-as.numeric(apply(port_sub[,2:6],2,sd))*100*sqrt(252)
  value_at_risk[i,1:5]<-as.numeric(apply(P_sub_ret[,2:6],2,quantile,prob=0.025))
  annual_risk_adj_ret[i,]<-anual_ret[i,]/anual_vol[i,]
}

m<-apply(annual_risk_adj_ret,2,mean)
s<-apply(annual_risk_adj_ret,2,sd)

anualized_analysis<-list(anual_ret=anual_ret,anual_vol=anual_vol,value_at_risk=value_at_risk,annual_risk_adj_ret=annual_risk_adj_ret)

save(anualized_analysis,file = "anualized_analysis.RData")

####-------------------------

library(xtable)
load(file="anualized_analysis.RData",verbose = T)

anual_ret <- anualized_analysis[["anual_ret"]]
rownames(anual_ret)<-2006:2018
path_nm<-getwd()
jpeg(paste(path_nm,'eq_anualised_return.jpg',sep = "/"))
plot(2006:2018,anual_ret[,'S&P 500']
     ,type = 'l',lwd=2,xlab="",ylab='Annualised Return (%)'
     ,ylim=c(-50,50))
lines(2006:2018,anual_ret[,'CAPM'],lwd=2,col='red')
lines(2006:2018,anual_ret[,"LARS-LASSO Model"],lwd=2,col='green')
lines(2006:2018,anual_ret[,"Factor Model with HS"],lwd=2,col='blue')
lines(2006:2018,anual_ret[,"Factor Model with BO"],lwd=2,col='orange')
grid(col = "grey",lty=1)
text<-colnames(anual_ret)
legend('bottomright',text,col = c('black','red','green','blue','orange'),lwd = c(2,2,2,2,2))
dev.off()



xtable(anual_ret)

anual_vol <- anualized_analysis[["anual_vol"]]
rownames(annula_vol)<-2006:2018
jpeg(paste(path_nm,'eq_anualised_volatility.jpg',sep = "/"))
plot(2006:2018,anual_vol[,'S&P 500']
     ,type = 'l',lwd=2,xlab="",ylab='Annualised Volatility (%)'
     ,ylim=c(0,60))
lines(2006:2018,anual_vol[,'CAPM'],lwd=2,col='red')
lines(2006:2018,anual_vol[,"LARS-LASSO Model"],lwd=2,col='green')
lines(2006:2018,anual_vol[,"Factor Model with HS"],lwd=2,col='blue')
lines(2006:2018,anual_vol[,"Factor Model with BO"],lwd=2,col='orange')
grid(col = "grey",lty=1)
text<-colnames(anual_vol)
legend('topright',text,col = c('black','red','green','blue','orange'),lwd = c(2,2,2,2,2))
dev.off()

xtable(anual_vol)

value_at_risk <- anualized_analysis[["value_at_risk"]]*-100
rownames(annula_vol)<-2006:2018
jpeg(paste(path_nm,'eq_anualised_VaR.jpg',sep = "/"))
plot(2006:2018,value_at_risk[,'S&P 500']
     ,type = 'l',lwd=2,xlab="",ylab='Annualised VaR (%)'
     ,ylim=c(0,10))
lines(2006:2018,value_at_risk[,'CAPM'],lwd=2,col='red')
lines(2006:2018,value_at_risk[,"LARS-LASSO Model"],lwd=2,col='green')
lines(2006:2018,value_at_risk[,"Factor Model with HS"],lwd=2,col='blue')
lines(2006:2018,value_at_risk[,"Factor Model with BO"],lwd=2,col='orange')
grid(col = "grey",lty=1)
text<-colnames(value_at_risk)
legend('topright',text,col = c('black','red','green','blue','orange'),lwd = c(2,2,2,2,2))
dev.off()


xtable(value_at_risk)


annual_risk_adj_ret <- anualized_analysis[["annual_risk_adj_ret"]]
rownames(annual_risk_adj_ret)<-2006:2008

jpeg(paste(path_nm,'eq_anualised_risk_adj_ret.jpg',sep = "/"))
plot(2006:2018,annual_risk_adj_ret[,'S&P 500']
     ,type = 'l',lwd=2,xlab="",ylab='Annualised Risk adjusted Return (%)'
     ,ylim=c(-4,4))
lines(2006:2018,annual_risk_adj_ret[,'CAPM'],lwd=2,col='red')
lines(2006:2018,annual_risk_adj_ret[,"LARS-LASSO Model"],lwd=2,col='green')
lines(2006:2018,annual_risk_adj_ret[,"Factor Model with HS"],lwd=2,col='blue')
lines(2006:2018,annual_risk_adj_ret[,"Factor Model with BO"],lwd=2,col='orange')
grid(col = "grey",lty=1)
text<-colnames(annual_risk_adj_ret)
legend('bottomright',text,col = c('black','red','green','blue','orange'),lwd = c(2,2,2,2,2))
dev.off()

xtable(annual_risk_adj_ret)

