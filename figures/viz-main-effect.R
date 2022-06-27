CurvilinearEffect <- function(stress, time, model){
  
  if(model == "RAPI_model05"){
    out <- (0.32)*stress + (-0.08)*stress*stress + time*((-0.01)*stress + (0.06)*stress*stress)
  }else if(model == "HED_model05"){
    out <- (0.06)*stress + (-0.07)*stress*stress + time*((0.00)*stress + (0.02)*stress*stress)
  }else{
    out <- -99
  }
  return(out)
}

dat_input <- expand.grid(stress = seq(-10,10,0.1), time = c(0,1), model = c("RAPI_model05","HED_model05"))
effect <- mapply(CurvilinearEffect, dat_input$stress, dat_input$time, dat_input$model)
dat_plot <- cbind(dat_input, effect)


###############################################################################
# RAPI
###############################################################################

par(mar = c(10, 5, 2, 0.5) + 0.1, mfrow = c(1,2))  # Bottom, left, top, right
dat_plot0 <- dat_plot[dat_plot$time==0 & dat_plot$model=="RAPI_model05",]
plot(-1, 
     type="n",
     xlim = c(-10,10),
     ylim = c(min(effect)-1,max(effect)+1),
     xlab = "",
     ylab = "Effect of psychological distress on RAPI", 
     cex.lab = 1.5,
     cex.axis = 1.5,
     frame.plot = FALSE)
lines(dat_plot0$stress, dat_plot0$effect, type = "l", lwd = 5)
mtext("RAPI at time 0", side = 3, line = 0, cex = 1.5)
mtext("Psychological Distress:\nNo. of standard deviations\nabove or below the mean", side = 1, line = 7, cex = 1.5)
dat_plot1 <- dat_plot[dat_plot$time==1 & dat_plot$model=="RAPI_model05",]
plot(-1, 
     type="n",
     xlim = c(-10,10),
     ylim = c(min(effect)-1,max(effect)+1),
     xlab = "",
     ylab = "Effect of psychological distress on RAPI", 
     cex.lab = 1.5,
     cex.axis = 1.5,
     frame.plot = FALSE)
lines(dat_plot1$stress, dat_plot1$effect, type = "l", lwd = 5)
mtext("RAPI at time 1", side = 3, line = 0, cex = 1.5)
mtext("Psychological Distress:\nNo. of standard deviations\nabove or below the mean", side = 1, line = 7, cex = 1.5)

###############################################################################
# HED
###############################################################################

par(mar = c(10, 5, 2, 0.5) + 0.1, mfrow = c(1,2))  # Bottom, left, top, right
dat_plot0 <- dat_plot[dat_plot$time==0 & dat_plot$model=="HED_model05",]
plot(-1, 
     type="n",
     xlim = c(-10,10),
     ylim = c(min(effect)-1,max(effect)+1),
     xlab = "",
     ylab = "Effect of psychological distress on HED", 
     cex.lab = 1.5,
     cex.axis = 1.5,
     frame.plot = FALSE)
lines(dat_plot0$stress, dat_plot0$effect, type = "l", lwd = 5)
mtext("HED at time 0", side = 3, line = 0, cex = 1.5)
mtext("Psychological Distress:\nNo. of standard deviations\nabove or below the mean", side = 1, line = 7, cex = 1.5)
dat_plot1 <- dat_plot[dat_plot$time==1 & dat_plot$model=="HED_model05",]
plot(-1, 
     type="n",
     xlim = c(-10,10),
     ylim = c(min(effect)-1,max(effect)+1),
     xlab = "",
     ylab = "Effect of psychological distress on HED", 
     cex.lab = 1.5,
     cex.axis = 1.5,
     frame.plot = FALSE)
lines(dat_plot1$stress, dat_plot1$effect, type = "l", lwd = 5)
mtext("HED at time 1", side = 3, line = 0, cex = 1.5)
mtext("Psychological Distress:\nNo. of standard deviations\nabove or below the mean", side = 1, line = 7, cex = 1.5)


