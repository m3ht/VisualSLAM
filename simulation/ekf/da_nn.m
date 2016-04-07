function H = da_nn(z)
% Runs an incremental maximum likelihood algoroithm
% to associte measurement E_i with the feature F_j
% having the smalles Mahalanobis distance.
%    z - the set of observations to
%        determine a hypothesis for.
%    H - the NN hypothesis of the i observation where a non-
%        zero element indicates a data association and a zero
%        element indicates the existence of a new landmark.

global State;

k = size(z, 2);
H = zeros(k, 1);

for i = 1:k
	d2min = inf;
	nearest = 0;

	for j = 1:State.Ekf.nL
		dij2 = individual_compatibility(z(1:2, i), State.Ekf.sL(j));
		if dij2 < d2min
			nearest = State.Ekf.sL(j);
			d2min = dij2;
		end
	end

	if d2min <= 10.0
		H(i) = nearest;
	end
end
