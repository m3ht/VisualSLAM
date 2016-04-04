function fast2_predict_sim(k, u, z, j)
% Fast SLAM 2.0 Prediction stage that samples 
% poses conditioned on both the current input 
% and the observation.

global Param;
global State;

[j, zhat, H_x, H_j] = observation_model(k, j);

Q_temp = State.Fast.particles{k}.Sigma(:,:,j) * H_j';
Q_j = H_j * Q_temp + Param.R;
K = Q_temp / Q_j;
dz = z - zhat;
dz(2) = minimizedAngle(dz(2));

V_t = gPrimeMotion(State.Fast.particles{k}.x, u);
M_t = motionNoiseCovariance(u, Param.alphas);
R_t = V_t * M_t * V_t';

mu_x = State.Fast.particles{k}.x;
Sigma_x = inv(H_x' * Q_j * H_x + inv(R_t))
mu_x = Sigma_x * H_x' * inv(Q_j) * dz + mu_x

State.Fast.particles{k}.x = sample(mu_x, Sigma_x, length(mu_x));

end

function M_t = motionNoiseCovariance(motion, alphas)
% Noise covariance of the process model given the alpha parameters.
	drot1 = motion(1);
	dtran = motion(2);
	drot2 = motion(3);

	M_t = zeros(length(motion));
	M_t(1, 1) = alphas(1)*drot1^2 + alphas(2)*dtran^2;
	M_t(2, 2) = alphas(3)*dtran^2 + alphas(4)*(drot1^2 + drot2^2);
	M_t(3, 3) = alphas(1)*drot2^2 + alphas(2)*dtran^2;
end
