## Poznámky k DC kurzùm na grafy (Introduction to/Intermediate) Data Vizualization with `ggplot2`

## encoding: windows-1250
## vytvoøil: 2021-04-26 FrK
## upravil:  2021-04-26 FrK

## Adresy na kurzy -- základní:
# https://learn.datacamp.com/courses/introduction-to-data-visualization-with-ggplot2

## Pokroèilý:
# https://learn.datacamp.com/courses/intermediate-data-visualization-with-ggplot2

## Package
library(ggplot2)
library(dplyr)



# #Introduction to ... ----------------------------------------------------





# #Intermediate ... -------------------------------------------------------


# Chapter 1 ----------------------------------------------------------------

## Ex 10
# Define position objects
# 1. Jitter with width 0.2
posn_j <- position_jitter(width = 0.2)

# 2. Dodge with width 0.1
posn_d <- position_dodge(width = 0.1)

# 3. Jitter-dodge with jitter.width 0.2 and dodge.width 0.1
posn_jd <- position_jitterdodge(jitter.width = 0.2, dodge.width = 0.1)

# Create the plot base: wt vs. fcyl, colored by fam
p_wt_vs_fcyl_by_fam <- ggplot(mtcars, aes(y = wt, x = factor(cyl), color = factor(am)))

# Add a point layer
p_wt_vs_fcyl_by_fam +
  geom_point()



## Ex 11
# Add jittering only
p_wt_vs_fcyl_by_fam +
  geom_point(position = posn_j)

# Add dodging only
p_wt_vs_fcyl_by_fam +
  geom_point(position = posn_d)

# Add jittering and dodging
p_wt_vs_fcyl_by_fam +
  geom_point(position = posn_jd)


## Ex 12
p_wt_vs_fcyl_by_fam +
  geom_point(position = posn_j) +
  # Add a summary stat of std deviation limits
  stat_summary(fun.data = mean_sdl,
               fun.args = list(mult = 1),
               position = posn_d)

p_wt_vs_fcyl_by_fam +
  geom_point(position = posn_j) +
  # Change the geom to be an errorbar
  stat_summary(fun.data = mean_sdl, fun.args = list(mult = 1),
               position = posn_d, geom = 'errorbar')

p_wt_vs_fcyl_by_fam +
  geom_point(position = posn_j) +
  # Add a summary stat of normal confidence limits
  stat_summary(fun.data = mean_cl_normal,
               position = posn_d)


# Chapter 2 ----------------------------------------------------------------



# Chapter 3 ----------------------------------------------------------------

## Ex 02
ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  # Facet rows by am
  facet_grid(rows = vars(am))

ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  # Facet columns by cyl
  facet_grid(cols = vars(cyl))

ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  # Facet rows by am and columns by cyl
  facet_grid(rows = vars(am), cols = vars(cyl))

## Ex 03
# Musíme si pøipravit promìnnou, kterou normálnì má DC pøipravenou
mtcars = mtcars %>%
  mutate(fcyl_fam = interaction(mtcars$am, mtcars$cyl, sep = ":"))

# See the interaction column
mtcars$fcyl_fam

# Color the points by fcyl_fam
ggplot(mtcars, aes(x = wt, y = mpg, col = fcyl_fam)) +
  geom_point() +
  # Use a paired color palette
  scale_color_brewer(palette = "Paired")

# Update the plot to map disp to size
ggplot(mtcars, aes(x = wt, y = mpg, color = fcyl_fam, size = disp)) +
  geom_point() +
  scale_color_brewer(palette = "Paired")

# Update the plot
ggplot(mtcars, aes(x = wt, y = mpg, color = fcyl_fam, size = disp)) +
  geom_point() +
  scale_color_brewer(palette = "Paired") +
  # Grid facet on gear and vs
  facet_grid(rows = vars(gear), cols = vars(vs))


## Ex 04
ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  # Facet rows by am
  facet_grid(am ~ .)

ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  # Facet columns by cyl
  facet_grid(. ~ cyl)

ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  # Facet rows by am and columns by cyl
  facet_grid(am ~ cyl)


## Ex 05 (video)

## Ex 06
# Plot wt by mpg
ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  # The default is label_value
  facet_grid(cols = vars(cyl))

# Plot wt by mpg
ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  # Displaying both the values and the variables
  facet_grid(cols = vars(cyl), labeller = label_both)

# Plot wt by mpg
ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  # Label context
  facet_grid(cols = vars(cyl), labeller = label_context)

# Plot wt by mpg
ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  # Two variables
  facet_grid(cols = vars(vs, cyl), labeller = label_context)


## Ex 07
# Make factor, set proper labels explictly
mtcars$fam <- factor(mtcars$am, labels = c(`0` = "automatic",
                                           `1` = "manual"))
# Default order is alphabetical
ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  facet_grid(cols = vars(fam))

# Make factor, set proper labels explictly, and
# manually set the label order
mtcars$fam <- factor(mtcars$am,
                     levels = c(1, 0),
                     labels = c("manual", "automatic"))
# View again
ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  facet_grid(cols = vars(fam))


## Ex 08 (video)

## Ex 09
ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  # Facet columns by cyl
  facet_grid(cols = vars(cyl))

ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  # Update the faceting to free the x-axis scales
  facet_grid(cols = vars(cyl), scales = "free_x")

ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  # Swap cols for rows; free the y-axis scales
  facet_grid(rows = vars(cyl), scales = "free_y")

## Ex 10
# Musíme si opìt trochu upravit data:
mtcars = mtcars %>% rownames_to_column(var = "car")

# Samotné cvièení:
ggplot(mtcars, aes(x = mpg, y = car, color = fam)) +
  geom_point() +
  # Facet rows by gear
  facet_grid(rows = vars(gear))

ggplot(mtcars, aes(x = mpg, y = car, color = fam)) +
  geom_point() +
  # Free the y scales and space
  facet_grid(rows = vars(gear), scales = "free_y", space = "free_y")

## Ex 11 (video)

## Ex 12
ggplot(Vocab, aes(x = education, y = vocabulary)) +
  stat_smooth(method = "lm", se = FALSE) +
  # Create facets, wrapping by year, using vars()
  facet_wrap(vars(year))

ggplot(Vocab, aes(x = education, y = vocabulary)) +
  stat_smooth(method = "lm", se = FALSE) +
  # Create facets, wrapping by year, using a formula
  facet_wrap(~ year)

ggplot(Vocab, aes(x = education, y = vocabulary)) +
  stat_smooth(method = "lm", se = FALSE) +
  # Update the facet layout, using 11 columns
  facet_wrap(~ year, ncol = 11)

## Ex 13
ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_point() +
  # Facet rows by fvs and cols by fam
  facet_grid(rows = vars(vs, fam), cols = vars(gear))

ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_point() +
  # Update the facets to add margins
  facet_grid(rows = vars(vs, fam), cols = vars(gear), margins = T)

ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_point() +
  # Update the facets to only show margins on fam
  facet_grid(rows = vars(vs, fam), cols = vars(gear), margins = c("fam"))

ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_point() +
  # Update the facets to only show margins on gear and fvs
  facet_grid(rows = vars(vs, fam), cols = vars(gear), margins = c("gear", "vs"))

# Chapter 4 ----------------------------------------------------------------

## Ex 02
# Plot wt vs. fcyl
ggplot(mtcars, aes(x = cyl, y = wt)) +
  # Add a bar summary stat of means, colored skyblue
  stat_summary(fun.y = mean, geom = "bar", fill = "skyblue") +
  # Add an errorbar summary stat std deviation limits
  stat_summary(fun.data = mean_sdl, fun.args = list(mult = 1), geom = "errorbar", width = 0.1)

## Ex 03
# Update the aesthetics to color and fill by fam
ggplot(mtcars, aes(x = cyl, y = wt, color = fam, fill = fam)) +
  stat_summary(fun.y = mean, geom = "bar") +
  stat_summary(fun.data = mean_sdl, fun.args = list(mult = 1), geom = "errorbar", width = 0.1)

# Set alpha for the first and set position for each stat summary function
ggplot(mtcars, aes(x = cyl, y = wt, color = fam, fill = fam)) +
  stat_summary(fun.y = mean, geom = "bar", alpha = 0.5, position = "dodge") +
  stat_summary(fun.data = mean_sdl, fun.args = list(mult = 1), geom = "errorbar", position = "dodge", width = 0.1)

# Define a dodge position object with width 0.9
posn_d <- position_dodge(0.9)

# For each summary stat, update the position to posn_d
ggplot(mtcars, aes(x = cyl, y = wt, color = fam, fill = fam)) +
  stat_summary(fun.y = mean, geom = "bar", position = posn_d, alpha = 0.5) +
  stat_summary(fun.data = mean_sdl, fun.args = list(mult = 1), width = 0.1, position = posn_d, geom = "errorbar")


## Ex 04
# Pøipravíme si data:
mtcars_by_cyl = mtcars %>% group_by(cyl) %>%
  summarise(mean_wt = mean(wt), sd_wt = sd(wt), n_wt = n()) %>% ungroup() %>%
  mutate(prop = n_wt / sum(n_wt))

# Using mtcars_cyl, plot mean_wt vs. cyl
ggplot(mtcars_by_cyl, aes(x = cyl, y = mean_wt)) +
  # Add a bar layer with identity stat, filled skyblue
  geom_bar(stat = "identity", fill = "skyblue")

ggplot(mtcars_by_cyl, aes(x = cyl, y = mean_wt)) +
  # Swap geom_bar() for geom_col()
  geom_col(fill = "skyblue")

ggplot(mtcars_by_cyl, aes(x = cyl, y = mean_wt)) +
  # Set the width aesthetic to prop
  geom_col(fill = "skyblue", aes(width = prop))

ggplot(mtcars_by_cyl, aes(x = cyl, y = mean_wt)) +
  geom_col(aes(width = prop), fill = "skyblue") +
  # Add an errorbar layer
  geom_errorbar(
    # ... at mean weight plus or minus 1 std dev
    aes(ymin = mean_wt - sd_wt, ymax = mean_wt + sd_wt),
    # with width 0.1
    width = 0.1
  )


## Ex 05 (video)

## Ex 06
# Using barley, plot variety vs. year, filled by yield
ggplot(barley, aes(x = year, y = variety, fill = yield)) +
  # Add a tile geom
  geom_tile()

# Previously defined
ggplot(barley, aes(x = year, y = variety, fill = yield)) +
  geom_tile() +
  # Facet, wrapping by site, with 1 column
  facet_wrap(facets = vars(site), ncol = 1) +
  # Add a fill scale using an 2-color gradient
  scale_fill_gradient(low = "white", high = "red")

# A palette of 9 reds
red_brewer_palette <- brewer.pal(9, "Reds")

# Update the plot
ggplot(barley, aes(x = year, y = variety, fill = yield)) +
  geom_tile() +
  facet_wrap(facets = vars(site), ncol = 1) +
  # Update scale to use n-colors from red_brewer_palette
  scale_fill_gradientn(colors = red_brewer_palette)

## Ex 07 (quiz)

## Ex 08
# The heat map we want to replace
# Don't remove, it's here to help you!
ggplot(barley, aes(x = year, y = variety, fill = yield)) +
  geom_tile() +
  facet_wrap( ~ site, ncol = 1) +
  scale_fill_gradientn(colors = brewer.pal(9, "Reds"))

# Using barley, plot yield vs. year, colored and grouped by variety
ggplot(barley, aes(x = year, color = variety, group = variety, y = yield)) +
  # Add a line layer
  geom_line() +
  # Facet, wrapping by site, with 1 row
  facet_wrap( ~ site, nrow = 1)

# Using barely, plot yield vs. year, colored, grouped, and filled by site
ggplot(barley, aes(x = year, y = yield, color = site, group = site, fill = site)) +
  # Add a line summary stat aggregated by mean
  stat_summary(fun.y = mean, geom = "line") +
  # Add a ribbon summary stat with 10% opacity, no color
  stat_summary(fun.data = mean_sdl, fun.args = list(mult = 1), geom = "ribbon", alpha = 0.1, color = NA)


## Ex 09 (video)

## Ex 10 (quiz)

## Ex 11 (quiz)

## Ex 12
# Initial plot
growth_by_dose <- ggplot(TG, aes(dose, len, color = supp)) +
  stat_summary(fun.data = mean_sdl,
               fun.args = list(mult = 1),
               position = position_dodge(0.1)) +
  theme_classic()
# View plot
growth_by_dose

# Change type
TG$dose <- as.numeric(as.character(TG$dose))
# Plot
growth_by_dose <- ggplot(TG, aes(dose, len, color = supp)) +
  stat_summary(fun.data = mean_sdl,
               fun.args = list(mult = 1),
               position = position_dodge(0.2)) +
  theme_classic()
# View plot
growth_by_dose

# Change type
TG$dose <- as.numeric(as.character(TG$dose))
# Plot
growth_by_dose <- ggplot(TG, aes(dose, len, color = supp)) +
  stat_summary(fun.data = mean_sdl,
               fun.args = list(mult = 1),
               position = position_dodge(0.2)) +
  # Use the right geometry
  stat_summary(fun.y = mean,
               geom = "line",
               position = position_dodge(0.1)) +
  theme_classic()
# View plot
growth_by_dose

# Change type
TG$dose <- as.numeric(as.character(TG$dose))
# Plot
growth_by_dose <- ggplot(TG, aes(dose, len, color = supp)) +
  stat_summary(fun.data = mean_sdl,
               fun.args = list(mult = 1),
               position = position_dodge(0.2)) +
  stat_summary(fun.y = mean,
               geom = "line",
               position = position_dodge(0.1)) +
  theme_classic() +
  # Adjust labels and colors:
  labs(x = "Dose (mg/day)", y = "Odontoblasts length (mean, standard deviation)", color = "Supplement") +
  scale_color_brewer(palette = "Set1", labels = c("Orange juice", "Ascorbic acid")) +
  scale_y_continuous(limits = c(0,35), breaks = seq(0, 35, 5), expand = c(0,0))
# View plot
growth_by_dose


