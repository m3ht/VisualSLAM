function H = da_known(k, z)
% Return a list of the marked
% IDs of the markers seen by
% the robot.
%    z - the actual observation.
%    H - list of marker IDs. Contains a zeros at
%        the i-th position to indicate that the
%        i-th observation is of a new landmark.

global State;
n = size(z, 2);
H = zeros(n, 1);
for i = 1:n
	if ~any(State.Fast.particles{k}.sL == z(3, i))
		H(i) = 0;
	else
		H(i) = z(3, i);
	end
end
