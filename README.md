# Sparse Portfolio Selection via Bayesian Multiple Testing

All codes of the paper titled "<b>Sparse Portfolio Selection via Multiple Testing</b>" are available here. This is a joint project of Sourish Das and Rituparna Sen. The paper is being accepted in <b>Sankhya - B</b>. The preprint of the paper can be found here: <a href='https://arxiv.org/abs/1705.01407'>Preprint</a> 

Soon we will upload all the R codes of this paper.

### Hierarchical Bayes with Horse Shoe Prior model for Portfolio Selection and Back testing 
1) <b>Factor_Model_HB_selection.R</b> file contain a function named '<i>Factor_Model_HB_selection</i>'. It implement the Gibbs sampling for &beta; and Metropolis update for scale parameters &sigma;<sub>c</sub> and &Sigma; with Horse Shoe prior on shrinkage parameter. The function uses parallel processing to simulate stock specific &beta; and &sigma; using <b>snowfall</b> R-package. The function uses three R-packages: (1) snowfall, (2) mvtnorm and (3) MCMCpack

2) <b>Factor_Model_HB_Back_testing.R</b> file contain a function named '<i>Factor_Model_HB_Back_testing</i>'. 

3) <b>simulate_theta_sigma.R</b> file contain a function named '<i>simulate_theta_sigma</i>'. The function is called in  <i>Factor_Model_HB_selection</i> and used in Gibbs steps to simulate stock specific &beta; and &sigma; in '<i>Factor_Model_HB_selection</i>' function.

4) <b>proposal_4_HC.R</b> file contain a function named '<i>proposal_4_HC</i>'. The function simulate proposal value for Global shrinkage parameter &tau; from uniform distribution in the Metropolis-Hastings step for &tau; in '<i>Factor_Model_HB_selection</i>' function.

5) <b>dHCauchy.R</b> file contain a function named '<i>dHCauchy</i>'. The function evaluate the density of the <b>Half-Cauchy</b> distribution.

6) <b>dinvGamma.R</b> file contain a function named '<i>dinvGamma</i>'. The function evaluate the density of the <b>Inverse-Gamma</b> distribution.

7) <b>log_posterior_parallel.R</b> file contain a function named '<i>log_posterior_parallel</i>'. The function evaluate the log-posterior at Metropolis step in '<i>Factor_Model_HB_selection</i>' function.
