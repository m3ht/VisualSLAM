function plotParticles(particles)
WAS_HOLD = ishold;

if ~WAS_HOLD
	hold on
end

M = length(particles);

for i = 1:M
	plotMarker(particles{i}.mu_x(1:2), 'r');
end

if ~WAS_HOLD
	hold off
end
