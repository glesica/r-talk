# Filename: traffic.r
# Author: George Lesica <george@lesica.com>
# Description: An example of some basic R functions using a small web site
# traffic dataset.

# In order to work with our data we need to read it in. This is easily
# accomplished with the `read.csv` function. Note a few things we do here.
# First, we use the `skip` parameter to skip the first 6 lines of the file.
# Open it in your editor to figure out why we need to do that. We set `header`
# to `T`, which is shorthand for `TRUE` to tell R that the first row of data
# are column headers. Next, we change the column headers because the ones in
# the file are ugly. We could have just skipped 7 lines and saved some
# complexity. We read all the columns as `character` data for simplicity. R has
# a nasty habit of choosing weird data types if you don't tell it what to do,
# so this is sometimes a good practice. Later, on the next two lines, we
# convert the columns to appropriate data types.

traf <- read.csv('data/traffic.csv', skip=6, header=T,
                       colClasses='character')
colnames(traf) <- c('Date', 'Visitors')
traf$Date <- as.Date(traf$Date, format='%m/%d/%Y')
traf$Visitors <- as.integer(traf$Visitors)

# Now that we've got our data let's make a simple plot. R is great for
# exploring data, most functions have totally sane defaults so you can quickly
# generate useful plots and analyses.

plot(traf$Date, traf$Visitors)
title('Visitors Over Time')

# Notice that the axis labels are taken from the data series names. This isn't
# great, especially when using a data frame. Let's try again with nicer labels.
# We are using the plotting functionality that is built-in to R. This system is
# stateful, so once we have created a plot we can continue to call plotting
# functions and most of them will edit the existing plot instead of creating a
# new one. This is how we create the plot title.

plot(traf$Date, traf$Visitors, xlab='Date', ylab='Visitors')
title('Visitors Over Time')

# So far the data look like a mess. Let's add a trend line to check for a
# correlation between the date and the number of visitors.

abline(lm(traf$Visitors ~ traf$Date))

# Again, the function edited the existing plot. Now we have a fancy trend line!
# Let's take a closer look at the call to `lm` since, as it turns out, it has a
# great deal of importance on its own outside of creating trendlines.

traf.model <- lm(traf$Visitors ~ traf$Date)

# This creates a linear model object (lm stands for "linear model"). The syntax
# `y ~ x` basically means "y varies with x". We can get a printout similar to
# what you could expect from SPSS or STATA by calling the `summary` function on
# the linear model object.

summary(traf.model)

# If you source this file from within R using the echo option you will be able
# to see all the output.
