function R_t = observation_noise(observation)
	global Param;

	x = observation(1);
	y = observation(2);
	d = observation(3);

	T_p_to_c = [1/d 0   -x/d^2;
                0   1/d -y/d^2;
                0   0   -1/d^2];
    T_c_to_w = inv(Param.cameraCalibration.P_rect{1}(:,1:3));

	baseline_distance = norm(Param.cameraCalibration.T{2});
	focal_length = Param.cameraCalibration.P_rect{1}(1,1);
	Bf = baseline_distance * focal_length;

	P = [1 0 0;
         0 1 0];
	R_c_to_i = Param.R_c_to_i;
	A = P * R_c_to_i * T_c_to_w * Bf * T_p_to_c;
	R_t = A * Param.Q * A';
end