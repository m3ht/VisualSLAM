function H = da_known(z)
% Return a list of the marked
% IDs of the markers seen by
% the robot.
%    z - the actual observation.
%    H - list of marker IDs. Contains a zeros at
%        the i-th position to indicate that the
%        i-th observation is of a new landmark.

global State;
k = size(z, 2);
H = zeros(k, 1);
for i = 1:k
	if ~any(State.Fast.sL == z(3, i))
		H(i) = 0;
	else
		H(i) = z(3, i);
	end
end
