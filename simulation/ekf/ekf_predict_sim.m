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
