# Pool-MI-Ests
Example data and analysis scripts for transforming and pooling multiple imputation estimates

**File Descriptions**
- `create stacked impuations.imp` 
  + Blimp script used to create a stacked multiple imputations
  + Uses `reading.dat` to conduct the multiple imputations
  + Creates the file `reading.imps.dat` used in `example script - reading data.R`
  + Blimp is available for download at http://www.appliedmissingdata.com/multilevel-imputation.html

- `example script - reading data.R`
  + R script that transforms and pools estimates from descriptives, correlation, and regression analyses
  + Uses `reading.imps.dat` to conduct analyses
  + Requires `pooling.functions.R`

- `pooling.functions.R`
  + R script that contains pooling functions required by `example script - reading data.R`

- `reading.dat`
  + Raw data file used by `create stacked impuations.imp` 

- `reading.imps.dat`
  + Stacked imputations data file created by `create stacked impuations.imp` and used by `example script - reading data.R`
