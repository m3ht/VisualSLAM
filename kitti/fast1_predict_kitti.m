function fast1_predict_kitti(u,dt)
% Fast SLAM 1.0 Prediction for the KITTI Dataset.

global Param;
global State;

for k = 1:Param.M
	noise = mvnrnd(Param.R_mu, Param.R_Sigma);
	u(1) = u(1) + noise(1);
	u(2) = u(2) + noise(2);
	State.Fast.particles{k}.x = prediction(State.Fast.particles{k}.x, u, dt);
end

end % function

function state = prediction(state, motion, deltaT)
	x = state(1);
	y = state(2);
	t = state(3);
	v = motion(1);
	w = motion(2);

	state(1) = x - v/w*sin(t) + v/w*sin(t+w*deltaT);
	state(2) = y + v/w*cos(t) - v/w*cos(t+w*deltaT);
	state(3) = t + w*deltaT;
end