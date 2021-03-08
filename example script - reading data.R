################################################################
##### INSTRUCTIONS TO RUN PROGRAM HERE
################################################################
    # This program pools multiple imputation results from descriptive analyses, bivariate correlation analyses, and single-level linear regression analyses.
    # This program is only able to read in multiply imputed data from .csv , .dat , .Rdata , .txt tab delimited files where the multiply imputed dataset is in a stacked format where the unimputed data is at the top of the dataset.
    # This program also requires the pooling.function.R and the data file to be in the same folder/file location as this program
    # A 'mids' object (multiply-imputed-data-set) object is created when reading in the stacked data, that is used throughout the file. A user of the MICE package may already have the required object, named 'implist.mids' created

################################################################
##### USER INPUTS HERE 
################################################################
# data file name could be .dat, .csv, .Rdata, .txt
# data file must be in a stacked file with un-imputed data at the top
# input data cannot contain column headers/variable names
    data  <- "reading.imps.dat"
    
# write the variable names here in the order they appear in the original file
    # must include names for ALL columns in data file 
    var.names <- c("imp","read1", "lrnprob1", "read2")
    
# write the indicator for the imputation number; must match variable name from 'var.names'
    imp.id <- "imp"
    
# write the indicator for the case/participant number here; must match variable name from 'var.names'
    # if there is not indicator variable for case/participant, use NA
    participant.id <- NA
    
# write the indicator for missing values here
    missing <- 999
    
# if computing/pooling descriptive statistics, write variables of interest here; must match variable names from 'var.names'
    variables <- c("read1", "lrnprob1", "read2")   

# if computing/pooling regression results, 
    # write linear model here in the format 'outcome ~ predictor1 + predictor2 + ... + predictorK'; 
    # must match variable names from 'var.names'
    my.lm <- "read2 ~ read1 lrnprob1 read1*lrnprob1"

################################################################
##### SET WORKING DIRECTORY, LOAD FUNCTIONS, REQUIRED PACKAGES 
################################################################
# R studio function that defines the working directory as where the current file is saved
# No modification required here
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
    
# R function that defines the working directory to specific location; modify as needed
# setwd("insert working directory file path here")
    
# check working directory here    
getwd()

# install required packages here; un-comment next line if needed
# install.packages(c("dplyr", "mice", "psych", "rlist", "miceadds, metaSEM"))

# load functions and required packages; no modification required here
# pooling.function.R file must be in same location as working directory
source(paste0(getwd(),"/pooling.functions.R"))

################################################################
##### THIS SECTION CREATS IMPLIST REQUIRED FOR ALL ANALYSES
################################################################
# make implist.mids from stacked data; no modification required here
# user can also create implist.mids using a mids object from mice
implist.mids <- make.mids(data = data,
                      var.names = var.names,
                      imp.id = imp.id,
                      participant.id = participant.id,
                      missing = missing
)


################################################################
##### THIS SECTION POOLS DESCRIPTIVE STATISTICS
################################################################
# pool descriptives; no modification required here
descriptives <- pool.descriptives(implist = implist.mids,
                                  variables = variables)

#print pooled descriptive statistics
descriptives

################################################################
##### THIS SECTION POOLS CORRELATIONS
################################################################
# pool correlations requires these packages
library(miceadds)
library(metaSEM)
  # use functions to pool correlation, no modification required here
  cor <- micombine.cor(mi.res=implist.mids, variables=variables)
  r_matrix   <- attr(cor, "r_matrix")
  fisher_r <- vec2symMat(cor$fisher_r[1:(length(cor$r)/2)], diag = FALSE, byrow = FALSE) ; rownames(fisher_r) <- colnames(fisher_r) <- variables
  
  # print un-transformed correlation matrix  
  r_matrix
  
  # print fisher's transformed correlation matrix
  fisher_r
  
################################################################
##### THIS SECTION CENTERS VARIABLES FOR REGRESSION ANALYSES
################################################################
# if analyses do not require centering, this section isn't necessary and can be skipped

# creating centered variables for regression/moderation analysis
  # this converts the mids.object back to long format so centering can be done
  # no modification required here
  stacked.dat <- complete(implist.mids, action='long', include=TRUE)
  
  # specify focal predictor (x) here; must be in quotations
  x <- "read1"
  
  # specify moderator (w) here; must be in quotations
  w <- "lrnprob1"
  
  # this generates centered variables
    # centering focal predictor and moderator at the mean
    # this creates new variables that is centered at the mean with "_mu" appended at the end of the variable name
    # no modification required here
    stacked.dat[paste0(x,"_mu")]     <- stacked.dat[x] - descriptives$un.transform[x,"mean"]
    stacked.dat[paste0(w,"_mu")]     <- stacked.dat[w] - descriptives$un.transform[w,"mean"]
  
    # centering moderator at 1 SD above/below the mean
    # this creates new variables that is centered at the mean with "_hi" and "_low" appended at the end of the variable name
    # no modification required here
    stacked.dat[paste0(w,"_hi")]  <- stacked.dat[w] - ( descriptives$un.transform[w,"mean"] + descriptives$sd.transform[w,"Inv.-Transformed"] )
    stacked.dat[paste0(w,"_low")] <- stacked.dat[w] - ( descriptives$un.transform[w,"mean"] - descriptives$sd.transform[w,"Inv.-Transformed"] )
    
    
  # converting long format back to mids object to do regression/moderation analysis
  # no modification required here
  implist.mids <- as.mids(stacked.dat)
  
################################################################
##### THIS SECTION POOLS REGRESSION RESULTS
################################################################
    
# defining three moderation analyses with different centering methods
  # centering focal predictor and moderator at the mean
  # use variables created from centering above
  
  # moderation analysis where focal predictor and moderator are centered at the mean
  # modify equation as needed
  lm <- 'read2 ~ read1_mu + lrnprob1_mu + read1_mu*lrnprob1_mu'
  
  # moderation analysis where focal predictor and moderator are centered at 1 SD above the mean
  # modify equation as needed
  lm_hi <- 'read2 ~ read1_mu + lrnprob1_hi + read1_mu*lrnprob1_hi'
  
  # moderation analysis where focal predictor and moderator are centered at 1 SD below the mean
  # modify equation as needed
  lm3_low <- 'read2 ~ read1_mu + lrnprob1_low + read1_mu*lrnprob1_low'
  
    
# use function to pool regression results, no modification required here
  reg <- pool.regression(implist.mids,lm)
  reg_hi <- pool.regression(implist.mids,lm_hi)
  reg_low <- pool.regression(implist.mids,lm3_low)
  
  # print regression results
  reg
  reg_hi
  reg_low 
 