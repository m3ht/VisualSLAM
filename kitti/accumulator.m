function [stable_surf_points, stable_surf_descriptors, stable_surf_descriptors_mu, stable_surf_descriptors_Sigma] = accumulator(t)

global Data;
global Param;
global State;

% Extract the images into local variables for convenience.
left = Data.leftCameraImages{t};
right = Data.rightCameraImages{t};

% Detect the k strongest SURF points from the left camera image.
left_surf_points = detectSURFFeatures(left);
left_surf_points = left_surf_points.selectStrongest(Param.maxSURFDescriptors);

% Extract SURF descriptors from the k strongest SURF points.
[left_surf_descriptors, left_surf_valid_points] = extractFeatures(left, left_surf_points);

if rem(t, Param.maxAccumulateFrames) == 1
	Data.accumulator.mu = left_surf_descriptors;
	Data.accumulator.Sigma = zeros( ...
		size(Data.accumulator.mu,2),...
		size(Data.accumulator.mu,2),...
		size(Data.accumulator.mu,1));
	Data.accumulator.previous.leftSURFValidPoints = left_surf_valid_points;
else
	% Temporal feature matching.
	index_pairs = matchFeatures(...
		left_surf_descriptors,...
		Data.accumulator.previous.leftSURFDescriptors,...
		'Method', 'Approximate',...
		'Unique', true,...
		'MatchThreshold',1.0);
	matched_points_current = left_surf_valid_points(index_pairs(:,1),:);

	% TODO: Compute the mean and covariance.
	if rem(t, Param.maxAccumulateFrames) == 0
		n = 5;
	else
		n = rem(t, Param.maxAccumulateFrames);
	end
	data_current = left_surf_descriptors(index_pairs(:,1),:);
	mu_previous = Data.accumulator.mu(index_pairs(:,2),:);
	Data.accumulator.mu = (data_current + (n-1)*mu_previous)/n;

	Data.accumulator.Sigma = Data.accumulator.Sigma(:,:,index_pairs(:,2));
	for i = 1:length(index_pairs(:,1))
		index1 = index_pairs(i,1);
		index2 = index_pairs(i,2);

		x = data_current(i,:)';
		mu = mu_previous(i,:)';

		Sigma_previous = Data.accumulator.Sigma(:,:,i);
		Sigma_current = (x - mu) * (x - mu)';
		Data.accumulator.Sigma(:,:,i) = ((n-1)*Sigma_previous + Sigma_current)./n;
	end


	Data.accumulator.previous.leftSURFValidPoints = matched_points_current;

	% matched_points_previous = Data.accumulator.previous.leftSURFValidPoints(index_pairs(:,2),:);
	% figure(2);
	% % Again, displaying the matched features for sanity check.
	% showMatchedFeatures(...
	% 	left,...
	% 	Data.leftCameraImages{t-1},...
	% 	matched_points_current,...
	% 	matched_points_previous);
end

Data.accumulator.previous.leftSURFDescriptors = extractFeatures(...
	Data.leftCameraImages{t},...
	Data.accumulator.previous.leftSURFValidPoints);

stable_surf_descriptors_mu = [];
stable_surf_descriptors_Sigma = [];
stable_surf_points = [];
stable_surf_descriptors = [];

if rem(t, Param.maxAccumulateFrames) == 0
	stable_surf_descriptors_mu = Data.accumulator.mu;
	stable_surf_descriptors_Sigma = Data.accumulator.Sigma;
	stable_surf_points = matched_points_current;
	stable_surf_descriptors = Data.accumulator.previous.leftSURFDescriptors;
end

end