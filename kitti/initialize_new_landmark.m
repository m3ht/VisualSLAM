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
R_t = observation_noise(z.O_c);
G_z = endPointPrimeObservation(state);

State.Fast.particles{k}.SURF(:,j) = z.surf;
State.Fast.particles{k}.mu(:,j) = endPoint(state, z.O_imu);
State.Fast.particles{k}.Sigma(:,:,j) = G_z * R_t * G_z';
State.Fast.particles{k}.mu_descriptor(:,end+1) = z.mu_descriptor;
State.Fast.particles{k}.Sigma_descriptor(:,:,end+1) = z.Sigma_descriptor;

% figure(1);
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