function pdf = gaussian(x, mu, Sigma)
	dx = x - mu;
	dx(2) = minimizedAngle(dx(2));
	pdf = 2 * pi * sqrt(det(Sigma));
	pdf = exp(-0.5*dx'*inv(Sigma)*dx) / pdf;
end