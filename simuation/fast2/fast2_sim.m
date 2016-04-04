function fast2_sim(u, z)
% Simulates Fast SLAM 2.0

global Param;
global State;

for k = 1:Param.M
	State.Fast.particles{k}.x = prediction(State.Fast.particles{k}.x, u);

	switch lower(Param.dataAssociation)
	case 'known'
		H = da_known(k, z);
	case 'nn'
		H = da_nn(k, z);
	case 'nndg'
		H = da_nndg(k, z);
	case 'jcbb'
		H = da_jcbb(k, z);
	end

	old = find(H);
	new = setdiff(1:length(H), old);

	for i = 1:length(old)
		fast2_predict_sim(k, u, z(1:2,old(i)), H(old(i)));
		fast2_update_sim(k, z(1:2,old(i)), H(old(i)));
	end

	for i = 1:length(new)
		H(new(i)) = initialize_new_landmark(k, z(:, new(i)));
	end
end

State.Fast.particles = resample(State.Fast.particles);