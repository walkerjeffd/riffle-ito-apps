x <- data.frame(V_cup=c(3,3.5,4,4.5,6,8,10,15,21),
                S_obs=c(2200,1990,1880,1840,1680,1580,1445,1215,1035))

x$V_lit <- x$V_cup*0.24
M <- 0.7125 # g
x$C_ppm <- M/x$V_lit*1000
x$S_pred <- x$C_ppm*2

N <- 1000
V <- x$V_lit
C <- array(NA, c(nrow(x), N))
for (i in 1:N) {
  M_mc <- rnorm(1, M, sd=0.001)
  V_mc <- V*runif(length(V), min=0.9, max=1.1)
  C_mc <- M_mc/V_mc*1000
  S_mc <- C_mc*2
  C[, i] <- C_mc
}

C.mean <- apply(C, 1, mean)
C.sd <- apply(C, 1, sd)
C.se <- C.sd/sqrt(N)

plot(V, C.mean, type='l')
lines(V, C.mean+2*C.se)
lines(V, C.mean-2*C.se)
C.mean
C.se
x
