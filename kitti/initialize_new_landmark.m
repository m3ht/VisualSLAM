function H = initialize_new_landmark(k,z)
% Fast SLAM 1.0 State Augmentation Step

global Param;
global State;

if State.Fast.particles{k}.nL == 0
	H = 1;
else
	H = State.Fast.particles{k}.sL(end)+1;
end

j = State.Fast.particles{k}.nL + 1;

State.Fast.particles{k}.nL = j;
State.Fast.particles{k}.sL(end + 1) = H;
State.Fast.particles{k}.iL(end + 1) = j;

state = State.Fast.particles{k}.x;
landmark = endPoint(state, z.O_imu);
plotMarker(landmark(1:2), 'green');

end % function

function landmark = endPoint(state, observation)
	x_r = state(1);
	y_r = state(2);
	t_r = state(3);

	x_j = observation(1);
	y_j = observation(2);
	z_j = observation(3);

	H_i_to_w = [cos(t_r) -sin(t_r) x_r;
	            sin(t_r)  cos(t_r) y_r;
				0         0        1 ];
	P = [1 0 0 0;
	     0 1 0 0;
	     0 0 0 1];
	landmark = H_i_to_w * P * [observation; 1];
end
