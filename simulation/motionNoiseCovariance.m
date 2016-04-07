function M_t = motionNoiseCovariance(motion, alphas)
% Noise covariance of the process model given the alpha parameters.
	drot1 = motion(1);
	dtran = motion(2);
	drot2 = motion(3);

	M_t = zeros(length(motion));
	M_t(1, 1) = alphas(1)*drot1^2 + alphas(2)*dtran^2;
	M_t(2, 2) = alphas(3)*dtran^2 + alphas(4)*(drot1^2 + drot2^2);
	M_t(3, 3) = alphas(1)*drot2^2 + alphas(2)*dtran^2;
end