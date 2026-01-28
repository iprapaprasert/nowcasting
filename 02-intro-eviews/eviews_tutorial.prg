'Make the working directory c:\temp
%path = @runpath
cd %path 

' 1. EViews Fundamental
'' Creating an EViews Workfile
''' Page 2: Create a workfile
wfcreate(wf=eviews_tutorial, page=usa_cy) q 1945q1 2022q4

'' 1.3 Creating an Empty Series
''' Page 7: Create an empty series called rc and show its spreadsheet view.
series rc 
show rc
close rc

'' 1.4 Saving a Workfile
''' Page 8: Save the workfile using double precision (option 2).
wfsave(2) "eviews_tutorial"
wfclose eviews_tutorial.wf1

'' 1.5 Creating a Workfile from a Foreign Data Source
''' Page 9: Import and Excel spreadsheet
import "usa_cy.xlsx" range=usa_cy colhead=2 namepos=firstatt na="#N/A" @freq Q @id @date(date) @smpl @all
wfsave(2) "eviews_tutorial"
wfclose "eviews_tutorial"

'' 1.6 Opening an Existing Workfile
''' Page 12: Opening an existing workfile...
wfopen "eviews_tutorial"

'' 1.7 Working with Series
''' Make use_cy the default pagefile.
pageselect usa_cy

''' Page 15: Show the content of the series rc in a spreadsheet view.
rdy.sheet

''' Page 16; Show two series (i.e., a group) in the spreadsheet view.
show rc rdy

'' 1.8 EViews Samples
''' Page 17: Adjust the active sample.
smpl 1947Q1 2000Q4
smpl @all

' 2. Creating New Series from Existing Series
'' 2.1 Using the Command Line to Initiate Calculation
''' Page 18: Create new series from existing series using the genr/series command.
series l_rc = log(rc)
series l_rdy = log(rdy)
series p_rc = @pc(rc)

''' Page 19: Some useful @ functions: seasonal dummies and a time trend.
show @seas(1) @seas(2) @seas(3) @trend

''' Page 22: Create a structural break dummy using smpl statements together with series/genr statements
series sb_1975_4 = @before("1976")

' 3. Descriptive Statistics
'' 3.1 Histogram and Stats
''' Page 23: Descriptive statistics: Histogram
freeze(rc_hist) rc.hist

'' 3.2 Stats by Classification
''' Page 24: Descriptive statistics: Stats by classification
freezr(rc_statby_rdy) rc.statby rdy

'' 3.3 Covariance Analysis
''' Page 25: Descriptive stattistics: Covariance analysis
'''' Create a group object called rc_rdy that contains rc and rdy 
group rc_rdy rc rdy

'''' Show the content of the group
show rc_rdy

'''' Calculate the covariance / correlation of the the 2 series.
smpl @first 2000q4
freeze(rc_rdy_cov) rc_rdy.cov(outfmt=single) cov corr

' 4. Graphical Representations
'' 1. Single Graph
''' Page 27: Plot rc and rdy on the same graph
line rc rdy

'' 2. Multiple Graphs 
''' Page 28: Plot the two series separately.
line(m) rc rdy

'' 3. Other Graph Types
''' Page 29: Display a scatter graph along with a trend line.
rc_rdy.scat(ab=histogram) linefit()

' 5. Estimating a Regression Line Using OLS
'' 5.1 Using the command line to create equation object
''' Page 30: Create a structural break variable for COVID 19 effects; equals 1 for the period 2020Q1-2021Q4, 0 otherwise.
smpl @all
series covid = @during("2020q1 2021q4")

''' Page 31: Estimate a least squares regression
equation cons_equation.ls log(rc) c log(rdy) log(rnw) log(rc(-1)) sb_1975_4 covid 
'' 5.2 Use Quick to Create Equation Object
''' Page 33: Estimate a HAC robust OLS
equation cons_equation_hac ls(cov=hac) log(rc) c log(rdy) log(rnw) log(rc(-1)) sb_1975_4 covid 

''' Page 33: Display the results
show cons_equation_hac
'' 5.3 Equation Objects: Saving, Labelling, Freezing, Printing
''' Page 34: Save the equation to the workfile as a equation object called 'cons_equation'
equation cons_equation.ls log(rc) c log(rdy) log(rnw) log(rc(-1)) sb_1975_4 covid

''' Page 35: Freeze the results
freeze(table_eq1) cons_equation

'' 5.5 View -> Representation
''' Page 38: View the algebraic representation of the estimated equation
freeze(cons_equation_representations) cons_equation.representations

''' Page 39: Show the coefficient estimates in the C vector (automatically updated after each regression) 
show c

'' 5.6 Hypothesis testing
''' Page 40: Hypothesis testing using the Wald Statistic
freeze(cons_equation_wald_1) cons_equation.wald c(3) = 0

''' Page 41: Hypothesis testing using the Wald Statistic: multiple contraints
freeze(cons_equation_wald_2)cons_equation.wald c(3) = 0, c(2) = 1

'' 5.7 Using the regression window
''' Make residual series
'''' Page 42: Create a residual vector
cons_equation.makeresids resid01

'''' Page 43: Display the residuals in a spreadsheet view.
resid01.sheet

''' Show actual, fitted, residual
'''' Page 43: Display a table of actuals, fitted, and residuals
freeze(cons_equation_resids_t) cons_equation.resids(t)

'''' Page 44: Display a graph of actuals, fitted and residuals
freeze(cons_equation_resids_g) cons_equation.resids(g)

'''' Page 45: Spreadsheet view of the data used to estimate the regression
cons_equation.makeregs

'''' Page 46: Freeze the regression results; will not change even if the data is changed.
freeze(mode=overwrite, cons_function) cons_equation

'' 5.8 Testing for Serial Correlation
''' Correlogram Q Statistics
'''' Page 47: Calculate the Q statistic for autocorrelation in the residuals (4 lags)
freeze(cons_equation_correl) cons_equation.correl(4)

''' Bruesch-Godfrey LM Test
'''' Page 48: Calculate the Bruesch-Godfrey LM test for autocorrelation (4 lags)
freeze(cons_equation_auto) cons_equation.auto(4)

'' 5.9 Out-of-sample Forecasting Experiment - Baseline Forecast
''' Forecast using model "Forecast" routine
'''' Page 49: Out-of-sample forecasting: notice that the sample has been cut back 3 observations for the purpose of forecast evaluation
smpl 1947q1 2020Q4

'''' Page 50: Reestimate the model over the restricted sample...
cons_equation.ls log(rc) c log(rdy) log(rnw) log(rc(-1)) sb_1975_4 covid

'''' Page 50: Now perform a dynamic forecast using the re-estimated regression
freeze(cons_equation_forecast) cons_equation.forecast(e, g, ga, forcsmpl="2021q1 2021q3") rc_forecast

'''' Page 53: Display the actual, and fitted values of real consumption for 2016Q1-2021Q3
smpl 2016Q1 2021Q3
plot rc rc_forecast

''' Forecast using model "Solver" routine
'''' Page 53: Make a model for the model simulator...
smpl 1945q1 2020Q4
cons_equation.ls log(rc) c log(rdy) log(rnw) log(rc(-1)) sb_1975_4 covid
cons_equation.makemodel(firstmod) @prefix s_
'''' Page 54: Solve the model (generate the baseline solution) over the forecast period
''''' Change the sample period to ensure that the simulation starts at 2000:1.  This is important for dynamic runs.
smpl 2021q1 2021q3 
''''' Solve the model over the active sample period
firstmod.solve

'''' Page 55: Display the actual, and fitted values of real consumption for 2016Q1-2021Q3
smpl 2016Q1 2021Q3
plot rc rc_forecast rc_0

'''' Page 56: Display the resulting forecastings, simulations
show rc rc_forecast rc_0

''' Out-of-sample Experiment: Alternative Scenario (10 Percent Increase in Volume)
'''' Page 57: Now generate an alternative scenario. 
series rnw_1 = @recode(@during("2021q1 2021q3"), rnw*1.1, rnw)
firstmod.scenario "Scenario 1"
firstmod.override rnw 'Tell the simulator to override rnw
firstmod.scenario "Baseline"
firstmod.scenario(c)  "Scenario 1" 'Set the comparison scenario to "scenario 1"
smpl 2021q1 2021q3
firstmod.solve(a=t) 'Resolve the model...
smpl 2018q1 2021q4
plot rc rc_forecast rc_0 rc_1
show rc rc_forecast rc_0 rc_1


