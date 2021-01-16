# mouseoxR
A function to analyze data from a MouseOx Mouse and Rat Pulse Oximeter.

To load the alpha version of `mouseoxR`, paste the following line into your R terminal. You only need to do this  if the `mouseoxR` function isn't already loaded in your environment.

```
devtools::source_url("https://raw.githubusercontent.com/jsodicoff/mouseoxR/main/mouseox.R")
```

There is one function in the file, also named `mouseoxR`. It takes 2 required parameters and two optional ones.

* Required
  * `file` - the output file from your MouseOx device, or some type of Excel file.
  * `time.points` - a named list of time points to use in analysis.
* Optional
  * `out.loc` - the directory to save the analyzed data to, in csv format.
  * `start.time` - the time recorded in your output file that your time points are measured from.
 
Here's an example call:

```
output = mouseoxR(file = "/Downloads/mouseox_out.txt",
                  out.loc = "Desktop/data/",
                  start.time = 567,
                  time.points = list(
                    pre_stim = 0,
                    stim_1 = 500,
                    stim_2 = 1000,
                    post_stim = 1250,
                    complete = 2000
                   )
```

The `output` object contains a nested list of generated results. Here's the structure.

* `output`
  * data
  * time_plot
  * bar_plot
  * individual_plots
    * time
        * o2
        * heart
        * breath
        * pulse
     * bar
        * o2
        * heart
        * breath
        * pulse

`data` returns a data frame of average recorded values by time point. All other terminal elements include plots.

To access the elements, use list indexing! `output[["data"]]` returns the data frame. `output[["time_plot"]]` returns a combined plot of heart rate and blood pressure over time. `output[["individual_plots"]][["bar"]][["o2"]]` returns a bar plot of arterial oxygen saturation by time point. But!,  `output[["individual_plots"]][["bar"]]` returns a list, which is not that helpful for viewing or saving.

Once you have opened a plot in the `Plots` panel, save it by hitting `Export`.

Merry measurement!

![](https://www.models-resource.com/resources/big_icons/37/36283.png)
