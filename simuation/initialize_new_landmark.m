function H = initialize_new_landmark(z, H)
% EKF-SLAM State Augmentation Step

global State;
global Param;

if H == 0
	if State.Ekf.nL == 0
		H = 1;
	else
		H = State.Ekf.sL(end) + 1;
	end
end

State.Ekf.nL = State.Ekf.nL + 1;
State.Ekf.sL(end + 1) = H;
State.Ekf.iM(end + 1) = length(State.Ekf.iR) + 2*State.Ekf.nL - 1;
State.Ekf.iM(end + 1) = length(State.Ekf.iR) + 2*State.Ekf.nL;
State.Ekf.iL{end + 1} = [State.Ekf.iM(end - 1) State.Ekf.iM(end)];

r = State.Ekf.iR;
l = length(State.Ekf.mu);
li = l+1:l+2;
state = State.Ekf.mu(r);
State.Ekf.mu(li) = endPoint(state, z);

G_r = endPointPrimeState(state, z);
G_z = endPointPrimeObservation(state, z);
State.Ekf.Sigma(li, li) = G_r * State.Ekf.Sigma(r, r) * G_r';
State.Ekf.Sigma(li, li) = State.Ekf.Sigma(li, li) + G_z * Param.R * G_z';
State.Ekf.Sigma(li, r) = G_r * State.Ekf.Sigma(r, r);
State.Ekf.Sigma(r, li) = State.Ekf.Sigma(li, r)';

if State.Ekf.nL > 0
	L = length(r)+1:l;
	State.Ekf.Sigma(li, L) = G_r * State.Ekf.Sigma(r, L);
	State.Ekf.Sigma(L, li) = State.Ekf.Sigma(li, L)';
end

end % function

function landmark = endPoint(state, observation)
% Expected Observation
%    state - mean of the robot position.
%    observation - the actual observation.
	global Param;
	orientation = state(3) + observation(2);
	if strcmp(Param.choice, 'vp') == 1
		orientation = orientation - pi/2;
	end
	orientation = minimizedAngle(orientation);

	landmark(1, 1) = state(1) + observation(1) * cos(orientation);
	landmark(2, 1) = state(2) + observation(1) * sin(orientation);
end

function G_r = endPointPrimeState(state, observation)
% Jacobian of the expected observation w.r.t. state of the robot.
%   state - the mean posiition of the robot's state.
%   observation - the actual observation seen by the robot.
	global Param;
	orientation = state(3) + observation(2);
	if strcmp(Param.choice, 'vp') == 1
		orientation = orientation - pi/2;
	end
	orientation = minimizedAngle(orientation);

	G_r = eye(length(observation(1:end-1)), length(state));
	G_r(1, 3) = observation(1) * -sin(orientation);
	G_r(2, 3) = observation(1) *  cos(orientation);
end

function G_z = endPointPrimeObservation(state, observation)
% Jacobian of the expected observation w.r.t. the observation.
%    state - the mean position of the robot.
%    observation - the actual observation seen by the robot.
	global Param;
	orientation = state(3) + observation(2);
	if strcmp(Param.choice, 'vp') == 1
		orientation = orientation - pi/2;
	end
	orientation = minimizedAngle(orientation);

	G_z(1, :) = [cos(orientation), observation(1) * -sin(orientation)];
	G_z(2, :) = [sin(orientation), observation(1) *  cos(orientation)];
end
