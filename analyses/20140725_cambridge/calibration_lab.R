lab <- data.frame(V=c(3,3.5,4,4.5,6,8,10,15,21)*0.24, # liter
                f_obs=c(2200,1990,1880,1840,1680,1580,1445,1215,1035)) # Hz

M <- 0.7125             # g
lab$TDS <- M/lab$V*1000 # mg/L
lab$S <- lab$TDS*2          # uS/cm

calc.freq <- function(S, LA, C, R) {
  S <- S * 1e2 / 1e6 # uS/cm -> S/m
  f <- 1 / (0.7 * C * (R + (2*LA/S)))
  f
}

plot(lab$f_obs, calc.freq(lab$S, 250, 0.1e-6, 3300))

N <- 100000
z <- data.frame(R=runif(N, 3000, 3600),  # ohm
                C=runif(N, 0.09, 0.5),  # uF
                LA=runif(N, 0.3, 2),     # 1/cm
                RMSE=NA)

S <- lab$S
f_obs <- lab$f_obs
z$RMSE <- apply(z, 1, function(x) {
  f <- calc.freq(S=S, LA=x['LA']*100, C=x['C']*1e-6, R=x['R'])
  err <- f_obs-f
  rmse <- sqrt(mean(err^2))
  rmse
})
z.opt <- z[which.min(z$RMSE),]
z.opt

gather(z, PARAM, VALUE, R:LA) %>%
  filter(RMSE<=500) %>%
  ggplot(aes(VALUE, RMSE)) +
  geom_point(alpha=0.1) +
  facet_wrap(~PARAM, scales='free_x', ncol=2)

filter(z, RMSE<=quantile(z$RMSE, probs=0.01)) %>%
  gather(PARAM, VALUE, R:LA) %>%
  ggplot(aes(VALUE, RMSE)) +
  geom_point(alpha=0.1) +
  facet_wrap(~PARAM, scales='free_x', ncol=2)

filter(z, RMSE<=quantile(z$RMSE, probs=0.001)) %>%
  gather(PARAM, VALUE, R:LA) %>%
  ggplot(aes(1, VALUE)) +
  geom_boxplot() +
  facet_wrap(~PARAM, scales='free_y', ncol=2)



par(mfrow = c(1,2))
plot(cbind(S, f_obs),
     xlab='Conductivity (uS/cm)', ylab='Freq (Hz)')
lines(cbind(S, calc.freq(S, z.opt[['LA']]*100, z.opt[['C']]*1e-6, z.opt[['R']])))

plot(cbind(f_obs, calc.freq(S, z.opt[['LA']]*100, z.opt[['C']]*1e-6, z.opt[['R']])),
     xlab='Measured Freq (Hz)', ylab='Estimated Freq (Hz)')
abline(0, 1)



# fix R and C
N <- 100000
z <- data.frame(R=3200,  # ohm
                C=0.12,  # uF
                LA=runif(N, 0.3, 2),     # 1/cm
                RMSE=NA)

S <- lab$S
f_obs <- lab$f_obs
z$RMSE <- apply(z, 1, function(x) {
  f <- calc.freq(S=S, LA=x['LA']*100, C=x['C']*1e-6, R=x['R'])
  err <- f_obs-f
  rmse <- sqrt(mean(err^2))
  rmse
})
z.opt <- z[which.min(z$RMSE),]
z.opt

filter(z, RMSE<=quantile(z$RMSE, probs=0.1)) %>%
  gather(PARAM, VALUE, LA) %>%
  ggplot(aes(VALUE, RMSE)) +
  geom_point(alpha=0.1) +
  facet_wrap(~PARAM, scales='free_x', ncol=2) +
  xlab('L/A Value')


library(gridExtra)

p1 <- data.frame(S=S, Obs=f_obs) %>%
  ggplot(aes(S, Obs)) +
  geom_line(aes(S, Fit),
            data=data.frame(S=seq(0, max(S)),
                            Fit=calc.freq(seq(0, max(S)), z.opt[['LA']]*100, z.opt[['C']]*1e-6, z.opt[['R']]))) +
  geom_point(color='red', size=4) +
  labs(x="Conductivity Conductivity (uS/cm)", y="555 Frequency (Hz)")

p2 <- data.frame(S=S, Obs=f_obs, Pred=calc.freq(S, z.opt[['LA']]*100, z.opt[['C']]*1e-6, z.opt[['R']])) %>%
  ggplot(aes(Obs, Pred)) +
  geom_point(size=4) +
  geom_smooth(method='lm') +
  geom_abline(color='red', linetype=2) +
  ylim(1000, 2500) +
  xlim(1000, 2500) +
  labs(x="Measured Freq (Hz)", y="Estimated Freq (Hz)")

grid.arrange(p1, p2, ncol=2, main='\nConductivity Calibration')
