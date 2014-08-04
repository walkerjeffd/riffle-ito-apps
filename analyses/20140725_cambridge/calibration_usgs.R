# assumes index.Rmd chunks already run so cond.temp.hr dataframe is in env

dt <- cond.temp.hr$DATEHOUR
freq <- cond.temp.hr$RIFFLE
obs <- cond.temp.hr$USGS
temp <- cond.temp.hr$TEMP
alpha <- 0.024

calc.cond <- function(f, LA, C, R, alpha, temp) {
  S <- 2 * LA / (1/(0.7*f*C) - R) * 1e6 / 1e2
  S <- S / (1 + alpha*(temp-25))
  S <- S
  S
}

cbind(obs, calc.cond(freq, 67, 0.185e-6, 3070, alpha, temp))

par(mfrow=c(1,1))
plot(cbind(obs, calc.cond(freq, 67, 0.185e-6, 3070, alpha, temp)),
     xlab='USGS SpCond (uS/cm)', ylab='Riffle SpCond (uS/cm)')
abline(0,1)

N <- 100000
z <- data.frame(R=runif(N, 1000, 5000),  # ohm
                C=runif(N, 0.001, 0.2),  # uF
                LA=runif(N, 0.1, 10), # 1/cm
                RMSE=NA)

z$RMSE <- apply(z, 1, function(x) {
  S <- calc.cond(f=freq, LA=x['LA']*100, C=x['C']*1e-6, R=x['R'], alpha=alpha, temp=temp)
  err <- obs-S
  rmse <- sqrt(mean(err^2))
  rmse
})

filter(z, RMSE <= quantile(z$RMSE, 0.1)) %>%
gather(PARAM, VALUE, R:LA) %>%
ggplot(aes(VALUE, RMSE)) +
  geom_point(alpha=0.1) +
  facet_wrap(~PARAM, scales='free_x', ncol=2)

z.opt <- z[which.min(z$RMSE),]
plot(cbind(obs, calc.cond(freq, z.opt[['LA']]*100, z.opt[['C']]*1e-6, z.opt[['R']], alpha, temp)),
     xlab='USGS SpCond (uS/cm)', ylab='Riffle SpCond (uS/cm)')
abline(0, 1)



plot(cbind(, ),
     xlab='USGS SpCond (uS/cm)', ylab='Riffle SpCond (uS/cm)', type='l')
points(cond.temp.hr$DATEHOUR, )
abline(0, 1)


# try alpha
N <- 100000
z <- data.frame(R=runif(N, 1000, 5000),  # ohm
                C=runif(N, 0.001, 0.2),  # uF
                LA=runif(N, 0.1, 10), # 1/cm
                alpha=runif(N, 0.001, 0.1),
                RMSE=NA)

z$RMSE <- apply(z, 1, function(x) {
  S <- calc.cond(f=freq, LA=x['LA']*100, C=x['C']*1e-6, R=x['R'], alpha=x['alpha'], temp=temp)
  err <- obs-S
  rmse <- sqrt(mean(err^2))
  rmse
})

filter(z, RMSE <= quantile(z$RMSE, 0.1)) %>%
  gather(PARAM, VALUE, R:alpha) %>%
  ggplot(aes(VALUE, RMSE)) +
  geom_point(alpha=0.1) +
  facet_wrap(~PARAM, scales='free_x', ncol=2)

z.opt <- z[which.min(z$RMSE),]
plot(cbind(obs, calc.cond(freq, z.opt[['LA']]*100, z.opt[['C']]*1e-6, z.opt[['R']], z.opt[['alpha']], temp)),
     xlab='USGS SpCond (uS/cm)', ylab='Riffle SpCond (uS/cm)')
abline(0, 1)


# for don

data.frame(DATEHOUR=dt,
           RIFFLE=calc.cond(freq, 1.87*100, 0.12*1e-6, 3200, 0.024, temp),
           USGS=cond.temp.hr$USGS) %>%
  gather(SOURCE, VALUE, RIFFLE:USGS) %>%
  ggplot(aes(DATEHOUR, VALUE, color=SOURCE)) +
  geom_line() +
  labs(x="Date", y="Specific Conductivity (uS/cm)")
