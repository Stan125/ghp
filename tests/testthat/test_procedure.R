##### This script tests for the correct use of ghp #####

## Libraries
library(ghp)
library(tibble)
library(gridExtra)
library(ggplot2)

## Remove everything
rm(list = ls())

## Data
india <- ghp::india

### --- 1. Transforming the data --- ###

# Without grouped df
data_ungrouped <- indep_tf("stunting", india, group_df = NULL)
expl_ungrouped <- data_ungrouped$indep
expect_type(expl_ungrouped, "list")
expect_equal(length(expl_ungrouped), 7)

# With grouped df
groupings <- tibble(varnames = colnames(india),
                    groups = c("0", "child", "child", "mother",
                               "child", "mother", "mother", "mother"))
data_grouped <- indep_tf("stunting", india, group_df = groupings)
expl_grouped <- data_grouped$indep
expect_type(expl_grouped, "list")
expect_equal(length(expl_grouped), 2)

### --- 2. Fitting the models --- ###

# Create a function just for testing all combinations and returning mfits
test_m_creation <- function(data, method, npar) {
  mfits <- mfit(data, method, npar)
  expect_equal(length(mfits), 5) # test for the four components
  expect_equal(length(mfits$models$mu), length(mfits$model_ids)) # length of ids should equal length of models
  if (npar == 1) {
    expect_equal(length(mfits$models), 1) # should only have mu
  } else if (npar == 2) {
    expect_equal(length(mfits$models), 2) # mu and sigma should be modeled
    expect_equal(length(mfits$models$mu), length(mfits$models$sigma)) # should have same number of models for each parameter
  }
  return(mfits)
}

# Key: models_method_grouped_npar
# Ungrouped
m_lm_ug_1 <- test_m_creation(data_ungrouped, method = "lm", npar = 1)
m_gs_ug_1 <- test_m_creation(data_ungrouped, method = "gamlss", npar = 1)
m_gs_ug_2 <- test_m_creation(data_ungrouped, method = "gamlss", npar = 2)

# Grouped
m_lm_g_1 <- test_m_creation(data_grouped, method = "lm", npar = 1)
m_gs_g_1 <- test_m_creation(data_grouped, method = "gamlss", npar = 1)
m_gs_g_2 <- test_m_creation(data_grouped, method = "gamlss", npar = 2)

# Remove function
rm(test_m_creation)

### --- 3. Obtaining GOF's --- ###

# Test function
gof_test <- function(mfits) {
  if (mfits$method == "lm") {
    # No errors should be here
    for (i in c("AIC", "r.squared", "loglik", "deviance"))
      gofs <- gof(mfits, i)

    # There should be an error here
    expect_error(gof(mfits, "BIC"))

    # Class should be "goodfit"
    expect_s3_class(gofs, "goodfit")

    # Should be of length 6
    expect_equal(length(gofs), 6)

    # Should only have one parameter modeled
    expect_equal(length(gofs$gofs), 1)

    # Return gofs
    return(gofs)
  } else if (mfits$method == "gamlss") {
    # No errors should be here
    for (i in c("AIC", "deviance"))
      gofs <- gof(mfits, i)

    # There should be an error here
    expect_error(gof(mfits, "BIC"))

    # Class should be "goodfit"
    expect_s3_class(gofs, "goodfit")

    # Should be of length 6
    expect_equal(length(gofs), 6)

    # Should have two param modeled if npar = 2
    expect_equal(mfits$npar, length(gofs$gofs))

    # Remove gofs
    return(gofs)
  }
}

# All tests
all_gofs_list <- list()
for (mfit in ls()[grepl("m_", ls())])
  all_gofs_list[[mfit]] <- gof_test(get(mfit))

# Remove objects
rm(list = ls()[grepl("m_", ls())])

### --- 4. Partitioning --- ###

# Function for part testing
test_part <- function(gofs_list) {

  # Partitioning, hell yeah
  parts <- part(gofs_list)

  # Right class
  expect_s3_class(parts, "part")

  # Right size of object
  expect_equal(length(parts), 4)

  # If npar == 2 then df has to be longer
  if (parts$npar == 1)
    expect_equal(length(gofs_list$expl_names), length(parts$results$var))
  if (parts$npar == 2)
    expect_equal(length(gofs_list$expl_names) * 2, length(parts$results$var))

  # Return object
  return(parts)
}

# Test all goodfit objects
parts <- lapply(all_gofs_list, FUN = test_part)

### --- 4. Plotting --- ###
plots <- lapply(parts, plot_ghp)
expect_error(ggsave(filename = "plots_ghp.pdf",
                    grid.arrange(grobs = plots)), regexp = NA)
file.remove("plots_ghp.pdf")
