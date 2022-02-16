library(geeM)
library(dplyr)

ColumnSummary <- function(x){
  
  MEAN <- mean(x, na.rm=TRUE)
  SD <- sd(x, na.rm=TRUE)
  MIN <- min(x, na.rm=TRUE)
  MAX <- max(x, na.rm=TRUE)
  NMISS <- sum(is.na(x))
  PMISS <- NMISS/length(x)
  
  out <- data.frame(MEAN = MEAN, SD = SD, MIN = MIN, MAX = MAX, NMISS = NMISS, PMISS = PMISS)
}

FormatGEEOutput <- function(fit){
  outfit <- cbind(estimates = summary(fit)$beta, se = summary(fit)$se.robust, p = summary(fit)$p)
  outfit <- as.data.frame(outfit)
  outfit$parameter <- summary(fit)$coefnames
  
  # Column 'estimates' is of character type
  outfit <- outfit %>%
    mutate(estimates = format(round(estimates, 2), nsmall=2)) %>%
    mutate(estimates = case_when(
      p <= 0.10 & p > 0.05 ~ paste(estimates, "\206", sep=""),
      p <= 0.05 & p > 0.01 ~ paste(estimates, "*", sep=""),
      p <= 0.01 & p > 0.001 ~ paste(estimates, "**", sep=""),
      p <= 0.001 ~ paste(estimates, "***", sep=""),
      TRUE ~ as.character(estimates)
    )) %>%
    mutate(se = format(round(se, 2), nsmall=2)) %>%
    mutate(p = format(round(p, 3), nsmall=3))
  
  outfit <- outfit %>% select(parameter, everything())
  
  return(outfit)
}


CondenseGEEOutput <- function(fit){
  # Note: This function is only used in the scripts boot-mediation-XX.R
  outfit <- cbind(estimates = summary(fit)$beta, se = summary(fit)$se.robust, p = summary(fit)$p)
  outfit <- as.data.frame(outfit)
  row.names(outfit) <- summary(fit)$coefnames
  # Column 'estimates' is of numeric type
  # Names of parameters are row names, and not in a column of their own
  
  return(outfit)
}


GetSS <- function(use_this_model, L, contrast_labels = NULL){
  # Function to calculate p-values for a two-sided test and 95% confidence intervals
  # The p-values correspond to the test of the null Lmat*beta = 0 against the
  # alternative Lmat*beta is not equal to 0
  
  alpha <- .05
  est_beta <- as.matrix(use_this_model$beta)
  coefnames <- use_this_model$coefnames
  est_cov_beta <- use_this_model$var
  converged <- 1*(use_this_model$converged==TRUE)
  
  if(converged==1){
    est_ss <- L %*% est_beta
    est_cov_ss <- L %*% est_cov_beta %*% t(L)
    est_stderr_ss <- sqrt(diag(est_cov_ss))
    est_stderr_ss <- as.matrix(est_stderr_ss)
    Z_ss <- est_ss/est_stderr_ss
    pval_ss <- 2*pnorm(abs(Z_ss), lower.tail = FALSE)
    LB95_ss <- est_ss - qnorm(1-alpha/2)*est_stderr_ss
    UB95_ss <- est_ss + qnorm(1-alpha/2)*est_stderr_ss
    
    # Round all results to 4 decimal places
    est_ss <- round(est_ss, digits=4)
    est_stderr_ss <- round(est_stderr_ss, digits=4)
    Z_ss <- round(Z_ss, digits=4)
    pval_ss <- round(pval_ss, digits=4)
    LB95_ss <- round(LB95_ss, digits=4)
    UB95_ss <- round(UB95_ss, digits=4)
    
    if(is.null(contrast_labels)){
      results_ss <- data.frame(estimates = est_ss, se = est_stderr_ss, p = pval_ss)
      
      results_ss <- results_ss %>%
        mutate(estimates = format(round(estimates, 2), nsmall=2)) %>%
        mutate(estimates = case_when(
          p <= 0.10 & p > 0.05 ~ paste(estimates, "\206", sep=""),
          p <= 0.05 & p > 0.01 ~ paste(estimates, "*", sep=""),
          p <= 0.01 & p > 0.001 ~ paste(estimates, "**", sep=""),
          p <= 0.001 ~ paste(estimates, "***", sep=""),
          TRUE ~ as.character(estimates)
        )) %>%
        mutate(se = format(round(se, 2), nsmall=2)) %>%
        mutate(p = format(round(p, 3), nsmall=3))
      
    }else{
      results_ss <- data.frame(contrast = contrast_labels, estimates = est_ss, se = est_stderr_ss, p = pval_ss)
      
      results_ss <- results_ss %>%
        mutate(estimates = format(round(estimates, 2), nsmall=2)) %>%
        mutate(estimates = case_when(
          p <= 0.10 & p > 0.05 ~ paste(estimates, "\206", sep=""),
          p <= 0.05 & p > 0.01 ~ paste(estimates, "*", sep=""),
          p <= 0.01 & p > 0.001 ~ paste(estimates, "**", sep=""),
          p <= 0.001 ~ paste(estimates, "***", sep=""),
          TRUE ~ as.character(estimates)
        )) %>%
        mutate(se = format(round(se, 2), nsmall=2)) %>%
        mutate(p = format(round(p, 3), nsmall=3))
      
    }
  }else{
    results_ss <- data.frame(msg = "did not converge") 
  }
  
  return(results_ss)
}




