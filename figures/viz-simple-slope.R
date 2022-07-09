###############################################################################
# Preliminary data preparation steps
###############################################################################

outdat_rutgers <- read.csv("figures/RAPI/injunctive_model_03.csv", header = TRUE)
colnames(outdat_rutgers)[1] <- "params"
varcovmat_rutgers <- read.csv("figures/RAPI/varcovmat_injunctive_model_03.csv", header = TRUE)

outdat_HED <- read.csv("figures/HED/injunctive_model_03.csv", header = TRUE)
colnames(outdat_HED)[1] <- "params"
varcovmat_HED <- read.csv("figures/HED/varcovmat_injunctive_model_03.csv", header = TRUE)

list_estimates <- list(outdat_rutgers = outdat_rutgers, outdat_HED = outdat_HED)
list_varcovmat <- list(varcovmat_rutgers = varcovmat_rutgers, varcovmat_HED = varcovmat_HED)

###############################################################################
# Define function for plotting effects
###############################################################################

CurvilinearEffect <- function(stress, 
                              model, 
                              estimates = list_estimates, 
                              varcovmat = list_varcovmat){
  
  out <- 0
  
  if(model == "RAPI_model03"){
    use_estimates <- estimates[["outdat_rutgers"]]
    use_varcovmat <- varcovmat[["varcovmat_rutgers"]][,2:ncol(varcovmat[["varcovmat_rutgers"]])]
  }else if(model == "HED_model03"){
    use_estimates <- estimates[["outdat_HED"]]
    use_varcovmat <- varcovmat[["varcovmat_HED"]][,2:ncol(varcovmat[["varcovmat_HED"]])]
  }else{
    out <- -99
  }
  
  if(out != -99){
    a_idx <- use_estimates[["params"]] == "DASS"
    b_idx <- use_estimates[["params"]] == "I(DASS * DASS)"
    
    a_est <- use_estimates[["estimates"]][a_idx]  # coefficient of DASS
    b_est <- use_estimates[["estimates"]][b_idx]  # coefficient of DASS*DASS
    
    est_linear_combo <- a_est + b_est*stress
    
    L <- rep(0, length(use_estimates[["params"]]))
    L[use_estimates[["params"]] == "DASS"] <- a_est
    L[use_estimates[["params"]] == "I(DASS * DASS)"] <- b_est * stress
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

min_xlim <- -1.5
max_xlim <- 2.0
these_xvals <- c(-1.5, -1, -0.5, 0, 0.5, 1.0, 1.5, 2)

dat_input <- expand.grid(stress = seq(min_xlim,max_xlim,0.1), model = c("RAPI_model03","HED_model03"))
list_output <- mapply(CurvilinearEffect, dat_input$stress, dat_input$model, SIMPLIFY = FALSE)
dat_output <- do.call(rbind, list_output)
dat_plot <- cbind(dat_input, dat_output)

min_ylim <- round(min(dat_plot$est), 1)
max_ylim <- round(max(dat_plot$est), 1)
these_yvals <- round(seq(from = min_ylim, to = max_ylim, by = 0.1), 1)

###############################################################################
# RAPI
###############################################################################
par(mar = c(10, 7, 2, 0.5) + 0.1)  # Bottom, left, top, right
dat_plot0 <- dat_plot[dat_plot$model=="RAPI_model03",]
plot(-1, 
     type="n",
     xlim = c(min_xlim, max_xlim),
     ylim = c(min_ylim, max_ylim),
     xlab = "",
     ylab = "",
     frame.plot = FALSE,
     xaxt = "n", yaxt = "n")
axis(1, at = these_xvals, cex.lab = 1.5, cex.axis = 1.5, lwd = 5)
axis(2, at = these_yvals, cex.lab = 1.5, cex.axis = 1.5, lwd = 5)
lines(dat_plot0$stress, dat_plot0$est, type = "l", lwd = 5)
lines(dat_plot0$stress, dat_plot0$LB95, type = "l", lwd = 5, lty = 3, col = "cornflowerblue")
lines(dat_plot0$stress, dat_plot0$UB95, type = "l", lwd = 5, lty = 3, col = "cornflowerblue")
mtext("Effect of psychological distress on ARP", side = 2, line = 5, cex = 1.5)
mtext("Psychological Distress:\nNo. of standard deviations above or below the mean", side = 1, line = 7, cex = 1.5)
abline(h = 0, lwd = 4, col = "brown", lty = 2)

###############################################################################
# HED
###############################################################################
par(mar = c(10, 7, 2, 0.5) + 0.1)  # Bottom, left, top, right
dat_plot0 <- dat_plot[dat_plot$model=="HED_model03",]
plot(-1, 
     type="n",
     xlim = c(min_xlim, max_xlim),
     ylim = c(min_ylim, max_ylim),
     xlab = "",
     ylab = "",
     frame.plot = FALSE,
     xaxt = "n", yaxt = "n")
axis(1, at = these_xvals, cex.lab = 1.5, cex.axis = 1.5, lwd = 5)
axis(2, at = these_yvals, cex.lab = 1.5, cex.axis = 1.5, lwd = 5)
lines(dat_plot0$stress, dat_plot0$est, type = "l", lwd = 5)
lines(dat_plot0$stress, dat_plot0$LB95, type = "l", lwd = 5, lty = 3, col = "cornflowerblue")
lines(dat_plot0$stress, dat_plot0$UB95, type = "l", lwd = 5, lty = 3, col = "cornflowerblue")
mtext("Effect of psychological distress on HED", side = 2, line = 5, cex = 1.5)
mtext("Psychological Distress:\nNo. of standard deviations above or below the mean", side = 1, line = 7, cex = 1.5)
abline(h = 0, lwd = 4, col = "brown", lty = 2)


