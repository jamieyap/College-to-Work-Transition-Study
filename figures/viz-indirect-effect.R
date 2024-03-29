library(dplyr)
path_output_data <- Sys.getenv("path_output_data")

CurvilinearEffect <- function(stress, time, var, dat){
        a2 <- dat$a2
        a3 <- dat$a3
        a4 <- dat$a4
        a5 <- dat$a5
        
        b1 <- dat$b1
        b2 <- dat$b2
        b3 <- dat$b3
        b4 <- dat$b4
        
        if(var == "quant"){
                out <- (a3 + a5*time)*(b1 + b3*time + b2*stress + b4*time*stress)
        }else if(var == "qual"){
                out <- (a2 + a4*time)*(b1 + b3*time + b2*stress + b4*time*stress)
        }else{
                out <- -99
        }
        
        est <- as.numeric(mean(out))
        lb95 <- as.numeric(quantile(out, probs = 0.025))
        ub95 <- as.numeric(quantile(out, probs = 0.975))
        
        return(list(est = est, lb95 = lb95, ub95 = ub95))
}

xran_min <- -1.5
xran_max <- 2.0
yran_min <- -0.02
yran_max <- 0.08
these_xvals <- c(-1.5, -1, -0.5, 0, 0.5, 1.0, 1.5, 2)
these_yvals <- c(-0.02, 0, 0.02, 0.04, 0.06, 0.08)

###############################################################################
# RAPI
###############################################################################

load("analysis/Hypothesis 04/list_models_rutgers.RData")
alpha <- 0.05

list_params_rutgers <- list()

for(i in 1:length(list_models_rutgers)){
        curr_model_estimates <- list_models_rutgers[[i]]
        
        tab_DASS <- curr_model_estimates[["est_DASS"]]
        a2 <- tab_DASS[row.names(tab_DASS) == "qualitative_role_overload",][["estimates"]]
        a4 <- tab_DASS[row.names(tab_DASS) == "qualitative_role_overload:time",][["estimates"]]
        a3 <- tab_DASS[row.names(tab_DASS) == "quantitative_role_overload",][["estimates"]]
        a5 <- tab_DASS[row.names(tab_DASS) == "quantitative_role_overload:time",][["estimates"]]
        
        tab_drinking <- curr_model_estimates[["est_rutgers_injunctive"]]
        b1 <- tab_drinking[row.names(tab_drinking) == "DASS",][["estimates"]]
        b2 <- tab_drinking[row.names(tab_drinking) == "I(DASS * DASS)",][["estimates"]]
        b3 <- tab_drinking[row.names(tab_drinking) == "DASS:time",][["estimates"]]
        b4 <- tab_drinking[row.names(tab_drinking) == "I(DASS * DASS):time",][["estimates"]]
        
        curr_params_rutgers <- data.frame(a2=a2, a4=a4, a3=a3, a5=a5, b1=b1, b2=b2, b3=b3, b4=b4)
        list_params_rutgers <- append(list_params_rutgers, list(curr_params_rutgers))
}

bootdat_params_rutgers <- bind_rows(list_params_rutgers) 

dat_plot <- expand.grid(stress = seq(xran_min, xran_max,0.10), time = c(0,1), var = c("quant","qual"))
list_dat_effect <- mapply(CurvilinearEffect, dat_plot$stress, dat_plot$time, dat_plot$var, MoreArgs = list(dat = bootdat_params_rutgers), SIMPLIFY = FALSE)
dat_effect <- bind_rows(list_dat_effect)
dat_plot <- cbind(dat_plot, dat_effect)
effect <- dat_effect$est

par(mar = c(10, 8, 7, 0.5) + 0.1, mfrow = c(2,2))  # Bottom, left, top, right
this_ylabel <- "Indirect Effect of\nQualitative Overload on ARP"
dat_plot0 <- dat_plot[dat_plot$time==0 & dat_plot$var=="qual",]
plot(-1, 
     type="n",
     xlim = c(xran_min, xran_max),
     ylim = c(yran_min, yran_max),
     xlab = "",
     ylab = "", 
     cex.lab = 1.5,
     cex.axis = 1.5,
     frame.plot = FALSE,
     xaxt = "n", yaxt = "n")
axis(1, at = these_xvals, cex.lab = 1.5, cex.axis = 1.5, lwd = 5)
axis(2, at = these_yvals, cex.lab = 1.5, cex.axis = 1.5, lwd = 5)
lines(dat_plot0$stress, dat_plot0$est, type = "l", lwd = 5)
lines(dat_plot0$stress, dat_plot0$lb95, type = "l", lwd = 3, lty = 3, col = "cornflowerblue")
lines(dat_plot0$stress, dat_plot0$ub95, type = "l", lwd = 3, lty = 3, col = "cornflowerblue")
mtext("ARP during the Early Onboarding Phase", side = 3, line = 0, cex = 1.5)
mtext("Psychological Distress:\nNo. of standard deviations above or below mean", side = 1, line = 7, cex = 1.5)
mtext(this_ylabel, side = 2, line = 3, cex = 1.5)
abline(h = 0, lwd = 4, col = "brown", lty = 2)
axis(2, at = seq(yran_min, yran_max, 0.02), cex.axis = 1.5, cex.lab = 1.5)

dat_plot1 <- dat_plot[dat_plot$time==1 & dat_plot$var=="qual",]
plot(-1, 
     type="n",
     xlim = c(xran_min, xran_max),
     ylim = c(yran_min, yran_max),
     xlab = "",
     ylab = "", 
     cex.lab = 1.5,
     cex.axis = 1.5,
     frame.plot = FALSE,
     xaxt = "n", yaxt = "n")
axis(1, at = these_xvals, cex.lab = 1.5, cex.axis = 1.5, lwd = 5)
axis(2, at = these_yvals, cex.lab = 1.5, cex.axis = 1.5, lwd = 5)
lines(dat_plot1$stress, dat_plot1$est, type = "l", lwd = 5)
lines(dat_plot1$stress, dat_plot1$lb95, type = "l", lwd = 3, lty = 3, col = "cornflowerblue")
lines(dat_plot1$stress, dat_plot1$ub95, type = "l", lwd = 3, lty = 3, col = "cornflowerblue")
mtext("ARP during the Late Onboarding Phase", side = 3, line = 0, cex = 1.5)
mtext("Psychological Distress:\nNo. of standard deviations above or below mean", side = 1, line = 7, cex = 1.5)
mtext(this_ylabel, side = 2, line = 3, cex = 1.5)
abline(h = 0, lwd = 4, col = "brown", lty = 2)
axis(2, at = seq(yran_min, yran_max, 0.02), cex.axis = 1.5, cex.lab = 1.5)

this_ylabel <- "Indirect Effect of\nQuantitative Overload on ARP"
dat_plot0 <- dat_plot[dat_plot$time==0 & dat_plot$var=="quant",]
plot(-1, 
     type="n",
     xlim = c(xran_min, xran_max),
     ylim = c(yran_min, yran_max),
     xlab = "",
     ylab = "", 
     cex.lab = 1.5,
     cex.axis = 1.5,
     frame.plot = FALSE,
     xaxt = "n", yaxt = "n")
axis(1, at = these_xvals, cex.lab = 1.5, cex.axis = 1.5, lwd = 5)
axis(2, at = these_yvals, cex.lab = 1.5, cex.axis = 1.5, lwd = 5)
lines(dat_plot0$stress, dat_plot0$est, type = "l", lwd = 5)
lines(dat_plot0$stress, dat_plot0$est, type = "l", lwd = 3)
lines(dat_plot0$stress, dat_plot0$lb95, type = "l", lwd = 3, lty = 3, col = "cornflowerblue")
lines(dat_plot0$stress, dat_plot0$ub95, type = "l", lwd = 3, lty = 3, col = "cornflowerblue")
mtext("ARP during the Early Onboarding Phase", side = 3, line = 0, cex = 1.5)
mtext("Psychological Distress:\nNo. of standard deviations above or below mean", side = 1, line = 7, cex = 1.5)
mtext(this_ylabel, side = 2, line = 3, cex = 1.5)
abline(h = 0, lwd = 4, col = "brown", lty = 2)
axis(2, at = seq(yran_min, yran_max, 0.02), cex.axis = 1.5, cex.lab = 1.5)

dat_plot1 <- dat_plot[dat_plot$time==1 & dat_plot$var=="quant",]
plot(-1, 
     type="n",
     xlim = c(xran_min, xran_max),
     ylim = c(yran_min, yran_max),
     xlab = "",
     ylab = "", 
     cex.lab = 1.5,
     cex.axis = 1.5,
     frame.plot = FALSE,
     xaxt = "n", yaxt = "n")
axis(1, at = these_xvals, cex.lab = 1.5, cex.axis = 1.5, lwd = 5)
axis(2, at = these_yvals, cex.lab = 1.5, cex.axis = 1.5, lwd = 5)
lines(dat_plot1$stress, dat_plot1$est, type = "l", lwd = 5)
lines(dat_plot1$stress, dat_plot1$lb95, type = "l", lwd = 3, lty = 3, col = "cornflowerblue")
lines(dat_plot1$stress, dat_plot1$ub95, type = "l", lwd = 3, lty = 3, col = "cornflowerblue")
mtext("ARP during the Late Onboarding Phase", side = 3, line = 0, cex = 1.5)
mtext("Psychological Distress:\nNo. of standard deviations above or below mean", side = 1, line = 7, cex = 1.5)
mtext(this_ylabel, side = 2, line = 3, cex = 1.5)
abline(h = 0, lwd = 4, col = "brown", lty = 2)
axis(2, at = seq(yran_min, yran_max, 0.02), cex.axis = 1.5, cex.lab = 1.5)

###############################################################################
# HED
###############################################################################

load("analysis/Hypothesis 04/list_models_HED.RData")

list_params_HED <- list()

for(i in 1:length(list_models_HED)){
        curr_model_estimates <- list_models_HED[[i]]
        
        tab_DASS <- curr_model_estimates[["est_DASS"]]
        a2 <- tab_DASS[row.names(tab_DASS) == "qualitative_role_overload",][["estimates"]]
        a4 <- tab_DASS[row.names(tab_DASS) == "qualitative_role_overload:time",][["estimates"]]
        a3 <- tab_DASS[row.names(tab_DASS) == "quantitative_role_overload",][["estimates"]]
        a5 <- tab_DASS[row.names(tab_DASS) == "quantitative_role_overload:time",][["estimates"]]
        
        tab_drinking <- curr_model_estimates[["est_HED_injunctive"]]
        b1 <- tab_drinking[row.names(tab_drinking) == "DASS",][["estimates"]]
        b2 <- tab_drinking[row.names(tab_drinking) == "I(DASS * DASS)",][["estimates"]]
        b3 <- tab_drinking[row.names(tab_drinking) == "DASS:time",][["estimates"]]
        b4 <- tab_drinking[row.names(tab_drinking) == "I(DASS * DASS):time",][["estimates"]]
        
        curr_params_HED <- data.frame(a2=a2, a4=a4, a3=a3, a5=a5, b1=b1, b2=b2, b3=b3, b4=b4)
        list_params_HED <- append(list_params_HED, list(curr_params_HED))
}

bootdat_params_HED <- bind_rows(list_params_HED) 

dat_plot <- expand.grid(stress = seq(xran_min, xran_max,0.10), time = c(0,1), var = c("quant","qual"))
list_dat_effect <- mapply(CurvilinearEffect, dat_plot$stress, dat_plot$time, dat_plot$var, MoreArgs = list(dat = bootdat_params_HED), SIMPLIFY = FALSE)
dat_effect <- bind_rows(list_dat_effect)
dat_plot <- cbind(dat_plot, dat_effect)
effect <- dat_effect$est

par(mar = c(10, 8, 7, 0.5) + 0.1, mfrow = c(2,2))  # Bottom, left, top, right
this_ylabel <- "Indirect Effect of\nQualitative Overload on HED"
dat_plot0 <- dat_plot[dat_plot$time==0 & dat_plot$var=="qual",]
plot(-1, 
     type="n",
     xlim = c(xran_min, xran_max),
     ylim = c(yran_min, yran_max),
     xlab = "",
     ylab = "", 
     cex.lab = 1.5,
     cex.axis = 1.5,
     frame.plot = FALSE,
     xaxt = "n", yaxt = "n")
axis(1, at = these_xvals, cex.lab = 1.5, cex.axis = 1.5, lwd = 5)
axis(2, at = these_yvals, cex.lab = 1.5, cex.axis = 1.5, lwd = 5)
lines(dat_plot0$stress, dat_plot0$est, type = "l", lwd = 5)
lines(dat_plot0$stress, dat_plot0$lb95, type = "l", lwd = 3, lty = 3, col = "cornflowerblue")
lines(dat_plot0$stress, dat_plot0$ub95, type = "l", lwd = 3, lty = 3, col = "cornflowerblue")
mtext("HED during the Early Onboarding Phase", side = 3, line = 0, cex = 1.5)
mtext("Psychological Distress:\nNo. of standard deviations above or below mean", side = 1, line = 7, cex = 1.5)
mtext(this_ylabel, side = 2, line = 3, cex = 1.5)
abline(h = 0, lwd = 4, col = "brown", lty = 2)
axis(2, at = seq(yran_min, yran_max, 0.02), cex.axis = 1.5, cex.lab = 1.5)

dat_plot1 <- dat_plot[dat_plot$time==1 & dat_plot$var=="qual",]
plot(-1, 
     type="n",
     xlim = c(xran_min, xran_max),
     ylim = c(yran_min, yran_max),
     xlab = "",
     ylab = "", 
     cex.lab = 1.5,
     cex.axis = 1.5,
     frame.plot = FALSE,
     xaxt = "n", yaxt = "n")
axis(1, at = these_xvals, cex.lab = 1.5, cex.axis = 1.5, lwd = 5)
axis(2, at = these_yvals, cex.lab = 1.5, cex.axis = 1.5, lwd = 5)
lines(dat_plot1$stress, dat_plot1$est, type = "l", lwd = 5)
lines(dat_plot1$stress, dat_plot1$lb95, type = "l", lwd = 3, lty = 3, col = "cornflowerblue")
lines(dat_plot1$stress, dat_plot1$ub95, type = "l", lwd = 3, lty = 3, col = "cornflowerblue")
mtext("HED during the Late Onboarding Phase", side = 3, line = 0, cex = 1.5)
mtext("Psychological Distress:\nNo. of standard deviations above or below mean", side = 1, line = 7, cex = 1.5)
mtext(this_ylabel, side = 2, line = 3, cex = 1.5)
abline(h = 0, lwd = 4, col = "brown", lty = 2)
axis(2, at = seq(yran_min, yran_max, 0.02), cex.axis = 1.5, cex.lab = 1.5)

this_ylabel <- "Indirect Effect of\nQuantitative Overload on HED"
dat_plot0 <- dat_plot[dat_plot$time==0 & dat_plot$var=="quant",]
plot(-1, 
     type="n",
     xlim = c(xran_min, xran_max),
     ylim = c(yran_min, yran_max),
     xlab = "",
     ylab = "", 
     cex.lab = 1.5,
     cex.axis = 1.5,
     frame.plot = FALSE,
     xaxt = "n", yaxt = "n")
axis(1, at = these_xvals, cex.lab = 1.5, cex.axis = 1.5, lwd = 5)
axis(2, at = these_yvals, cex.lab = 1.5, cex.axis = 1.5, lwd = 5)
lines(dat_plot0$stress, dat_plot0$est, type = "l", lwd = 5)
lines(dat_plot0$stress, dat_plot0$est, type = "l", lwd = 3)
lines(dat_plot0$stress, dat_plot0$lb95, type = "l", lwd = 3, lty = 3, col = "cornflowerblue")
lines(dat_plot0$stress, dat_plot0$ub95, type = "l", lwd = 3, lty = 3, col = "cornflowerblue")
mtext("HED during the Early Onboarding Phase", side = 3, line = 0, cex = 1.5)
mtext("Psychological Distress:\nNo. of standard deviations above or below mean", side = 1, line = 7, cex = 1.5)
mtext(this_ylabel, side = 2, line = 3, cex = 1.5)
abline(h = 0, lwd = 4, col = "brown", lty = 2)
axis(2, at = seq(yran_min, yran_max, 0.02), cex.axis = 1.5, cex.lab = 1.5)

dat_plot1 <- dat_plot[dat_plot$time==1 & dat_plot$var=="quant",]
plot(-1, 
     type="n",
     xlim = c(xran_min, xran_max),
     ylim = c(yran_min, yran_max),
     xlab = "",
     ylab = "", 
     cex.lab = 1.5,
     cex.axis = 1.5,
     frame.plot = FALSE,
     xaxt = "n", yaxt = "n")
axis(1, at = these_xvals, cex.lab = 1.5, cex.axis = 1.5, lwd = 5)
axis(2, at = these_yvals, cex.lab = 1.5, cex.axis = 1.5, lwd = 5)
lines(dat_plot1$stress, dat_plot1$est, type = "l", lwd = 5)
lines(dat_plot1$stress, dat_plot1$lb95, type = "l", lwd = 3, lty = 3, col = "cornflowerblue")
lines(dat_plot1$stress, dat_plot1$ub95, type = "l", lwd = 3, lty = 3, col = "cornflowerblue")
mtext("HED during the Late Onboarding Phase", side = 3, line = 0, cex = 1.5)
mtext("Psychological Distress:\nNo. of standard deviations above or below mean", side = 1, line = 7, cex = 1.5)
mtext(this_ylabel, side = 2, line = 3, cex = 1.5)
abline(h = 0, lwd = 4, col = "brown", lty = 2)
axis(2, at = seq(yran_min, yran_max, 0.02), cex.axis = 1.5, cex.lab = 1.5)

