data{
	int N;      //number of children
	int M;      //number of trip
	int ID_i[M];//id of forager/return
	real R[M];  //returns
	real L[M];  //length of trip
	real A[N];
	real tide[M];//height of tide
	}
parameters{
  vector [N] iota;
  real<lower=0> sigma_i;
  real<lower=0> alpha;
  real<lower=0> beta; //age effect
  real<lower=0> gamma; //age elasticity
  real xi; //exponent for length trip
  real tau;//coefficient of tide
	real<lower=0> sigma;
}
transformed parameters{
  vector [N] phi;
  vector [M] psi;
  for(i in 1:N) phi[i]  = exp (iota[i] * sigma_i) * ( 
                          (1-exp(-beta * A[i]  )) ^ gamma );
  for(i in 1:M) psi[i] =  L[i] ^ xi *
                          exp( tide[i] * tau);//height of tide
;

}
model{
  iota ~ normal(0,1);
  sigma_i ~ exponential(1);
  alpha ~ normal(0,1)T[0,];
  beta ~ lognormal(0, 1);
  gamma~ lognormal(1, 1);
  xi ~ normal(0, 1);
  tau ~ normal(0, 1);
  sigma ~ exponential(1);
  for ( i in 1:M ) {
         real m = log( alpha * phi[ID_i[i]] * psi[i]);
         R[i] ~ lognormal( m , sigma ); 
      }
}