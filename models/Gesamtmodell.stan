functions {
  #include "../includes/cond_logistic.stan"
  #include "../includes/Rsquared.stan"
}
data {
  int N; // Number of participants
  int P; // Number of predictors stage I ; = 2 ; Interc + CT
  int D; // Number of intermediate outcome levels; = 3 ; N/K | K/L | L/Z
  int K; // Number of predictors stage II; = 5 ; Interc + CT + N/K + K/L + L/Z
  
  vector[N] Y;   // outcome
  int W[N,D + 1];  // intermediate outcome 
  matrix[N, P] Z; // predictors stage I & II
}
parameters {
  matrix[P, D] gamma;
  vector[K] beta; 
  real<lower=0> sigma; 
}
transformed parameters {
  vector[N] yhat; 
  matrix[N, D] lambda;
  
  lambda = Z * gamma;
  yhat = append_col(Z, lambda) * beta;
}
model {
  beta ~ normal(0,5);
  to_vector(gamma) ~ normal(0, 5);
  
  for (i in 1:N) {
    if (Z[i, 2] > 0) {
      W[i,] ~ multinomial(cond_logistic(to_vector(inv_logit(lambda[i,])))); 
    } else {
      W[i, 1:D] ~ multinomial(cond_logistic(to_vector(inv_logit(lambda[i, 1:(D-1)])))); 
    }
  }
  
  Y ~ normal(yhat, sigma);
}
generated quantities {
  real R2; 
  R2 = Rsquared(Y, yhat);
}
