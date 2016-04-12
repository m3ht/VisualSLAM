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
R_t = observationNoise(z.O_c);
G_z = endPointPrimeObservation(state);

State.Fast.particles{k}.mu(:,j) = endPoint(state, z.O_imu);
State.Fast.particles{k}.Sigma(:,:,j) = G_z * R_t * G_z';

plotMarker(State.Fast.particles{k}.mu(:,j), 'green');

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
	P1 = [1 0 0;
		  0 1 0];
	P2 = [1 0 0 0;
	      0 1 0 0;
	      0 0 0 1];
	landmark = P1 * H_i_to_w * P2 * [observation; 1];
end

function G_z = endPointPrimeObservation(state)
	G_z = [cos(state(3)) -sin(state(3));
	       sin(state(3))  cos(state(3))];
end

function R_t = observationNoise(observation)
	global Param;

	x = observation(1);
	y = observation(2);
	d = observation(3);

	T_p_to_c = [1/d 0   -x/d^2;
				0   1/d -y/d^2;
				0   0   -1/d^2];
	P = [1 0 0;
		 0 1 0];
	R_c_to_i = Param.R_c_to_i;
	A = P * R_c_to_i * T_p_to_c;
	R_t = A * Param.Q * A';
end