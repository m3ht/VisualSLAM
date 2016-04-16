function fast1_update_kitti(z)

if isempty(z)
	return;
end

global Param;
global State;

for k = 1:Param.M
	[H_e, H_m] = da_nn(k,z);
	H = H_e;

	old = find(H);
	new = setdiff(1:length(H), old);

	for i = 1:length(old)
		[j, zhat, H_j] = observation_model(k, H(old(i)));
		Q_temp = State.Fast.particles{k}.Sigma(:,:,j) * H_j';
		Q = H_j * Q_temp + observation_noise(z{old(i)}.O_c);
		K = Q_temp / Q;
		dz = z{old(i)}.O_imu(1:2) - zhat;
		State.Fast.particles{k}.mu(:,j) = State.Fast.particles{k}.mu(:,j) + K*dz;
		State.Fast.particles{k}.Sigma(:,:,j) = State.Fast.particles{k}.Sigma(:,:,j) - K*H_j*State.Fast.particles{k}.Sigma(:,:,j);
		State.Fast.particles{k}.weight = State.Fast.particles{k}.weight * importance_weight(zhat, z{old(i)}.O_imu(1:2), Q);
	end

	for i = 1:length(new)
		H(new(i)) = initialize_new_landmark(k,z{new(i)});
	end

	State.Fast.particles = resample(State.Fast.particles);
end

end % function

function pdf = importance_weight(zhat, z, Q)
	dz = zhat - z;
	pdf = 2 * pi * sqrt(det(Q));
	pdf = exp(-0.5*dz'*inv(Q)*dz) / pdf;
end

