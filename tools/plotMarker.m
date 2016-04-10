function h = plotMarker(state, color)

WAS_HOLD = ishold;

if ~WAS_HOLD
	hold on
end

h = plot(state(1), state(2), '.', 'linewidth', 2, 'Color', color);

if ~WAS_HOLD
	hold off
end
