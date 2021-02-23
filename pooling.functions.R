# FUNCTIONS FOR POOLING REGRESSION RESULTS # 

#required packages
library(dplyr)
library(mice)
library(psych)
library(rlist)  
library(miceadds)



# make implist from stacked data
        make.mids <- function(data, var.names, imp.id, participant.id, missing){
 
          # reading in different types of files
          if ( grepl("csv", data, fixed = TRUE)) {
            imps <- read.csv(data)
          } else if ( grepl("dat", data, fixed = TRUE)) {
            imps <- read.table(data)
            print(paste("Reading in", data, "file"))
          } else if ( grepl(".Rdata", data, fixed = TRUE)) {
            imps <- source(data)
            print(paste("Reading in", data, "file"))
          } else if ( grepl("txt", data, fixed = TRUE)) {
            imps <- read.delim(data)
            print(paste("Reading in", data, "file"))
            print( ".txt files must be tab delimited files where the character for decimal points is a period ")
          } else {
            writeLines("This function only accepts .csv ,  .dat , .Rdata , and .txt files.
        \nAll files must have imputations stacked with the original dataset at the beginning
        \n.txt files must be tab delimited files where the character for decimal points is a period ")
          }

        imps <- na_if(imps,missing)
        names(imps) <- var.names

        implist <- as.mids(imps, .imp = imp.id, .id = participant.id)
        return(implist)
    }

implist <- implist.mids

#pool descriptives from implist
    pool.descriptives <- function(implist,variables){

      descriptives <- with(implist, 
                           expr= describe(list.cbind((mget(variables))))
                          )
  
      pooled.desc <- withPool_MI(descriptives) # pooling untranformed
      varnames <- rownames(withPool_MI(descriptives))
      
      descriptives.analyses <- descriptives$analyses # (for sd and var pooling later)
      
      #sd descriptives transformations
      transformations <- sd_transform(descriptives.analyses)
      colnames(transformations) <- c("Untransformed", "Log-Transformed", "Sq.Rt-Transformed","Cube-Rt Transformed", "Inv.-Transformed")
      rownames(transformations) <- variables
      
      #variance descriptive transformations
      transformations2 <- var_transform(descriptives.analyses)
      colnames(transformations2) <- colnames(transformations)
      rownames(transformations2) <- variables

      #skewness descriptive transformations
      transformations3 <- skew_transform(descriptives.analyses)
      colnames(transformations3) <- colnames(transformations[,c(1,4,5)])
      rownames(transformations3) <- variables   
      
      #kurtosis descriptive transformations
      transformations4 <- kurt_transform(descriptives.analyses)
      colnames(transformations4) <- colnames(transformations[,c(1,4,5)])
      rownames(transformations4) <- variables      
      
            
      all.describe <- list(un.transform  = pooled.desc,
                           sd.transform  = transformations,
                           var.transform = transformations2,
                           skew.transform = transformations3,
                           kurt.transform = transformations4)

      
      return(all.describe)
      
}

# pool regression estimates from implist
    pool.regression <- function(implist, formula){

      # regression analysis
      fit <- with(implist,{
        lm(as.formula(formula))
      })
    
      # extract list of analysis results
      fit.analyses <- fit$analyses
    
      
      # pool coefficients
      coef <- summary(pool(fit.analyses))
      
      # pool regression analysis results for r, r2, sd, var
      impresults <- list()
      for (i in 1:length(fit.analyses)) {
        impresults[[i]] <- as.data.frame(cbind(r  = sqrt(summary(fit$analyses[[i]])$r.squared), # multiple correlation
                                               r2 = summary(fit$analyses[[i]])$r.squared, # multiple r2
                                               sd = summary(fit$analyses[[i]])$sigma, # residual std err
                                               var = (summary(fit$analyses[[i]])$sigma)^2 # residual var
        ))
      }
  
  # labeling transformatino results
      r <- r_transform(impresults)
        colnames(r) <- c("Untransformed", "Fisher's R-Z Transformation")
        rownames(r) <- c("Multiple Correlation Transformations")
        r <- t(r)
        
      r2 <- r2_transform(impresults)
        colnames(r2) <- c("Untransformed", "Fisher's R-Z Transformation", "Log-Transformed", "Sq.Rt-Transformed","Cube-Rt Transformed", "Inv.-Transformed")
        rownames(r2) <- c("Multiple R-Squared Transformations")
        r2 <- t(r2)
        
      sd <- sd_transform(impresults)
        colnames(sd) <- c("Untransformed", "Log-Transformed", "Sq.Rt-Transformed","Cube-Rt Transformed", "Inv.-Transformed")
        rownames(sd) <- c("Residual Standard Error Transformations")
        sd <- t(sd)
        
      var <- var_transform(impresults)
        colnames(var) <- c("Untransformed", "Log-Transformed", "Sq.Rt-Transformed","Cube-Rt Transformed", "Inv.-Transformed")
        rownames(var) <- c("Residual Variance Transformations")
        var <- t(var)
      
      all.regression <- list(coefficients      = coef,
                             multiple.r        = r,
                             multiple.r2       = r2,
                             residual.std.err  = sd,
                             residual.variance = var
                             )

}

# r transform (for multiple correlation)
    r_transform <- function(data){
  
  rfunc <- function(data){
    # data <- impresults[[1]]
    R <- data$r
    fisher <- ((1/2)*(log((1+R)/(1-R))))
    rinfo <- cbind(R,fisher)
    #return(R[2,1])
    return(rinfo)
  }
  
  rlist <- t(lapply(data, rfunc)) # lapply() instead of sapply()
  
  r_avg <- function(rlist){
    # r averages and backtransform
    ravgs <- withPool_MI(rlist)
    z <- ravgs[,2]
    ravgs[,2] <- (exp(2*z)-1)/(exp(2*z)+1)
    # names(ravgs) <- c("r", "rfisher")
    return(ravgs)
  }
  
  
  
  rs <- r_avg(rlist)
  return(rs)
  
}

# r2 transform (for multiple r2)
    r2_transform <- function(data){
  
  r2func <- function(data){
    # data <- impresults[[1]]
    r2 <- data$r2
    R <- sqrt(r2)
    fisherr2 <- ((1/2)*(log((1+R)/(1-R))))
    logr2 <- log(r2)
    sqrtr2 <- sqrt(r2)
    cuber2 <- r2^(1/3)
    invr2 <- 1/r2
    r2info <- cbind(r2, fisherr2,logr2, sqrtr2, cuber2, invr2)
    #return(R[2,1])
    return(r2info)
  }
  
  r2list <- t(lapply(data, r2func)) # lapply() instead of sapply()
  
  r2_avg <- function(r2list){
    # sd averages and backtransform
    r2avgs <- withPool_MI(r2list)
    zz <- r2avgs[,2]
    r2avgs[,2] <- ((exp(2*zz)-1)/(exp(2*zz)+1))^2
    r2avgs[,3] <- exp(r2avgs[,3])
    r2avgs[,4] <- r2avgs[,4]^2
    r2avgs[,5] <- r2avgs[,5]^3
    r2avgs[,6] <- 1/r2avgs[,6]
    # names(r2avgs) <- c("r2", "fisherr2",'logr2', "sqrtr2", "cuber2", "invr2")
    return(r2avgs)
  }
  
  r2s <- r2_avg(r2list)
  return(r2s)
  
}

# sd transform (for descriptive sd OR residual std. err)
    sd_transform <- function(data){
  
  sdfunc <- function(data){
    # data <- descriptives.analyses[[1]]
    sd <- data$sd
    logsd <- log(sd)
    sqrtsd <- sqrt(sd)
    cubesd <- sd^(1/3)
    invsd <- 1/sd
    sdinfo <- cbind(sd,logsd,sqrtsd,cubesd,invsd)
    return(sdinfo)
  }
  
  sdlist <- t(lapply(data, sdfunc)) # lapply() instead of sapply()
  
  sd_avg <- function(sdlist){
    # sd averages and backtransform
    sdavgs <- withPool_MI(sdlist)
    sdavgs[,2] <- exp(sdavgs[,2])
    sdavgs[,3] <- sdavgs[,3]^2
    sdavgs[,4] <- sdavgs[,4]^3
    sdavgs[,5] <- 1/sdavgs[,5] 
    # names(sdavgs) <- c("sd", "logsd", "sqrtsd", "cubesd", "invsd")
    # sdavgs <- sdavgs[1:length(sdavgs),]
    return(sdavgs)
  }
  
  sds <- sd_avg(sdlist)
  return(sds)
  
}

# var transform (for descriptive var OR residual var)
    var_transform <- function(data){
  
  varfunc <- function(data){
    # data <- impresults[[1]]
    var <- (data$sd)^2
    logv <- log(var)
    sqrtv <- sqrt(var)
    cubev <- var^(1/3)
    invv <- 1/var
    vinfo <- cbind(var,logv,sqrtv,cubev,invv)
    return(vinfo)
  }
  
  
  # vlist1 <- t(lapply(descriptives.analyses, varfunc))
  vlist <- t(lapply(data, varfunc)) # lapply() instead of sapply()
  
  varavg <- function(vlist){
    # var averages and backtransform
    varavgs <- withPool_MI(vlist)
    varavgs[,2] <- exp(varavgs[,2])
    varavgs[,3] <- varavgs[,3]^2
    varavgs[,4] <- varavgs[,4]^3
    varavgs[,5] <- 1/varavgs[,5] 
    # names(sdavgs) <- c("sd", "logsd", "sqrtsd", "cubesd", "invsd")
    # sdavgs <- sdavgs[1:length(sdavgs),]
    return(varavgs)
    
    
  }
  
  vars <- varavg(vlist)
  return(vars)
  
}

# skew transform (for descriptive var OR residual var)
    skew_transform <- function(data){
      
        # define cube root function for negative values
        cubert <- function(x) {sign(x) * abs(x)^(1/3)}   
      
      skewfunc <- function(data){
        # data <- impresults[[1]]
        skew <- data$skew
        cubesk <- cubert(skew)
        invsk <- 1/skew
        skinfo <- cbind(skew,cubesk,invsk)
        return(skinfo)
      }


      # vlist1 <- t(lapply(descriptives.analyses, varfunc))
      skewlist <- t(lapply(data, skewfunc)) # lapply() instead of sapply()
      
      skewavg <- function(skewlist){
        # var averages and backtransform
        skewavgs <- withPool_MI(skewlist)
        skewavgs[,2] <- skewavgs[,2]^3
        skewavgs[,3] <- 1/skewavgs[,3] 
        # names(sdavgs) <- c("sd", "logsd", "sqrtsd", "cubesd", "invsd")
        # sdavgs <- sdavgs[1:length(sdavgs),]
        return(skewavgs)
        
        
      }
      
      skew <- skewavg(skewlist)
      return(skew)
      
    }    

# kurtosis transform (for descriptive kurtosis)
    kurt_transform <- function(data){
      
      # define cube root function for negative values
      cubert <- function(x) {sign(x) * abs(x)^(1/3)}   
      
      kurtfunc <- function(data){
        # data <- impresults[[1]]
        kurt <- data$kurtosis
        cubek <- cubert(kurt)
        invk <- 1/kurt
        kinfo <- cbind(kurt,cubek,invk)
        return(kinfo)
      }
      
      
      # vlist1 <- t(lapply(descriptives.analyses, varfunc))
      kurtlist <- t(lapply(data, kurtfunc)) # lapply() instead of sapply()
      
      kurtavg <- function(kurtlist){
        # var averages and backtransform
        kurtavgs <- withPool_MI(kurtlist)
        kurtavgs[,2] <- kurtavgs[,2]^3
        kurtavgs[,3] <- 1/kurtavgs[,3] 
        # names(sdavgs) <- c("sd", "logsd", "sqrtsd", "cubesd", "invsd")
        # sdavgs <- sdavgs[1:length(sdavgs),]
        return(kurtavgs)
        
        
      }
      
      kurt <- kurtavg(kurtlist)
      return(kurt)
      
    }    
    