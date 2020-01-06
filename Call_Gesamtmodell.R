library(rstan)

source("utils.R")

data_list <- list(
    N = nrow(dat_base), P = 2, D = 3, K = 5,
    W = select(dat_base, ns, ks, ls, zs) %>% as.matrix(), 
    Z = select(dat_base, AEs) %>% cbind(1, .) %>% as.matrix(), 
    Y = c()  # Your outcome vector
)

ncores <- parallel::detectCores() - 1
nchains <- ncores
niter <- 4e4
ctlr  <- list(max_treedepth = 15)

mc <- stanc_builder(file = 'models/Gesamtmodell.stan')$model_code

est_time <- create_counter() ; est_time$start()
fit <- stan(model_code = mc, data = data_list, 
            pars = c("gamma", "beta", "sigma", "R2"), 
            cores = ncores, iter = niter, chains = nchains, , control = ctlr)
est_time$stop() ; est_time

# As teh calculation might take a while -- largely depending on your computer -- it is wise to 
# store the data for later analysis; just create a directory named cache and uncomment the 
# lines below.
# save(fit, file = 'cache/Gesamtmodell.rdata')
