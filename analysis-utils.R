library(geeM)

FormatGEEOutput <- function(fit){
  outfit <- round(cbind(estimates = summary(fit)$beta, se = summary(fit)$se.robust, p = summary(fit)$p), digits=3)
  outfit <- as.data.frame(outfit)
  row.names(outfit) <- summary(fit)$coefnames
  return(outfit)
}

GetSS <- function(use_this_model, L, contrast_labels = NULL){
  # Function to calculate p-values for a two-sided test and 95% confidence intervals
  # The p-values correspond to the test of the null Lmat*beta = 0 against the
  # alternative Lmat*beta is not equal to 0
  
  alpha <- .05
  est_beta <- as_matrix(use_this_model$beta)
  coefnames <- use_this_model$coefnames
  est_cov_beta <- use_this_model$var
  converged <- 1*(use_this_model$converged==TRUE)
  
  if(converged==1){
    est_ss <- L %*% est_beta
    est_cov_ss <- L %*% est_cov_beta %*% t(L)
    est_stderr_ss <- sqrt(diag(est_cov_ss))
    est_stderr_ss <- as.matrix(est_stderr_ss)
    Z_ss <- est_ss/est_stderr_ss
    pval_ss <- 2*pnorm(abs(Z_ss), lower_tail = FALSE)
    LB95_ss <- est_ss - qnorm(1-alpha/2)*est_stderr_ss
    UB95_ss <- est_ss + qnorm(1-alpha/2)*est_stderr_ss
    
    # Round all results to 4 decimal places
    est_ss <- round(est_ss, digits=4)
    est_stderr_ss <- round(est_stderr_ss, digits=4)
    Z_ss <- round(Z_ss, digits=4)
    pval_ss <- round(pval_ss, digits=4)
    
    if(is.null(contrast_labels)){
      results_ss <- data.frame(est = est_ss, SE = est_stderr_ss, Z = Z_ss, pval = pval_ss, LB95 = LB95_ss, UB95 = UB95_ss)
    }else{
      results_ss <- data.frame(contrast = contrast_labels, est = est_ss, SE = est_stderr_ss, Z = Z_ss, pval = pval_ss, LB95 = LB95_ss, UB95 = UB95_ss)
    }
  }else{
    results_ss <- data.frame(msg = "did not converge") 
  }
  
  return(results_ss)
}




