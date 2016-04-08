function X_bar = resample(particles)
% Resample the particles using the low-
% variance importance sampling scheme.

M = length(particles);
X_bar = {};

r  = 1/M * rand;
weights_bar = zeros(M, 1);
for k = 1:M
	weights_bar(k) = particles{k}.weight;
end
weights = weights_bar ./ sum(weights_bar);

cdf = cumsum(weights);
i = 1;
for m = 1:M
	U = r + (m - 1)/M;
	while U > cdf(i)
		i = i + 1;
	end
	X_bar{m} = particles{i};
end

for k = 1:M
	X_bar{k}.weight = 1/M;
end
