function H = da_nn(k,z)

global Param;
global State;

n = size(z, 2);
H = zeros(n, 1);

for i = 1:n
	d2min = inf;
	nearest = 0;

	for j = 1:State.Fast.particles{k}.nL
		dij2 = individual_compatibility(k,z(1:2,i),j);
		if dij2 < d2min
			nearest = State.Fast.particles{k}.sL(j);
			d2min = dij2;
		end
	end

	if d2min <= Param.nnThreshold
		H(i) = nearest;
	end
end

end % function

function distance = individual_compatibility(k, E_i, F_j)

global Param;
global State;

F_j = State.Fast.particles{k}.sL(F_j);
[li, F_j, H_r, H_j] = observation_model(k,F_j);
dz = E_i - F_j;
dz(2) = minimizedAngle(dz(2));
Q = H_j * State.Fast.particles{k}.Sigma(:,:,li) * H_j' + Param.R;
distance = dz' / Q * dz;

end % function