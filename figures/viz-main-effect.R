###############################################################################
# Preliminary data preparation steps
###############################################################################

outdat_rutgers <- read.csv("figures/RAPI/injunctive_model_05.csv", header = TRUE)
colnames(outdat_rutgers)[1] <- "params"
varcovmat_rutgers <- read.csv("figures/RAPI/varcovmat_injunctive_model_05.csv", header = TRUE)

outdat_HED <- read.csv("figures/HED/injunctive_model_05.csv", header = TRUE)
colnames(outdat_HED)[1] <- "params"
varcovmat_HED <- read.csv("figures/HED/varcovmat_injunctive_model_05.csv", header = TRUE)

list_estimates <- list(outdat_rutgers = outdat_rutgers, outdat_HED = outdat_HED)
list_varcovmat <- list(varcovmat_rutgers = varcovmat_rutgers, varcovmat_HED = varcovmat_HED)

###############################################################################
# Define function for plotting effects
###############################################################################

CurvilinearEffect <- function(stress, 
                              time, 
                              model, 
                              estimates = list_estimates, 
                              varcovmat = list_varcovmat){
  
  out <- 0
  
  if(model == "RAPI_model05"){
    use_estimates <- estimates[["outdat_rutgers"]]
    use_varcovmat <- varcovmat[["varcovmat_rutgers"]][,2:ncol(varcovmat[["varcovmat_rutgers"]])]
  }else if(model == "HED_model05"){
    use_estimates <- estimates[["outdat_HED"]]
    use_varcovmat <- varcovmat[["varcovmat_HED"]][,2:ncol(varcovmat[["varcovmat_HED"]])]
  }else{
    out <- -99
  }
  
  if(out != -99){
    a_idx <- use_estimates[["params"]] == "DASS"
    b_idx <- use_estimates[["params"]] == "I(DASS * DASS)"
    c_idx <- use_estimates[["params"]] == "DASS:time"
    d_idx <- use_estimates[["params"]] == "I(DASS * DASS):time"
    
    a_est <- use_estimates[["estimates"]][a_idx]
    b_est <- use_estimates[["estimates"]][b_idx]
    c_est <- use_estimates[["estimates"]][c_idx]
    d_est <- use_estimates[["estimates"]][d_idx]
    
    est_linear_combo <- (a_est)*stress + (b_est)*stress*stress + time*((c_est)*stress + (d_est)*stress*stress)
    
    L <- rep(0, length(use_estimates[["params"]]))
    L[use_estimates[["params"]] == "DASS"] <- a_est
    L[use_estimates[["params"]] == "I(DASS * DASS)"] <- b_est * stress
    L[use_estimates[["params"]] == "DASS:time"] <- c_est * time
    L[use_estimates[["params"]] == "I(DASS * DASS):time"] <- d_est * stress * time
    L <- t(as.matrix(L))
    
    var_linear_combo <- L %*% as.matrix(use_varcovmat) %*% t(L)
    stderr_linear_combo <- sqrt(var_linear_combo)
  }
  
  out = data.frame(est = est_linear_combo,
                   stderr = stderr_linear_combo,
                   LB95 = est_linear_combo - qnorm(0.975)*stderr_linear_combo,
                   UB95 = est_linear_combo + qnorm(0.975)*stderr_linear_combo)
  return(out)
}

###############################################################################
# Prepare data for plotting
###############################################################################

dat_input <- expand.grid(stress = seq(-4,4,0.1), time = c(0,1), model = c("RAPI_model05","HED_model05"))
list_output <- mapply(CurvilinearEffect, dat_input$stress, dat_input$time, dat_input$model, SIMPLIFY = FALSE)
dat_output <- do.call(rbind, list_output)
dat_plot <- cbind(dat_input, dat_output)

min_ylim <- min(dat_plot$est)
max_ylim <- max(dat_plot$est)
min_xlim <- -4
max_xlim <- 4

###############################################################################
# RAPI
###############################################################################
par(mar = c(10, 5, 2, 0.5) + 0.1, mfrow = c(1,2))  # Bottom, left, top, right
dat_plot0 <- dat_plot[dat_plot$time==0 & dat_plot$model=="RAPI_model05",]
plot(-1, 
     type="n",
     xlim = c(min_xlim, max_xlim),
     ylim = c(min_ylim, max_ylim),
     xlab = "",
     ylab = "Effect of psychological distress on RAPI", 
     cex.lab = 1.5,
     cex.axis = 1.5,
     frame.plot = FALSE)
lines(dat_plot0$stress, dat_plot0$est, type = "l", lwd = 2)
lines(dat_plot0$stress, dat_plot0$LB95, type = "l", lwd = 2, lty = 3, col = "cornflowerblue")
lines(dat_plot0$stress, dat_plot0$UB95, type = "l", lwd = 2, lty = 3, col = "cornflowerblue")
mtext("RAPI at time 0", side = 3, line = 0, cex = 1.5)
mtext("Psychological Distress:\nNo. of standard deviations\nabove or below the mean", side = 1, line = 7, cex = 1.5)
dat_plot1 <- dat_plot[dat_plot$time==1 & dat_plot$model=="RAPI_model05",]
plot(-1, 
     type="n",
     xlim = c(min_xlim, max_xlim),
     ylim = c(min_ylim, max_ylim),
     xlab = "",
     ylab = "Effect of psychological distress on RAPI", 
     cex.lab = 1.5,
     cex.axis = 1.5,
     frame.plot = FALSE)
lines(dat_plot1$stress, dat_plot1$est, type = "l", lwd = 2)
lines(dat_plot1$stress, dat_plot1$LB95, type = "l", lwd = 2, lty = 3, col = "cornflowerblue")
lines(dat_plot1$stress, dat_plot1$UB95, type = "l", lwd = 2, lty = 3, col = "cornflowerblue")
mtext("RAPI at time 1", side = 3, line = 0, cex = 1.5)
mtext("Psychological Distress:\nNo. of standard deviations\nabove or below the mean", side = 1, line = 7, cex = 1.5)

###############################################################################
# HED
###############################################################################
par(mar = c(10, 5, 2, 0.5) + 0.1, mfrow = c(1,2))  # Bottom, left, top, right
dat_plot0 <- dat_plot[dat_plot$time==0 & dat_plot$model=="HED_model05",]
plot(-1, 
     type="n",
     xlim = c(min_xlim, max_xlim),
     ylim = c(min_ylim, max_ylim),
     xlab = "",
     ylab = "Effect of psychological distress on HED", 
     cex.lab = 1.5,
     cex.axis = 1.5,
     frame.plot = FALSE)
lines(dat_plot0$stress, dat_plot0$est, type = "l", lwd = 2)
lines(dat_plot0$stress, dat_plot0$LB95, type = "l", lwd = 2, lty = 3, col = "cornflowerblue")
lines(dat_plot0$stress, dat_plot0$UB95, type = "l", lwd = 2, lty = 3, col = "cornflowerblue")
mtext("HED at time 0", side = 3, line = 0, cex = 1.5)
mtext("Psychological Distress:\nNo. of standard deviations\nabove or below the mean", side = 1, line = 7, cex = 1.5)
dat_plot1 <- dat_plot[dat_plot$time==1 & dat_plot$model=="HED_model05",]
plot(-1, 
     type="n",
     xlim = c(min_xlim, max_xlim),
     ylim = c(min_ylim, max_ylim),
     xlab = "",
     ylab = "Effect of psychological distress on HED", 
     cex.lab = 1.5,
     cex.axis = 1.5,
     frame.plot = FALSE)
lines(dat_plot1$stress, dat_plot1$est, type = "l", lwd = 2)
lines(dat_plot1$stress, dat_plot1$LB95, type = "l", lwd = 2, lty = 3, col = "cornflowerblue")
lines(dat_plot1$stress, dat_plot1$UB95, type = "l", lwd = 2, lty = 3, col = "cornflowerblue")
mtext("HED at time 1", side = 3, line = 0, cex = 1.5)
mtext("Psychological Distress:\nNo. of standard deviations\nabove or below the mean", side = 1, line = 7, cex = 1.5)


