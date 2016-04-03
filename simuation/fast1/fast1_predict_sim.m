function fast1_predict_sim(u)
% Fast SLAM 1.0 Prediction for the Simulation

global Param;
global State;

for i = 1:Param.M
	State.Fast.particles{i}.x = sampleOdometry( ...
		u, State.Fast.particles{i}.x, Param.alphas);
end
