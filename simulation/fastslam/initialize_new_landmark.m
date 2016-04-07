function H = initialize_new_landmark(k, z)
% EKF-SLAM State Augmentation Step

global State;
global Param;

switch lower(Param.dataAssociation)
case 'known'
	H = z(3);
otherwise
	if State.Fast.particles{k}.nL == 0
		H = 1;
	else
		H = State.Fast.particles{k}.sL(end) + 1;
	end
end

li = State.Fast.particles{k}.nL + 1;

State.Fast.particles{k}.nL = li;
State.Fast.particles{k}.sL(end + 1) = H;
State.Fast.particles{k}.iL(end + 1) = li;

state = State.Fast.particles{k}.mu_x;
State.Fast.particles{k}.mu_j(:,li) = endPoint(state, z);
G_z = endPointPrimeObservation(State.Fast.particles{k}.mu_x, z);
State.Fast.particles{k}.Sigma_j(:,:,li) = G_z*Param.R*G_z';

end % function

function landmark = endPoint(state, observation)
% Expected Observation
%    state - mean of the robot position.
%    observation - the actual observation.
	global Param;
	orientation = state(3) + observation(2);
	orientation = minimizedAngle(orientation);

	landmark(1, 1) = state(1) + observation(1) * cos(orientation);
	landmark(2, 1) = state(2) + observation(1) * sin(orientation);
end

function G_z = endPointPrimeObservation(state, observation)
% Jacobian of the expected observation w.r.t. the observation.
%    state - the mean position of the robot.
%    observation - the actual observation seen by the robot.
	global Param;
	orientation = state(3) + observation(2);
	orientation = minimizedAngle(orientation);

	G_z(1, :) = [cos(orientation), observation(1) * -sin(orientation)];
	G_z(2, :) = [sin(orientation), observation(1) *  cos(orientation)];
end
