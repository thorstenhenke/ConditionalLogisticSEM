real Rsquared(vector y, vector yhat) {
  return 1 - (sum(crossprod(to_matrix(y - yhat)))/sum(crossprod(to_matrix(y - mean(y)))));
}
