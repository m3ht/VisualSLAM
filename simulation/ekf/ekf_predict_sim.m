function ekf_predict_sim(u)
% EKF-SLAM Prediction Step for the Simulation
	global Param;
	global State;

	r = State.Ekf.iR;
	G_t = gPrimeState(u, State.Ekf.mu(r));
	V_t = gPrimeMotion(State.Ekf.mu(r), u);
	M_t = motionNoiseCovariance(u, Param.alphas);
	R_t = V_t * M_t * V_t';

	State.Ekf.mu(r) = prediction(State.Ekf.mu(r), u);
	State.Ekf.Sigma(r, r) = G_t * State.Ekf.Sigma(r, r) * G_t' + R_t;

	if size(State.Ekf.Sigma, 1) > length(r)
		State.Ekf.Sigma(r, length(r)+1:end) = G_t * State.Ekf.Sigma(r, length(r)+1:end);
		State.Ekf.Sigma(length(r)+1:end, r) = State.Ekf.Sigma(r, length(r)+1:end)';
	end
end

function G_t = gPrimeState(motion, state)
% Jacobian of the process model w.r.t. the state.
	G_t = eye(length(state));
	G_t(1, 3) = -motion(2) * sin(state(3) + motion(1));
	G_t(2, 3) =  motion(2) * cos(state(3) + motion(1));
end


function V_t = gPrimeMotion(state, motion)
% Jacobian of the process model w.r.t. the motion.
	V_t = zeros(length(state));
	V_t(1, :) = [-motion(2)*sin(motion(1) + state(3)), cos(motion(1) + state(3)), 0];
	V_t(2, :) = [ motion(2)*cos(motion(1) + state(3)), sin(motion(1) + state(3)), 0];
	V_t(3, :) = [                                   1,                         0, 1];
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
