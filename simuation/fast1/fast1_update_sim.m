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

	for j = 1:length(old)
		[li, zhat, H_r, H_j] = observation_model(k, H(old(j)));
		Q_temp = State.Fast.particles{k}.Sigma(:,:,li) * H_j';
		Q = H_j * Q_temp + Param.R;
		K = Q_temp / Q;
		dz = z(1:2,old(j)) - zhat;
		dz(2) = minimizedAngle(dz(2));
		State.Fast.particles{k}.mu(:,li) = State.Fast.particles{k}.mu(:,li) + K*dz;
		State.Fast.particles{k}.Sigma(:,:,li) = State.Fast.particles{k}.Sigma(:,:,li) - K*H_j*State.Fast.particles{k}.Sigma(:,:,li);
		State.Fast.particles{k}.weight = State.Fast.particles{k}.weight * gaussian(zhat(1:2), z(1:2,old(j)), Q);
	end

	for j = 1:length(new)
		H(new(j)) = initialize_new_landmark(k, z(:, new(j)));
	end
end

State.Fast.particles = resample(State.Fast.particles);

end

function pdf = gaussian(z, mu, Sigma)
	dz = z - mu;
	dz(2) = minimizedAngle(dz(2));
	pdf = 2 * pi * sqrt(det(Sigma));
	pdf = exp(-0.5*dz'*inv(Sigma)*dz) / pdf;
end
