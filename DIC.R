library(mvtnorm)

x= read.delim("earthequakes.txt")
y.sample = x$Quakes

n.all=length(y.sample)
p=3
m0=matrix(rep(0,p),ncol=1)
C0=10*diag(p)
n0=0.02
d0=0.02




Y=matrix(y.sample[4:n.all],ncol=1)
Fmtx=matrix(c(y.sample[3:(n.all-1)],y.sample[2:(n.all-2)],y.sample[1:(n.all-3)]),nrow=p,byrow=TRUE)
n=length(Y)




e=Y-t(Fmtx)%*%m0
Q=t(Fmtx)%*%C0%*%Fmtx+diag(n)
Q.inv=chol2inv(chol(Q))
A=C0%*%Fmtx%*%Q.inv
m=m0+A%*%e
C=C0-A%*%Q%*%t(A)
n.star=n+n0
d.star=t(Y-t(Fmtx)%*%m0)%*%Q.inv%*%(Y-t(Fmtx)%*%m0)+d0




n.sample=5000


nu.sample=rep(0,n.sample)
phi.sample=matrix(0,nrow=n.sample,ncol=p)


for (i in 1:n.sample) {
    set.seed(i)
    nu.new=1/rgamma(1,shape=n.star/2,rate=d.star/2)
    nu.sample[i]=nu.new
    phi.new=rmvnorm(1,mean=m,sigma=nu.new*C)
    phi.sample[i,]=phi.new
}


par(mfrow=c(1,3))
hist(phi.sample[,1],freq=FALSE,xlab=expression(phi[1]),main="")
lines(density(phi.sample[,1]),type='l',col='red')
hist(phi.sample[,2],freq=FALSE,xlab=expression(phi[2]),main="")
lines(density(phi.sample[,2]),type='l',col='red')
hist(nu.sample,freq=FALSE,xlab=expression(nu),main="")
lines(density(nu.sample),type='l',col='red')



cal_log_likelihood=function(phi,nu){
    mu.y=t(Fmtx)%*%phi
    log.lik=sapply(1:length(mu.y), function(k){dnorm(Y[k,1],mu.y[k],sqrt(nu),log=TRUE)})
    sum(log.lik)
}


phi.bayes=colMeans(phi.sample)
nu.bayes=mean(nu.sample)


log.lik.bayes=cal_log_likelihood(phi.bayes,nu.bayes)


post.log.lik=sapply(1:5000, function(k){cal_log_likelihood(phi.sample[k,],nu.sample[k])})
E.post.log.lik=mean(post.log.lik)


p_DIC=2*(log.lik.bayes-E.post.log.lik)

DIC=-2*log.lik.bayes+2*p_DIC