function H = ekf_update_sim(z)
% EKF-SLAM update step that's used by
% both the simulation and the victoria
% park data set.
	global Param;
	global State;

	switch lower(Param.dataAssociation)
		case 'known'
			H = da_known(z);
		case 'nn'
			H = da_nn(z);
		case 'jcbb'
			H = da_jcbb(z);
		otherwise
			error('unrecognized data association method: "%s"', Param.dataAssociation);
	end

	seen = find(H);
	new = setdiff(1:length(H), seen);

	switch lower(Param.updateMethod)
	case 'seq'
		sequentialUpdate(z(:, seen), H(seen));
	case 'batch'
		batchUpdate(z(:, seen), H(seen));
	otherwise
		error('unrecognized update method: "%s"', Param.updateMethod);
	end

	for i = 1:length(new)
		if strcmp(Param.dataAssociation, 'known')
			H(new(i)) = z(3, new(i));
		end
		H(new(i)) = initialize_new_landmark(z(:, new(i)), H(new(i)));
	end
end

function sequentialUpdate(z, H)
	global State;
	global Param;

	for i = 1:length(H)
		[zhat, H_t] = observation_model(H(i));
		S_temp = State.Ekf.Sigma*H_t';
		S = H_t*S_temp + Param.R;
		K = S_temp / S;
		dz = z(1:2, i) - zhat;
		dz(2) = minimizedAngle(dz(2));
		State.Ekf.mu = State.Ekf.mu + K*dz;
		State.Ekf.Sigma = State.Ekf.Sigma - K*H_t*State.Ekf.Sigma;
	end
end

function batchUpdate(z, H)
	if length(H) < 1
		return;
	end

	global State;
	global Param;

	R = [];
	H_t = [];
	dz = [];
	for i = 1:length(H)
		[zhat_i, H_t(end+1:end+2, :)] = observation_model(H(i));
		dz(end+1, 1) = z(1,i) - zhat_i(1);
		dz(end+1, 1) = minimizedAngle(z(2,i) - zhat_i(2));
		R(end+1:end+2, end+1:end+2) = Param.R;
	end
	S_temp = State.Ekf.Sigma*H_t';
	S = H_t*S_temp + R;
	K = S_temp / S;
	State.Ekf.mu = State.Ekf.mu + K*dz;
	State.Ekf.Sigma = State.Ekf.Sigma - K*H_t*State.Ekf.Sigma;
end
