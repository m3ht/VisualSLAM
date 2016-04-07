function [li, zhat, H_r, H_j] = observation_model(k, markerId)
% An observation model that returns the expected
% observation and the corresponding Jacobian.

global State;
global Param;

index = State.Fast.particles{k}.sL == markerId;
li = State.Fast.particles{k}.iL(index);

mu_x = State.Fast.particles{k}.x;
mu_j = State.Fast.particles{k}.mu(:,li);
dx = mu_j(1) - mu_x(1);
dy = mu_j(2) - mu_x(2);
q = dx^2 + dy^2;
zhat(1, 1) = sqrt(q);
zhat(2, 1) = minimizedAngle(atan2(dy, dx) - mu_x(3));

H_r(1, :) = 1/q * [-sqrt(q)*dx, -sqrt(q)*dy,  0];
H_r(2, :) = 1/q * [         dy,         -dx, -q];
H_j(1, :) = 1/q * [ sqrt(q)*dx,  sqrt(q)*dy];
H_j(2, :) = 1/q * [        -dy,          dx];
