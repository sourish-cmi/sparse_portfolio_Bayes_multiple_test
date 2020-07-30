# Sparse Portfolio Selection via Bayesian Multiple Testing

All codes of the paper titled "<b>Sparse Portfolio Selection via Multiple Testing</b>" are available here. This is a joint project of <b>Sourish Das</b> and <b>Rituparna Sen</b>. The paper is being accepted in <b>Sankhya - B</b>. The preprint of the paper can be found here: <a href='https://arxiv.org/abs/1705.01407'>Preprint</a> 

Soon we will upload all the R codes of this paper.

<b>Following R-packages are required</b>:

1) snowfall
2) mvtnorm
3) MCMCpack
4) tseries
5) lars
6) xts
7) xtable
  
### Back testing of the Bayesian Sparse Portfolio

<b>Back_testing.R</b> is the main file which tests all the methodology described in the paper with data on 500 stocks which are mostly part of S&P 500 index and listed with NYSE (around 2018). The file <b>Back_testing.R</b> calls all the files described below. The 500 stocks which are part of S&P 500 are typically liquid in nature. We pretend that the market consists of these 500 stocks and we are going to select 25 stocks using described methodologies using one month data. Then we pretend as if we invest in those 25 selected stocks for next one month and accept the portfolio return from the investment. We start our back-testing from 2006-Jan-01. 

For backtesting, the adjusted close prices of 500 stocks were downloaded from Yahoo and stored as RData file: <b>yahoo_snp500_adj_close_return_20181101.RData</b> The data downloaded on 1st Nov 2018.

### Capital Asset Pricing Model (CAPM) with MLE 

1) <b>CAPM_MLE_Back_testing.R</b> compute the &alpha;, &beta;, and &sigma; of CAPM for <i>j<sup>th</sup></i> training period for month <i>t</i> to select the stocks for portfolio. Based on &alpha; it select the ns(=25) stocks. Then compute the out-sample portfolio return for month <i>t+1</i>. The parameters of <b>CAPM</b> &alpha; &beta; and &sigma; estimated using MLE method.

### Capital Asset Pricing Model (CAPM) with LARS-LASSO method by Fang etal.

2) <b>CAPM_Fang_Back_testing.R</b> compute the &alpha;, &beta;, and &sigma; of CAPM for <i>j<sup>th</sup></i> training period for month <i>t</i> to select the stocks for portfolio. Based on &alpha; it select the ns(=25) stocks. Then compute the out-sample portfolio return for month <i>t+1</i>. The parameters of <b>CAPM</b> &alpha; &beta; and &sigma; estimated using LARS-LASSO method.

### Bayes Oracle test with Discrete Mixture prior for Portfolio Selection and Back testing of K-factor model

3) <b>Factor_Model_BO_Back_testing.R</b> compute the Bayes Oracle statistics <i>S<sub>i</sub></i> for the <i>i<sup>th</sup></i> stock. Then it select the ns(=25) many stocks for portfolio for largest ns(=25) <i>S<sub>i</sub></i>'s. The function implements the portfolio selection for the <i>j<sup>th</sup></i> training period for month <i>t</i> to select the stock's for portfolio and then test the performance for the month <i>t+1</i>.



### Hierarchical Bayes with Horse Shoe Prior model for Portfolio Selection and Back testing of K-factor model

4) <b>Factor_Model_HB_selection.R</b> file contain a function named '<i>Factor_Model_HB_selection</i>'. It implement the Gibbs sampling for &beta; and Metropolis update for scale parameters &sigma;<sub>c</sub> and &Sigma; with Horse Shoe prior on shrinkage parameter. The function uses parallel processing to simulate stock specific &beta; and &sigma; using <b>snowfall</b> R-package. The function uses three R-packages: (1) snowfall, (2) mvtnorm and (3) MCMCpack

4a) <b>run_Factor_Model_HB_selection.R</b> runs the portfolio selction with <i>Factor_Model_HB_selection</i> function for given month and return the stock specific MCMC samples of &alpha;, &beta; &sigma; and posterior estimates of the P(&alpha; > 0| data). 

4b) <b>Factor_Model_HB_Back_testing.R</b> file contain a function named '<i>Factor_Model_HB_Back_testing</i>'. It takes the output from <i>run_Factor_Model_HB_selection</i> for a specific month and build the portfolio using the highest posterior estimates of the P(&alpha; > 0| data) for ns(=25) stocks. One can use either 'equal weight' portfolio or 'Markowitz weight' portfolio strategy on the selected ns(=25) stocks. It computes the portfolio return for next month (as out-of-sample or test-sample portfolio return) for portfolio selected with ns(=25) stocks.

4c) <b>simulate_theta_sigma.R</b> file contain a function named '<i>simulate_theta_sigma</i>'. The function is called in  <i>Factor_Model_HB_selection</i> and used in Gibbs steps to simulate stock specific &beta; and &sigma; in '<i>Factor_Model_HB_selection</i>' function.

4d) <b>proposal_4_HC.R</b> file contain a function named '<i>proposal_4_HC</i>'. The function simulate proposal value for Global shrinkage parameter &tau; from uniform distribution in the Metropolis-Hastings step for &tau; in '<i>Factor_Model_HB_selection</i>' function.

4e) <b>dHCauchy.R</b> file contain a function named '<i>dHCauchy</i>'. The function evaluate the density of the <b>Half-Cauchy</b> distribution.

4f) <b>dinvGamma.R</b> file contain a function named '<i>dinvGamma</i>'. The function evaluate the density of the <b>Inverse-Gamma</b> distribution.

4g) <b>log_posterior_parallel.R</b> file contain a function named '<i>log_posterior_parallel</i>'. The function evaluate the log-posterior for Metropolis step in '<i>Factor_Model_HB_selection</i>' function.


