# Workshop on Test Construction with R
# Würzburg 2021, Wolfgang Lenhard, wolfgang.lenhard@uni-wuerzburg.de
# Data taken from the pilotation sample of ELFE II reading comprehension test
# (W. Lenhard, Lenhard & Schneider, 2017)


# STEP 1: INSTALLATION OF NECESSARY LIBRARIES
#         (might take a minute or two)
install.packages(c("psych", "difR", "TAM", "eRm", "cNORM", "lavaan", "semTools", "openxlsx"), dependencies = TRUE)

# or: Update existing packages
update.packages(checkBuilt=TRUE, ask=FALSE)





# STEP 2: READ IN DATA
#         here we use an R data object; creates object 'elfeText' in environment
#         adjust path, if necessary or use the open function in RStudio above the
#         environment tab
load("data.RData")

###########################################################################################
# alternative: in case you want to read in SPSS, Excel, CSV ... please use the import tab
# nonetheless, here the script:
# library(haven)
# elfeText <- read_sav("ELFE2PilotierungText.sav") # please adjust path
# elfeText <- as.data.frame(as.matrix(elfeText))   # get rid of the attributes
###########################################################################################

# to get the list of variables with index number ...
View(as.data.frame(colnames(elfeText)))

# check for NA
anyNA(elfeText)    # returns FALSE, so no missing data found                                  

str(elfeText)      # display structure of data table
                   # ATTENTION, in case of errors when loading data, often variables
                   # are represented as Strings and interpreted as factors
                   # This produces errors in later analysis. Check structure via
                   # 'str' to avoid strange errors and warnings later on.

# generate a data frame based only on the item data (column 7 to 37 from the original file)
data <- elfeText[,7:37]     # we only need the accuracy raw data of each item
View(data)                  # open data viewer


# YOUR TURN: Basic data handling in R
# - define a variable
# - define a vector with numeric values
# - compute m and sd of the numeric vector
# - generate a data.frame object with your numeric vector as one col and a second col with 
#   fictitious participiant names
# - display the third col of the example dataset
# - display the value of the 'example' dataset in the 3rd col and 5th row
# - delete col 1 / variable 'col1' of the example dataset



# STEP 3: BASIC DESCRIPTIVE STATISTICS
# We use the psych-package for this
library(psych)
describe(data)
describeBy(data, group=elfeText$Sex)

# some plotting, correlations ... of means between boys and girls
descriptives <- describeBy(data, group=elfeText$Sex)

# R offers so many plotting functions, that you can get completely lost in it
plot(descriptives[[1]]$mean, descriptives[[2]]$mean)

# Sidenote: to add a regression line via linear regression:
abline(lm(descriptives[[2]]$mean ~ descriptives[[1]]$mean),col="red",lwd=1.5, lty=2)

# function calls can be embedded into other function calls; here plot of mean versus sd
plot(describe(data)$mean, describe(data)$sd)

# Sidenote: you can fit polynomial regression and confidence intervals as well (but better use 'ggplot2' for this)


cor(descriptives[[1]]$mean, descriptives[[2]]$mean) # correlation of item difficulties in
                                                    # boys and girls
                                                    

# YOUR TURN:
# a. Get an overview on the distribution of means and standard deviations. Which range would
#    you expect?
# b. How do mean and sd relate?
# c. Which items should be most diagnostic? Do you already see problematic items? Look out for
#    items m < .4 and m >.9





# STEP 4: HOMOGENEITY AND DISCRIMINATION 
#         Analysis of item discrimination, alpha and omega (as well psych)
library(psych)
alpha <- alpha(data)
alpha$total                           # scale information
alpha$item.stats                      # item information; discrimination is listed in column r.drop

# visualization makes everything easier:
plot(alpha$item.stats$r.drop)         # plot discrimination scores
grid(NA, 6)                           # add some horizontal lines to the plot

# back to alpha
alpha$alpha.drop                      # scale information if item is excluded
print(alpha$item.stats, digits = 2)   # in case, you need less or more digits

# YOUR TURN:
# a. Which items have the best discrimination?
#    Hint: Use plot function
# b. Which items should be excluded? (In any case negative values and by convention values < .3)
# c. Generate new data.frame without problematic items and rerun the analyses. You can use the
#    syntax data2 <- data[, -c(colX, colY, colZ)]
#
#    Or directly:
#    print(alpha(data[, -c(x1, x2, x3, x4 ...)]), digits =4) with x indicating the index of
#                                                           problematic items


# Alpha measure is not optimal, however. Let's repeat it with omega and split-half.
# Further information: McNeish, D. (2017). Thanks coefficient alpha, we’ll take it from here.
#                               Psychological Methods. https://doi.org/10.1037/met0000144
omega <- omega(data)      # ATTENTION! data2 HAS TO BE CREATED BEFORE!
omega$omega.tot           # omega total gives you an unbiased homogeneity indicator
splitHalf(data)           # alternatively: split-half measures
glb(data)                 # 'greatest lowest bound' as the probably most robust homogeneity indicator




# STEP 5: UNIDIMENSIONALITY ASSUMPTION (again using psych)
#         We will try a test on dimensionality by Factor analysis
#         Look out for low communalities
library(psych)
FA <- fa(data)         # carry out factor analysis
print(FA)
unidim(data)           # experimental feature; indices on unidimensionality
plot(FA$communalities) # plot communalities
fa.diagram(FA)         # print factor loadings
fa.parallel(data)      # Velicer's Minimum Average Partial- (MAP-) Test and Scree plot
                       # alternative: Simple Scree plot; Cattell's test on one dimensionality
                       # with scree(data); we will later use CFA for the same purpose.

# YOUR TURN: Which items do not fit in? Look out for low communalities (h2) and items, that
#            do not fit in the structure





# STEP 6: ITEM RESPONSE THEORY
#         Set up the model and inspect descriptives
#         We will use the TAM package; further information:
#         http://www.edmeasurementsurveys.com/TAM/Tutorials/
library(TAM)
mod.tam <- tam(data)                       # 1 parameter logistic (= Rasch) model

# First: Focus on item characteristics
mod.tam$xsi                                # print item parameters 
hist(mod.tam$xsi$xsi)                      # plot distribution of difficulties
plot(mod.tam$xsi$xsi, describe(data)$mean) # relation between difficulty and theta
plot(mod.tam$xsi$xsi, mod.tam$xsi$se.xsi)  # Confidence: plot SE against theta

# Second: Have a look at the persons; estimate abilities
Abil <- tam.wle(mod.tam)
PersonAbility <- Abil$theta
hist(PersonAbility)

#Descriptive statistics on item parameters and person abilities
describe(mod.tam$xsi$xsi)
describe(PersonAbility)

# plot PersonAbilities by raw score (with CI lines)
plot(elfeText$TextScore, PersonAbility, main = "Raw Score vs. WLE with 95% CI")
lines(elfeText$TextScore, PersonAbility - Abil$error*1.96, lty = 'dashed', col = 'red')
lines(elfeText$TextScore, PersonAbility + Abil$error*1.96, lty = 'dashed', col = 'red')


# Just for fun: 2PL (= Birnbaum) model
# Alternative: ltm packages (see https://wnarifin.github.io/simpler/irt_2PL.html)
mod.tam2PL <- tam.mml.2pl(data)
mod.tam2PL$item              
summary(mod.tam2PL)          # 2PL: item difficulties (A) and slopes (B)
                             # YOUR TURN: Which items have a low slope?
                             # Visually inspect ICCs with plot(mod.tam2PL)






# STEP 7: IRT MODEL FIT
#         Identify poorly fitting items via ICCs and fit statistics plot model
library(TAM)
plot(mod.tam)                 # ICC of the 1PL model
plot(mod.tam2PL)              # ICC of the 2PL model

# Calculate fit indices; infit is inlier and outfit outlier sensitive
summary(tam.fit( mod.tam ))

# Infit and outfit values are best between 0.75 and 1.25. Lower values that .75 indicate
# items with a higher diagnostic value than expected / a model overfit
# Values above 1.25 have poor diagnostic information

# YOUR TURN: Search for infit values deviating from expectancy; especially look out for items
#            with an infit above 1.25 or Infit_p < .05 with an Infit > 1


# STEP 8: TEST MODEL ASSUMPTIONS AND DIFFERENTIAL ITEM FUNCTIONING
#         Do patterns differ between subgroups?
#         Is the test equally fair for e. g. boys and girls, ethnicities ...?
#         For this, we need the total score of the test and the grouping variable
#         from ELFENorm2 and we use the eRm package
#         Online-Tutorial: https://de.wikibooks.org/wiki/GNU_R:_Rasch-Modelle
library(eRm)
mod2<-RM(data)

# some commands comparable to TAM
summary(mod2)                 # results of modeling
plotjointICC(mod2)            # ICC
plotPImap(mod2, sorted=TRUE)  # plot person item map

pp <- person.parameter(mod2)  # estimate person parameters
plot(pp)                      # plot person parameters against raw scores
itemfit(pp)                   # Infit here is 'Infit MSQ'
plotPWmap(mod2)               # plot infit t statistics
personfit(pp)                 # we can check for unfitting persons as well

# conditional likelihood quotient test and graphical model test
lrt1<-LRtest(mod2, splitcr=elfeText$Sex)              # test on specific objectivity based on sex variable
                                                      # leaving splitcr empty does median split

print(lrt1)                                           # Check if test fulfills the Rasch model
plotGOF(lrt1, conf=list(), ylab="Girls", xlab="Boys") # graphical test with 2dimensinal CI ellipses
Waldtest(mod2, splitcr=elfeText$Sex)                  # test of Rasch assumptions on item level

# YOUR TURN: Find items, that significantly deviate from the model assumptions and might be unfair
#            for one group. Please search in the plot and afterwards look at the Wald test results


# We will try a 2nd approach and search for DIF via logistic regression with the difR package
library(difR)
dif <- difLogistic(data, group = elfeText$Sex, 
                   focal.name = "male")               # searches for unfiform and 
                                                      # non-uniform DIF
dif                                                   # show results
plot(dif)                                             # plot distribution of items
plot(dif, plot="itemCurve", item = 18)                # display ICC of specific item

# YOUR TURN: Find items, with DIF and plot them. Do the same problematic items show up,
#            compared to the Waldtest?



# What other tests are possible? Let's have a look at local independence, multidimsionality, learning ...
# Again we use eRM, but we have to do a simulation of data distributions first, thus 'rsampler'
# The following tests are non-parametric. Object contain $prop vector with probabilities.
dataX <- as.matrix(data)	# the simulation needs data in form of a matrix
rmat <- rsampler(dataX) # we simulate 100 matrices

q3h <- NPtest(rmat, method = "Q3h") # Checks for local dependence via increased inter-item residuals
print(q3h, alpha = 0.01)

t11 <- NPtest(rmat, method = "T11") # Global test for local dependence
print(t11, alpha = 0.01)

t1m <- NPtest(rmat, method = "T1m") # Check on multidimsionality
print(t1m, alpha = 0.01)

t1l <- NPtest(rmat, method = "T1l") # Check on learning
print(t1l, alpha = 0.01)

# tloef <- NPtest(rmat, n = 100, method = "MLoef") # exact Martin-Löf test; skipped due computational effort
# print(tloef, alpha = 0.01)

# ... and many others ...
# YOUR TURN: Run the tests. How does the scale perform?



# STEP 9: SET UP NORM SCORES
#          Compute grade specific norm scores and continuous norms with:
#
#                 _   _  ___  ____  __  __ 
#             ___| \ | |/ _ \|  _ \|  \/  |
#            / __|  \| | | | | |_) | |\/| |
#           | (__| |\  | |_| |  _ <| |  | |
#            \___|_| \_|\___/|_| \_\_|  |_|
#
#
# Tutorial available via:        https://www.psychometrica.de/cNorm.html
# Online demonstration with GUI; https://cnorm.shinyapps.io/cNORM/

library(cNORM)

# in case, you would rather have a GUI:
cNORM.GUI()

# get manifest norm scores per grade; we will take the build in elfe demo dataset
data.elfe <- cNORM::elfe    # we make a copy of the data
View(data.elfe)             # let's have a look at it
percentile <- rankByGroup(data = data.elfe, 
                          raw = data.elfe$raw, 
                          group = data.elfe$group)   # To get the manifest percentiles and norm scores
                                                     # for the complete sample

# regression-based norming model, including age / grade as a covariate
# you can vary the number of terms in the model with 'terms' and the power parameter via 'k'
# reduce 'k' in case of overfit
cnorm.model <- cnorm(raw = data.elfe$raw, group=data.elfe$group)
plot(cnorm.model, "norm")                         # plot fitted and manifest norm scores
plot(cnorm.model, "raw", group="group")           # plot fitted and manifest raw scores per group
plot(cnorm.model, "subset")                       # information criteria on possible models
plot(cnorm.model, "series", start = 2, end = 10)  # visualisation of different solutions


# generate norm table (norm score -> raw), save them as external file
normTable(A = 3.75, cnorm.model, minNorm = 25, maxNorm = 75)
norm.table <- normTable(A = c(4.00, 4.25, 4.50, 4.75), cnorm.model, minNorm = 25, maxNorm = 75, reliability = .96)
norm.table
library(openxlsx) # export to Excel
write.xlsx(norm.table, file = "normTables.xlsx")

# generate raw score table (raw -> norm)
raw.table <- rawTable(A = c(4.00, 4.25, 4.50, 4.75), cnorm.model, reliability = .96)
raw.table

# YOUR TURN: Use the CDC dataset with BMI data from the US and select a good fitting model
#            Dataset: cNORM::bmi with group = CDC$group and raw = CDC$bmi
#            Which parameters k and terms would you opt for?



# The hard stuff:
# STEP 10: CONFIRMATORY FACTOR ANALYSIS AND MEASUREMENT INVARIANCE ACROSS GROUPS
#         To which extend is the scale comparable between groups?
#         Can be applied to single scales, but more interesting for test with several scales,
#         testing mode effects ...
#         Tutorial: https://lavaan.ugent.be/tutorial/index.html for SEM
#         Measurement Invariance with Multi Group CFA (MGCFA)
library(lavaan)
data3 <- data
data3$Sex <- elfeText$Sex

data3$parcel1 <- data3$Item01 + data3$Item06 + data3$Item11 +  data3$Item16 + data3$Item21 + data3$Item26 + data3$Item31
data3$parcel2 <- data3$Item02 + data3$Item07 + data3$Item12 +  data3$Item17 + data3$Item22 + data3$Item27
data3$parcel3 <- data3$Item03 + data3$Item08 + data3$Item13 +  data3$Item18 + data3$Item23 + data3$Item28
data3$parcel4 <- data3$Item04 + data3$Item09 + data3$Item14 +  data3$Item19 + data3$Item24 + data3$Item29
data3$parcel5 <- data3$Item05 + data3$Item10 + data3$Item15 +  data3$Item20 + data3$Item25 + data3$Item30


mod3 <- 'text =~ parcel1 + parcel2 + parcel3 + parcel 4 + parcel5'

model.fit3 <- cfa(mod3, data=data3, meanstructure=TRUE, estimator="MLR")
summary(model.fit3, fit.measures=TRUE, standardized=TRUE)
# Again testing model assumptions: Does a one dimensional model have an acceptable fit?
# YOUR TURN: Look out for SRMR and RMSEA (both should be below .08) and CFI (should be higher than .91).
#            Does the model fit the data sufficiently well?

# Finally measurement invariance
library(semTools)
measurementInvariance(model = mod3, data = data3, group = "Sex", estimator = "MLR", strict = TRUE)

# Have a look at the delta CFI statistic; according to Cheung & Rensvold, successively watch
# out for delt.cfi >= .01 and stop there. Which kind of measurement variance does elfe reach?


