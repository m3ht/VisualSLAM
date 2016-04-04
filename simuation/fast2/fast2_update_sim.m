function fast2_update_sim(k, z, j)

global Param;
global State;

[j, zhat, H_x, H_j] = observation_model(k, j);
Q_temp = State.Fast.particles{k}.Sigma(:,:,j) * H_j';
Q = H_j * Q_temp + Param.R;
K = Q_temp / Q;
dz = z - zhat;
dz(2) = minimizedAngle(dz(2));
State.Fast.particles{k}.mu(:,j) = State.Fast.particles{k}.mu(:,j) + K*dz;
State.Fast.particles{k}.Sigma(:,:,j) = State.Fast.particles{k}.Sigma(:,:,j) - K*H_j*State.Fast.particles{k}.Sigma(:,:,j);
State.Fast.particles{k}.weight = State.Fast.particles{k}.weight * gaussian(zhat(1:2), z, Q);