function [zhat, H] = observation_model(markerId)
% An observation model that returns the expected
% observation and the corresponding Jacobian.

global State;
global Param;

index = State.Ekf.sL == markerId;
li = State.Ekf.iL{index};
r = State.Ekf.iR;
mu_x = State.Ekf.mu(r);
mu_j = State.Ekf.mu(li);
dx = mu_j(1) - mu_x(1);
dy = mu_j(2) - mu_x(2);
q = dx^2 + dy^2;
zhat(1, 1) = sqrt(q);
zhat(2, 1) = minimizedAngle(atan2(dy, dx) - mu_x(3));
if strcmp(Param.choice, 'vp') == 1
	zhat(2, 1) = minimizedAngle(zhat(2, 1) + pi/2);
end

H = zeros(length(mu_j), length(State.Ekf.mu));
H_r(1, :) = 1/q * [-sqrt(q)*dx, -sqrt(q)*dy,  0];
H_r(2, :) = 1/q * [         dy,         -dx, -q];
H_i(1, :) = 1/q * [ sqrt(q)*dx,  sqrt(q)*dy];
H_i(2, :) = 1/q * [        -dy,          dx];
H(:, r) = H_r;
H(:, li) = H_i;

