function s = sample(mu, Sigma, dimensions)
% Samples from a multivariate gaussian
% with the given mean and covariance.

[V, D] = eig(Sigma);
s = mu + V*sqrt(D)*randn(dimensions,1);
