# Independence Testing for Multivariate Time Series

Code accompanying the publication: [Independence Testing for Multivariate Time Series](https://arxiv.org/abs/1908.06486).

## Abstract

Complex data structures such as time series are increasingly more prevalent in modern data science problems. A fundamental question is whether two such time-series have a statistically significant relationship. Many current approaches rely on making parametric assumptions on the random processes, detecting only linear associations, requiring multiple tests, or sacrificing power in high-dimensional and nonlinear settings. The distribution of any test statistic under the null hypothesis is challenging to estimate, as the permutation test is typically invalid. This study combines distance correlation (Dcorr) and multiscale graph correlation (MGC) from independence testing literature with block permutation from time series analysis to address these challenges. The proposed nonparametric procedure is asymptotic valid, consistent for dependence testing under stationary time-series, able to estimate the optimal lag that maximizes the dependence. It eliminates the need for multiple testing, and exhibits superior power in high-dimensional, low sample size, and nonlinear settings. The analysis of neural connectivity with fMRI data reveals a linear dependence of signals within the visual network and default mode network and nonlinear relationships in other networks. This work provides a primary data analysis tool with open-source code, impacting a wide range of scientific disciplines.

## Repo Structure

## Guide to using the repository

- Navigate to a directory where you want to store the project, and clone this repo:

```
git clone https://github.com/neurodata/bilateral-connectome
```
