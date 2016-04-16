function [H_e, H_m] = da_nn(k,z)

global Param;
global State;

n = length(z);
H_e = zeros(n, 1);
H_m = zeros(n, 1);

bins = cell(State.Fast.particles{k}.nL,1);
for i = 1:State.Fast.particles{k}.nL
	bin = {};
	for j = 1:n
		dij2 = individual_compatibility_observation(k,z{j},i);
		if dij2 < Param.nnMahalanobisThreshold
			bin{end+1}.index = j;
			bin{end}.observation = z{j};
		end
	end
	bins{i} = bin;
end

% for i = 1:State.Fast.particles{k}.nL
% 	landmark_surf = State.Fast.particles{k}.SURF(:,i);

% 	minimum_index = 0;
% 	minimum_distance = inf;
% 	for j = 1:length(bins{i})
% 		distance = norm(bins{i}{j}.observation.surf - landmark_surf);
% 		if distance < minimum_distance
% 			minimum_distance = distance;
% 			minimum_index = j;
% 		end
% 	end

% 	if minimum_distance < Param.nnEuclideanThreshold
% 		H_e(bins{i}{minimum_index}.index) = i;
% 	end
% end

for i = 1:State.Fast.particles{k}.nL
	d2min = inf;
	nearest = 0;

	for j = 1:length(bins{i})
		dij2 = individual_compatibility_descriptor(k,bins{i}{j}.observation,i);
		if dij2 < d2min
			nearest = State.Fast.particles{k}.sL(j);
			d2min = dij2;
		end
	end

	if d2min <= 100
		H_m(bins{i}{nearest}.index) = i;
	end
end

end % function

function distance = individual_compatibility_observation(k, E_i, F_j)

global Param;
global State;

F_j = State.Fast.particles{k}.sL(F_j);
[li, F_j, H_j] = observation_model(k,F_j);
dz = E_i.O_imu(1:2) - F_j;
R_t = observation_noise(E_i.O_c);
Q = H_j * State.Fast.particles{k}.Sigma(:,:,li) * H_j' + R_t;
distance = dz' / Q * dz;

end % function

function distance = individual_compatibility_descriptor(k, E_i, F_j)

global Param;
global State;

mu_descriptor = State.Fast.particles{k}.mu_descriptor(:,F_j);
dz = E_i.mu_descriptor - mu_descriptor;
distance = dz' / State.Fast.particles{k}.Sigma_descriptor(:,:,F_j) * dz;

end