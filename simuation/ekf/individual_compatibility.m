function distance = individual_compatibility(E_i, F_j)
% Compute the malanobis distance
% between measurement E_i and a
% landmark F_j.

global State;
global Param;
[F_j H] = observation_model(F_j);
dz = E_i - F_j;
dz(2) = minimizedAngle(dz(2));
S = H*State.Ekf.Sigma*H' + Param.R;
distance = dz' / S * dz;
