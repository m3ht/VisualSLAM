function plotSamples(samples)
WAS_HOLD = ishold;

if ~WAS_HOLD
	hold on
end

numSamples = size(samples, 2);

for i = 1:numSamples
	plotMarker(samples(1:2, i), 'y');
end

if ~WAS_HOLD
	hold off
end
