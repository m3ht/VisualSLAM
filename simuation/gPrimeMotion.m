function V_t = gPrimeMotion(state, motion)
% Jacobian of the process model w.r.t. the motion.
	V_t = zeros(length(state));
	V_t(1, :) = [-motion(2)*sin(motion(1) + state(3)), cos(motion(1) + state(3)), 0];
	V_t(2, :) = [ motion(2)*cos(motion(1) + state(3)), sin(motion(1) + state(3)), 0];
	V_t(3, :) = [                                   1,                         0, 1];
end