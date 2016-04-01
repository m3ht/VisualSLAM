function [mu, Sigma] = meanAndVariance(samples)
% Returns the mean and the covariance
% of a collection of smaples.
% Assumes equally weighted particles.
numSamples = length(samples);
mu = mean(samples, 2);

% Orientation is a bit more tricky.
sinSum = 0;
cosSum = 0;
for i = 1:numSamples,
	cosSum = cosSum + cos(samples(3, i));
	sinSum = sinSum + sin(samples(3, i));
end
mu(3) = atan2(sinSum, cosSum);

% Compute covariance.
zeroMean = samples - repmat(mu, 1, numSamples);
for i = 1:numSamples
	zeroMean(3, i) = minimizedAngle(zeroMean(3, i));
end

Sigma = zeroMean*zeroMean' / numSamples;
