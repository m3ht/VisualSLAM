function fast1_update_sim(z)
% Fast SLAM 1.0 update step.

global Param;
global State;

for k = 1:Param.M
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
		[j, zhat, H_x, H_j] = observation_model(k, H(old(i)));
		Q_temp = State.Fast.particles{k}.Sigma(:,:,j) * H_j';
		Q = H_j * Q_temp + Param.R;
		K = Q_temp / Q;
		dz = z(1:2,old(i)) - zhat;
		dz(2) = minimizedAngle(dz(2));
		State.Fast.particles{k}.mu(:,j) = State.Fast.particles{k}.mu(:,j) + K*dz;
		State.Fast.particles{k}.Sigma(:,:,j) = State.Fast.particles{k}.Sigma(:,:,j) - K*H_j*State.Fast.particles{k}.Sigma(:,:,j);
		State.Fast.particles{k}.weight = State.Fast.particles{k}.weight * gaussian(zhat(1:2), z(1:2,old(i)), Q);
	end

	for i = 1:length(new)
		H(new(i)) = initialize_new_landmark(k, z(:, new(i)));
	end
end

State.Fast.particles = resample(State.Fast.particles);

end
