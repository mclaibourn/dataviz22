# Data Viz in R
# 2022-08-31
# Practicing with R


# ..................................................
# Good Coding Practices ----

# If your using packages, load them all at once 
#   at the beginning

# Use code sections to break up your script 
#   into discrete, readable (labeled) chunks: 
#   - creates easy navigation between them
#   - sections are automatically foldable
#   - a comment line with four+ trailing dashes (-), 
#     equal signs (=), or pound signs (#) 
#   - automatically creates a code section
#   - and you can use the Jump To menu at the bottom of the editor to navigate

# Try to limit a given line of code to 80 characters 

# Add a space after a comma (for readability)
#   While you're at it, add spaces around 
#   <-, = and ==, and other separators

# Pick an object naming convention
#   I like snake_case (all lower case)
#   But CamelCase is popular, too
#   Don't use spaces
#   And stay away from . 
#     (base R uses . in function names)


# ..................................................
# Load libraries and data ----
# Libraries
library(tidyverse)
library(ggforce) # for sina plot
library(ggridges) # for ridge plot
library(treemapify) # for tree plot
library(waffle) # for wafflet plot


# Data
property <- read_csv("data/parcels_cards_chacteristics.csv")


# ..................................................
# Factors ----
property %>% count(condition) # currently a character

property %>% 
  mutate(condition = factor(condition)) %>% # make a factor
  count(condition)

# assert the ordering of the factor levels
cond_levels <- c("Excellent", "Good", "Average", "Fair", "Poor", "Very Poor", "Unknown")

property <- property %>% 
  mutate(condition = factor(condition, levels = cond_levels)) 

property %>% count(condition)

# giving the factor levels new labels
#   labels in vector are assigned by the order of the level
cond_labels <- c("The best", "Solid", "Okay", "Meh", "Not great", "Really bad", "Who knows?")

property %>% 
  mutate(condition2 = factor(condition, 
                             levels = cond_levels,
                             labels = cond_labels)) %>% 
  count(condition2, condition)


# forcats
# create level by frequency
property %>% 
  mutate(condition = fct_infreq(condition)) %>% 
  count(condition)

# combine small levels, fct_lump_n (min, prop, etc.)
property %>% 
  mutate(condition = fct_lump_n(condition, 6)) %>% 
  count(condition)

# recode levels, fct_collapse (also fct_recode)
property %>% 
  mutate(condition = fct_collapse(condition,
                                  missing = c("Unknown")),
         condition = fct_explicit_na(condition, na_level = "missing")) %>% 
  count(condition)


# ..................................................
# Distributions ----

p <- ggplot(property, aes(x = totalvalue))

p + geom_histogram()

# To try:
# change the bins
# change the color of the bars

p + geom_density()

# To try:
# change the bandwidth, e.g, adjust = 1/2 means use half the default bandwidth
# change the color of the line

p + geom_density(aes(fill = hsdistrict, color = hsdistrict), alpha = 1/3) 

# To try:
# limit the axis with coord_cartesian() -- zooms in without changing underlying data
# limit the axis with scale_x_continuous() -- converts values outside of range to NA


# Comparing distributions
# Box plots
property %>%   
  filter(!hsdistrict %in% c("Unassigned", "NULL"), 
         !is.na(hsdistrict),
         finsqft < 10000) %>% 
  ggplot(aes(x = hsdistrict, y = finsqft)) +
  geom_boxplot(fill = "grey90") 


# strip charts
property %>%   
  filter(!hsdistrict %in% c("Unassigned", "NULL"), 
         !is.na(hsdistrict),
         finsqft < 10000) %>% 
  ggplot(aes(x = hsdistrict, y = finsqft)) +
  geom_point(size = 0.25, position = "jitter", 
             color = "gray50", alpha = 1/5) +
  stat_summary(fun = "median", geom = "point", 
               size = 3, color = "red")


# Violin plots
property %>%   
  filter(!hsdistrict %in% c("Unassigned", "NULL"), 
         !is.na(hsdistrict),
         finsqft < 10000) %>% 
  ggplot(aes(x = hsdistrict, y = finsqft)) +
  geom_violin(fill = "gray50") 

# To try:
# flip the coordinate
# add some color


# Sina plots 
property %>%   
  filter(!hsdistrict %in% c("Unassigned", "NULL"), 
         !is.na(hsdistrict),
         finsqft < 10000) %>% 
  
  ggplot(aes(x = hsdistrict, y = finsqft, color = hsdistrict)) +
  geom_violin() +
  geom_sina(shape = ".", alpha = 1/10) + 
  scale_color_manual(
    values = c("red", "gold", "blue"),
    guide = "none"
  ) +
  labs(x = "High School District",
       y = "Finished Square Feet")

# To try:
# change the shape to . or reduce alpha or both
# put a violin underneath (before sina)


# ridge plots
property %>% 
  filter(finsqft < 5000,
         !esdistrict %in% c("NULL", "Unassigned", "Yancey"),
         !is.na(esdistrict)) %>% 

  ggplot(aes(x = finsqft, y = esdistrict)) +
  geom_density_ridges() +
  coord_cartesian(clip = "off") +
  labs(x = "Finished Square Feet",
       y = "School District",
       title = "Home Sizes by School District") +
  theme_ridges()

# To try:
# order school districts by number of homes (e.g., fct_infreq())
# order by median size of homes (e.g., fct_reorder())


# ..................................................
# Amounts ----
# Grouped bars
# Create era built factor, value_sqft from last week
property <- property %>% 
  mutate(value_sqft = totalvalue/finsqft,
         era = case_when(
           yearbuilt < 1950 ~ "Pre-1950",
           yearbuilt >= 1950 & yearbuilt < 2000 ~ "1950-1999",
           yearbuilt >= 2000 ~ "Post-2000"),
         era = factor(era, levels = c("Pre-1950", "1950-1999", "Post-2000"))
  )

# use era built as fill factor
property %>% 
  filter(magisterialdistrict != "Unassigned") %>%
  ggplot(aes(x = fct_infreq(magisterialdistrict), fill = era)) +
  geom_bar(position = "dodge") 

# To try:
# group districts within eras instead
# instead of grouping, try faceting


# Dot plots (or lollipops)

# find median value per square foot in county
medvalue <- property %>% 
  filter(!esdistrict %in% c("NULL", "Unassigned", "Yancey"),
         !is.na(esdistrict)) %>% 
  summarize(med_value_sqft = median(value_sqft, na.rm = TRUE)) %>% 
  as_vector()

# make property by elementary district data frame
prop_by_esdistrict <- property %>% 
  filter(!esdistrict %in% c("NULL", "Unassigned", "Yancey"),
         !is.na(esdistrict)) %>% 
  group_by(esdistrict) %>% 
  summarize(med_value_sqft = median(value_sqft, na.rm = TRUE)) %>%
  # add variable for whether district median is above or below county median
  mutate(hi_lo = ifelse(med_value_sqft < medvalue, "Low", "High"))

# dot plot
prop_by_esdistrict %>% 
  ggplot(aes(x = med_value_sqft, 
             y = fct_reorder(esdistrict, med_value_sqft))) + 
  geom_point(size = 5, color = "#0072B2") +  
  labs(title = "Does Assessed Value per Square Footage of Homes Vary by School District?",
       subtitle = "Median Assesed Value/Square Foot by Elementary School Zones", 
       x = "Median Assessed Value per Square Foot",
       y = "") +
  theme_minimal()

# lollipop version
prop_by_esdistrict %>% 
  ggplot(aes(x = med_value_sqft, 
             y = fct_reorder(esdistrict, med_value_sqft))) + 
  geom_point(size = 5, color = "#0072B2") +  
  geom_segment(aes(x=0, xend=med_value_sqft, y=esdistrict, yend=esdistrict), 
               color = "grey") + 
  labs(title = "Does Assessed Value per Square Footage of Homes Vary by School District?",
       subtitle = "Median Assesed Value/Square Foot by Elementary School Zones", 
       x = "Median Assessed Value per Square Foot",
       y = "") +
  theme_minimal()

# To try:
# add reference line for median value 
# adjust the line segment to reflect deviation
# color by hi_lo 


# ..................................................
# BONUS: Recreating Wilke's heatmap
# Create number of houses built each year by magisterial district
prop_by_year <- property %>% 
  filter(!magisterialdistrict %in% c("NULL", "Unassigned"),
         !is.na(magisterialdistrict),
         yearbuilt > 1900) %>% 
  group_by(yearbuilt, magisterialdistrict) %>% 
  summarize(num_built = n())  

# Fill in missing year/district pairs with 0
prop_by_year <- prop_by_year %>% 
  group_by(magisterialdistrict) %>% 
  complete(yearbuilt = full_seq(1901:2021, 1), 
           fill = list(num_built = 0)) 

# heatmap/tile
prop_by_year %>% 
  ggplot(aes(x = yearbuilt, y = magisterialdistrict, fill = num_built)) +
  geom_tile(color = "white", size = 0.1) +
  # color = "white" add white line separator between tiles
  scale_fill_viridis_c(
    option = "plasma", 
    name = "Number of houses built/year",
    guide = guide_colorbar(
      direction = "horizontal",
      label.position = "bottom",
      title.position = "top",
      ticks = FALSE,
      barwidth = grid::unit(3, "in"),
      barheight = grid::unit(0.2, "in")
    )
  ) +
  labs(title = "Housing Growth by Magisterial District") +
  # I borrowed this from Wilke 
  scale_x_continuous(expand = c(0, 0), name = NULL) +
  # make the plotted figure fill the full plot
  scale_y_discrete(name = NULL, position = "right") +
  # remove the y axis title and put labels on the right
  theme(
    axis.line = element_blank(),
    axis.ticks = element_blank(),
    axis.ticks.length = grid::unit(1, "pt"),
    legend.position = "bottom",
    legend.justification = "right",
    legend.title.align = 0.5,
    legend.title = element_text(size = 12*12/14)
  )
# alter the theme to control legend placement


# ..................................................
# Proportions ----

# Pie charts and donuts -- though you probably shouldn't

# Map use codes to residence type
count(property, usecode) %>% View()

sfh <- c("Single Family", "Single Family-Rental")
mfh <- c("3-4 Family", "Apartment", "Apartments",
         "Condo-Res-TH", "Condo-Res-Garden", 
         "Duplex", "Doublewide", "Mobile Home", 
         "Multi-Family", "Small Apartment")
vac <- c("Vacant (R5-R6)", "Vacant Residential Land")

# Pie and Donut data prep
prop_pie <- property %>% 
  mutate(use = case_when(
    usecode %in% sfh ~ "single-family",
    usecode %in% mfh ~ "multi-family",
    usecode %in% vac ~ "vacant-land",
    TRUE ~ "non-residence"
  ),
  use = factor(use, levels = c("single-family", 
                               "multi-family", 
                               "vacant-land", 
                               "non-residence"))
  ) %>% 
  filter(!use == "non-residence") %>% 
  group_by(use) %>% 
  summarize(num = n())  %>% 
  arrange(num) %>% 
  # this sorts the data in the order I want it to plot
  mutate(prop = num/sum(num) * 100,
         # calculate the percent within each type
         ypos = cumsum(prop) - 0.5*prop,
         # calculate point for label position
         label = ifelse(prop > 5, as.character(use), NA_character_)
         # don't print labels if value is really small
         )

# Pie 
ggplot(prop_pie, aes(x = 1, y = prop, fill = use)) + 
  geom_col(color = "white") + 
  coord_polar(theta = "y") +
  geom_text(aes(y = ypos, x = 1.25, label = label), 
            color = "white", size=4) +
  guides(fill = "none") +
  theme_void()


# Donut
ggplot(prop_pie, aes(x = 2, y = prop, fill = use)) + 
  geom_col(color = "white") + 
  coord_polar(theta = "y") +
  geom_text(aes(y = ypos, x = 2, label = label), 
            color = "white", size=4) +
  guides(fill = "none") +
  xlim(0.5, 2.5) +
  theme_void()


# Tree map
acreage <- property %>% 
  group_by(magisterialdistrict) %>% 
  summarize(acres = sum(lotsize)) %>% 
  mutate(label = paste(magisterialdistrict, scales::comma(acres), "acres", sep = "\n"))

ggplot(acreage, aes(area = acres, fill = acres, 
                    label = label)) +
  geom_treemap() + 
  geom_treemap_text(colour = "white") +
  labs(title = "Residential Acreage by Magisterial District") +
  theme(legend.position = "none")


# Waffles
# https://github.com/hrbrmstr/waffle
(prop_waffle <- prop_pie %>% 
    mutate(num_scaled = round(num/100)) %>% 
    select(use, num_scaled) %>% 
    droplevels())

# using geom_waffle 
ggplot(prop_waffle, aes(fill = use, values = num_scaled)) +
  geom_waffle(n_rows = 10, color = "white", flip = TRUE) +
  coord_equal() +
  scale_fill_manual(values = c("#969696", "#009bda", "#c7d4b6", "#97b5cf"),
                    name = "") +
  theme_void() +
  theme(legend.position = "bottom") 

