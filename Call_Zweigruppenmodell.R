library(rstan)

source("utils.R")

data_list_base <- list(
    N = nrow(dat_base), P = 2, D = 3, K = 5,
    W = select(dat_base, ns, ks, ls, zs) %>% as.matrix(), 
    Z = select(dat_base, AEs) %>% cbind(1, .) %>% as.matrix(), 
    Y = c()  # Your outcome vector
)

two_groups <- function(dlb, idx) {
    stopifnot(all(idx == 1 | idx == 2) && length(unique(idx)) == 2)
    idx_ord <- order(idx)
    dlb$N <- c(sum(idx == 1), sum(idx == 2))
    dlb$W <- dlb$W[idx_ord,]
    dlb$Z <- dlb$Z[idx_ord,]
    dlb$Y <- dlb$Y[idx_ord]
    dlb
}

data_list <- list(myid = two_groups(dlb = data_list_base, idx = myid))


ncores <- parallel::detectCores() - 1
nchains <- ncores
niter <- 4e4
ctlr  <- list(max_treedepth = 15)

mc <- stanc_builder(file = 'models/Zweigruppenmodell.stan')$model_code

est_time <- create_counter() ; est_time$start()
fit <- stan(model_code = mc, data = data_list$myid, 
                pars = c("gamma", "beta", "sigma", "gamma_diff", "beta_diff", "sigma_diff", "R2"), 
                cores = ncores, iter = niter, chains = nchains, , control = ctlr)
est_time$stop() ; est_time

# As teh calculation might take a while -- largely depending on your computer -- it is wise to 
# store the data for later analysis; just create a directory named cache and uncomment the 
# lines below.
# save(fit, file = 'cache/Zweigruppenmodell.rdata')
