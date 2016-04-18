function [li, zhat, H_j] = observation_model(k,j)
% An observation model that returns the expected
% observation and the corresponding Jacobian.

global Param;
global State;

index = State.Fast.particles{k}.sL == j;
li = State.Fast.particles{k}.iL(index);

mu_x = State.Fast.particles{k}.x;
mu_j = State.Fast.particles{k}.mu(:,li);

% The rotation transformation from 
% the imu frame to the world frame.
R_i_to_w = [cos(mu_x(3)) -sin(mu_x(3));
            sin(mu_x(3))  cos(mu_x(3))];
% The roation transformation from
% the world frame to the imu frame.
R_w_to_i = inv(R_i_to_w);

zhat = R_w_to_i * (mu_j - mu_x(1:2));
H_j = R_w_to_i * eye(length(mu_j)) * R_w_to_i';

end