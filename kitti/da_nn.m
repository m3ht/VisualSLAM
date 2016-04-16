function H = da_nn(k,z)

global Param;
global State;

n = length(z);
H = zeros(n, 1);

bins = cell(State.Fast.particles{k}.nL,1);
for i = 1:State.Fast.particles{k}.nL
	bin = {};
	for j = 1:n
		dij2 = individual_compatibility(k,z{j},i);
		if dij2 < Param.nnMahalanobisThreshold
			bin{end+1}.index = j;
			bin{end}.observation = z{j};
		end
	end
	bins{i} = bin;
end

for i = 1:State.Fast.particles{k}.nL
	landmark_surf = State.Fast.particles{k}.SURF(:,i);

	minimum_index = 0;
	minimum_distance = inf;
	for j = 1:length(bins{i})
		distance = norm(bins{i}{j}.observation.surf - landmark_surf);
		if distance < minimum_distance
			minimum_distance = distance;
			minimum_index = j;
		end
	end

	if minimum_distance < Param.nnEuclideanThreshold
		H(bins{i}{minimum_index}.index) = i;
	end
end

end % function

function distance = individual_compatibility(k, E_i, F_j)

global Param;
global State;

F_j = State.Fast.particles{k}.sL(F_j);
[li, F_j, H_j] = observation_model(k,F_j);
dz = E_i.O_imu(1:2) - F_j;
R_t = observation_noise(E_i.O_c);
Q = H_j * State.Fast.particles{k}.Sigma(:,:,li) * H_j' + R_t;
distance = dz' / Q * dz;

end % function