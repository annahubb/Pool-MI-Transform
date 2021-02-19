# Pool-MI-Ests
Example data and analysis scripts for transforming and pooling multiple imputation estimates for descriptives, correlation, and regression analyses using data from Montague, Enders, and Castro (2005).  

**Data Description**

The data used for this analysis is based on a sample of *N* = 74 adolescents who were previously identified as being at risk for developing emotional and behavioral disorders when in kindergarten and first grade. The data contains information about reading achievement in reading achievement and learning problems in primary school and reading achievement in secondary school. The missing data rate for reading achievement in primary school was 67.5\% while reading achievement in secondary school and learning problems in primary school had missing data rates of 16.\2% and 1.3\%, respectively. We will demonstrate the pooling process using the following moderation analysis 
**Analysis Description**

The analysis script `example script - reading data.R` contains code to obtain descriptive statistics and transform standard deviations and variances from the descriptives. Other analyses included are bivariate correlation analyses with the Fishers *R*-to-*z* transfomation. Finally the analysis script includes code to compute transformed/pooled imputation estimates for a simple moderated regression analysis where learning problems in primary school moderates the effect of primary school reading achievement on secondary school reading achievement. The moderation analysis is demonstrated with three different centering schemes: (1) when the focal predictor and moderator are both centered at their means; (2) when the focal prector is centered at its mean and the moderator is centered at 1 standard devation above the mean; (3) when the focal prector is centered at its mean and the moderator is centered at 1 standard devation below the mean. The regression equation is as follows:

*Variable-specific Notation:*

<img src="https://render.githubusercontent.com/render/math?math=READ2_i \= READ1_i %2B LRNPROB1_i %2B READ1_i\*LRNPROB1_i %2B \varepsilon">

*Generic Notation*

<img src="https://render.githubusercontent.com/render/math?math=Y_i \= X_i %2B W_i %2B X_i\*W_i %2B \varepsilon">



**File Descriptions**
- `create stacked impuations.imp` 
  + Blimp script used to create a stacked multiple imputations
  + Uses `reading.dat` to conduct the multiple imputations
  + Creates the file `reading.imps.dat` used in `example script - reading data.R`
  + Blimp is available for download at http://www.appliedmissingdata.com/multilevel-imputation.html

- `example script - reading data.R`
  + R script that transforms and pools estimates for descriptives, correlation, and regression analyses
  + Uses `reading.imps.dat` to conduct analyses
  + Requires `pooling.functions.R`

- `pooling.functions.R`
  + R script that contains pooling functions required by `example script - reading data.R`

- `reading.dat`
  + Raw data file used by `create stacked impuations.imp` 

- `reading.imps.dat`
  + Stacked imputations data file created by `create stacked impuations.imp` and used by `example script - reading data.R`


**References**

Montague, M., Enders, C., & Castro, M. (2005). Academic and Behavioral Outcomes for Students at Risk for Emotional and Behavioral Disorders. Behavioral Disorders, 31(1), 84-94. doi:10.1177/019874290503100106
