#file, the location of the txt or xlsx to use
#out.loc, the directory to save the output file to
#time.points, a named list of integer values, corresponding to the names of time points
#start.time, the second at which the rest of the time points are from

mouseoxR = function(file, out.loc, time.points, start.time = 0){
  install.packages(setdiff(c("readxl","ggplot2","ggformula","cowplot"),installed.packages()[,1]))
  ex = strsplit(file, "\\.")[[1]]
  ex = ex[-1]
  if(ex == "txt"){
    ox_output = read.csv(file)
  } else {
    ox_output = readxl::read_excel(file)
  }
  time_points = lapply(time.points, function(x){return(round(x) - round(start.time))})
  ox_output = ox_output[-c(1,2), ]
  
  ox_output$Elapsed = as.double(as.character(ox_output$Elapsed))
  ox_output$Error = as.double(as.character(ox_output$Error))
  ox_output$Arterial.O2 = as.double(as.character(ox_output$Arterial.O2))
  ox_output$Heart = as.double(as.character(ox_output$Heart))
  ox_output$Breath = as.double(as.character(ox_output$Breath))
  ox_output$Pulse = as.double(as.character(ox_output$Pulse))
  
  ox_output$Breath[!ox_output$Error %in% c(0,4)] = NA
  ox_output$Heart[!ox_output$Error %in% c(0,3,4,7)] = NA

  avg_val_df = data.frame(time_point = unlist(time_points),
                          description = names(time_points),
                          o2 = numeric(length(time_points)),
                          heart = numeric(length(time_points)),
                          breath = numeric(length(time_points)),
                          pulse = numeric(length(time_points)))
  time_ranges = unname(c(unlist(time_points), ox_output$Elapsed[nrow(ox_output)]))
  time_ranges = match(time_ranges, ox_output$Elapsed)
  for(i in 1:(length(time_ranges) - 1)){
    avg_val_df$o2[i] = mean(as.double(ox_output$Arterial.O2[(time_ranges[i]):(time_ranges[i+1])]), na.rm = TRUE)
    avg_val_df$heart[i] = mean(as.double(ox_output$Heart[(time_ranges[i]):(time_ranges[i+1])]), na.rm = TRUE)
    avg_val_df$breath[i] = mean(as.double(ox_output$Breath[(time_ranges[i]):(time_ranges[i+1])]), na.rm = TRUE)
    avg_val_df$pulse[i] = mean(as.double(ox_output$Pulse[(time_ranges[i]):(time_ranges[i+1])]), na.rm = TRUE)
  }
  library(ggplot2)
  library(ggformula)
  o2_plot = ggplot(ox_output, aes(x = Elapsed, y = Arterial.O2)) +
    geom_spline() +
    ggtitle("") + xlab("Seconds Elapsed") + ylab("Arterial O2 Saturation")
  heart_plot = ggplot(ox_output, aes(x = Elapsed, y = Heart)) +
    geom_spline() +
    ggtitle("") + xlab("Seconds Elapsed") + ylab("Heart Rate (BPM)")
  breath_plot = ggplot(ox_output, aes(x = Elapsed, y = Breath)) +
    geom_spline() +
    ggtitle("") + xlab("Seconds Elapsed") + ylab("Breath Rate (BRPM)")
  pulse_plot = ggplot(ox_output, aes(x = Elapsed, y = Pulse)) +
    geom_spline() +
    ggtitle("") + xlab("Seconds Elapsed") + ylab("Pulse Distention (um)")
  o2_bar_plot = ggplot(avg_val_df, aes(x = description, fill = description, y = o2)) +
    geom_bar(stat = "identity") + 
    ggtitle("") + xlab("Timepoint") + ylab("Arterial O2 Saturation") +
    theme(legend.position = "none")
  heart_bar_plot = ggplot(avg_val_df, aes(x = description, fill = description, y = heart)) +
    geom_bar(stat = "identity") + 
    ggtitle("") + xlab("Timepoint") + ylab("Heart Rate (BPM)") +
    theme(legend.position = "none")
  breath_bar_plot = ggplot(avg_val_df, aes(x = description, fill = description, y = breath)) +
    geom_bar(stat = "identity") + 
    ggtitle("") + xlab("Timepoint") + ylab("Breath Rate (BRPM)") +
    theme(legend.position = "none")
  pulse_bar_plot = ggplot(avg_val_df, aes(x = description, fill = description, y = pulse)) +
    geom_bar(stat = "identity") + 
    ggtitle("") + xlab("Timepoint") + ylab("Arterial O2 Saturation") +
    theme(legend.position = "none")
  
  library(cowplot)
  time_plot = plot_grid(heart_plot, breath_plot)
  bar_plot = plot_grid(heart_bar_plot, breath_bar_plot)
  if(!is.null(out.loc)){
    write.csv(avg_val_df, paste0(out.loc,"mouseoxr_analysis.csv"))
  }
  return(list(data = avg_val_df,
              time_plot = time_plot,
              bar_plot = bar_plot,
              individual_plots = list(
                  time = list(
                    o2 = o2_plot,
                    heart = heart_plot,
                    breath = breath_plot,
                    pulse = pulse_plot
                  ),
                  bar = list(
                    o2 = o2_bar_plot,
                    heart = heart_bar_plot,
                    breath = breath_bar_plot,
                    pulse = pulse_bar_plot
                  )
                )
              )
         )
}
