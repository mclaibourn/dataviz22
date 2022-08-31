# Data Viz in R
# Problem Set 2: wrangling in R, graphing in R
# Due 2022-09-07


# Be sure to use good coding practices in your problem set script!


# 1. Install/load packages ----

library(tidyverse)
# add whatever libraries you need to complete the assignment


# 2. Load and explore the data ----

# Download birth data in the FiveThirtyEight github repo 
#   You can see their description here: https://github.com/fivethirtyeight/data/tree/master/births
#   We'll grab the SSA provided data from 2000-2014

births <- read_csv("https://github.com/fivethirtyeight/data/blob/master/births/US_births_2000-2014_SSA.csv?raw=true")

# Have a look at the data and get a feel for what's here 
#   (head, glimpse, summary, View, etc.)



# 3. Factors ----

# a. Create a new variable, month_name, that turns month into a factor
#   and assigns the name of the month as the level of the factor;
# b. Create a new variable, day_name, that turns day_of_week into
#   a factor and assigns the name of the day as the level  
#      (the github page tells us 1 is Monday, 7 is Sunday); 
# c. Create an indicator variable, weekend, for weekend days



# d. Look at (print to the console) the total number of births 
#   by month using your new month_name variable
#   (you'll need to sum the births variable)



# 4. Visualizing Distributions ----

# a. Look at the distribution of the number of births (births) by day;
#    each row is a different day, so a histogram shows you for how many
#    days in this 15 year period (or this period of 5,479 days) 
#    there have been X number of births;
# a. try a histogram (choose a number of bins)
# b. try a density plot
# add a title and axis titles; feel free to make them prettier



# c. What do you notice?


# d. Look at the distribution of number of births by the 
#   day of the week (day_name)
#   generate two of the following chart types: 
#     strip chart, violin plot, sina plot
#   make sure the days of the week are shown in a reasonable order

#   try having some fun with these -- add some color, 
#   add a summary function, play with alpha, switch the x and y, etc. 



# 5. Visualizing Amounts ----

# a. First, make a new dataframe that calculates the average and median
#   daily births by month. 
# b. Then make a bar plot of the averages.
#   Be sure to add titles and appropriate axis labels 
#   (which may be no axis labels).


# c. Make a dot plot of the median daily birth rate.
#   Feel free to play with color, point size, or other attributes!



# d. Turn the dot plot into a lollipop chart emphasizing how the  
#   median for each month compares to the overall median monthly 
#   (the overall median is 12,320; you'll want to add a geom_segment
#    and probably a geom_vline for reference). 
#   Feel free to play with color, point size, or other attributes!

