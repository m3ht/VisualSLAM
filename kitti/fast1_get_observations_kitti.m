function z = fast1_get_observations(t, points, descriptors)

global Data;
global Param;
global State;

% Extract the images into local variables for convenience.
left = Data.leftCameraImages{t};
right = Data.rightCameraImages{t};

z = [];

if rem(t, Param.maxAccumulateFrames) > 0
	return;
end

% Detect the k strongest SURF points from the right camera image.
right_surf_points = detectSURFFeatures(right);
right_surf_points = right_surf_points.selectStrongest(Param.maxSURFDescriptors);

%  Extract SURF descriptors from the k strongest SURF points.
[right_surf_descriptors, right_surf_valid_points] = extractFeatures(right, right_surf_points);

% Match stereo features.
index_pairs = matchFeatures(...
	descriptors,...
	right_surf_descriptors,...
	'Method', 'Approximate',...
	'Unique', true,...
	'MatchThreshold', 1.0);
matched_points_1 = points(index_pairs(:,1),:);
matched_points_2 = right_surf_valid_points(index_pairs(:,2),:);

figure(3);
showMatchedFeatures(left, right, matched_points_1, matched_points_2);

% Get calibrations parameters.
baseline_distance = norm(Param.cameraCalibration.T{2});
focal_length = Param.cameraCalibration.P_rect{1}(1,1);

% Return Noisy Observations
disparity = sum((matched_points_1.Location - matched_points_2.Location).^2,2).^0.5;
depth = baseline_distance * focal_length ./ disparity;

z = depth;