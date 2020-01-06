functions {
  #include "../includes/cond_logistic.stan"
  #include "../includes/Rsquared.stan"
}
data {
  int N[2]; // Number of participants per Group
  int P; // Number of predictors stage I ; = 2 ; Interc + CT
  int D; // Number of intermediate outcome levels; = 3 ; N/K | K/L | L/Z
  int K; // Number of predictors stage II; = 5 ; Interc + CT + N/K + K/L + L/Z
  
  vector[sum(N)] Y;     // outcome
  int W[sum(N), D + 1]; // intermediate outcome 
  matrix[sum(N), P] Z;  // predictors stage I & II
}
transformed data {
  int row_s[2];
  int row_e[2];
  
  row_s[1] = 1; 
  row_s[2] = N[1] + 1; 
  row_e[1] = N[1]; 
  row_e[2] = sum(N); 
}
parameters {
  matrix[P, D] gamma[2];
  vector[K] beta[2]; 
  real<lower=0> sigma[2]; 
}
transformed parameters {
  vector[sum(N)] yhat; 
  matrix[sum(N), D] lambda;
  
  matrix[P, D] gamma_diff;
  vector[K] beta_diff; 
  real sigma_diff; 
  
  for (g in 1:2) {
    lambda[row_s[g]:row_e[g],] = Z[row_s[g]:row_e[g],] * gamma[g];
    yhat[row_s[g]:row_e[g]] = append_col(Z[row_s[g]:row_e[g],], lambda[row_s[g]:row_e[g],]) * beta[g];
  }
  gamma_diff = gamma[1] - gamma[2]; 
  beta_diff = beta[1] - beta[2];
  sigma_diff = sigma[1] - sigma[2];
}
model {
  int pos; 
  
  for (g in 1:2) {
    beta[g] ~ normal(0,5);
    to_vector(gamma[g]) ~ normal(0, 5);
  }
  
  for (i in 1:sum(N)) {
    if (Z[i, 2] > 0) {
      W[i,] ~ multinomial(cond_logistic(to_vector(inv_logit(lambda[i,])))); 
    } else {
      W[i, 1:D] ~ multinomial(cond_logistic(to_vector(inv_logit(lambda[i, 1:(D-1)])))); 
    }
  }

  pos = 1; 
  for (g in 1:2) {
    segment(Y, pos, N[g]) ~ normal(yhat[row_s[g]:row_e[g]], sigma[g]);
    pos = pos + N[g];
  }
}
generated quantities {
  real R2; 
  R2 = Rsquared(Y, yhat);
}
