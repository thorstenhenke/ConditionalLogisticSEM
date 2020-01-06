vector cumulative_prod(vector p) {
	return exp(cumulative_sum(log(p))); 
}
vector to_simplex(vector v) {
	real s = sum(v); 
	return v / s; 
}
vector cond_logistic(vector phi) {
	int n = num_elements(phi); 
	vector[n + 1] mu;
	vector[n] cum_phi;

	cum_phi = cumulative_prod(1 - phi); 

	mu[1] = phi[1]; 
	for (i in 2:(n)) {
		mu[i] = phi[i] * cum_phi[i-1];
	}
	mu[n+1] = cum_phi[n]; 

	return to_simplex( mu ); 
}
