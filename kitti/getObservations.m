function z = getObservations(t, points, descriptors)

global Data;
global Param;
global State;

z = [];

if rem(t, Param.maxAccumulateFrames) > 0
	return;
end

% Extract the images into local variables for convenience.
left = Data.leftCameraImages{t};
right = Data.rightCameraImages{t};

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

% figure(3);
% showMatchedFeatures(left, right, matched_points_1, matched_points_2);

% Get calibrations parameters.
baseline_distance = norm(Param.cameraCalibration.T{2});
focal_length = Param.cameraCalibration.P_rect{1}(1,1);

% Return Noisy Observations
disparity = sum((matched_points_1.Location - matched_points_2.Location).^2,2).^0.5;
depth = baseline_distance * focal_length ./ disparity;

% Band-pass filter to only choose good disparities within a hand-picked range.
k = find(and(disparity >= Param.minDisparity,disparity <= Param.maxDisparity));
disparity = disparity(k); depth = depth(k);
matched_points_1 = matched_points_1(k,:);

z = camera_transform_pixel2world(matched_points_1.Location',depth);
z_imu  = Param.H_c_to_i * [z;repmat(1,[1 size(z,2)])];
z_imu = z_imu(1:3,:)./repmat(z_imu(4,:),[3 1]);
z = z_imu;

end % function

function world_coordinate = camera_transform_pixel2world(pixel_coordinate, Z)
	% Converts pixel coordinates (origin top-left) 2xn, where n is the number 
	% of SURF points vector and depth nx1 to world coordinates [X,Y,Z] from 
	% point of view of camera center.
	% outputs a 3xn vector (non homogenous)

	global Param;

	% Pre-computed inverse does not give same result. 
	T = Param.cameraCalibration.P_rect{1}(:,1:3);
	% Units depend on unit of Z.
	world_coordinate = T\([pixel_coordinate; repmat(1,[1 size(pixel_coordinate,2)])].*repmat(Z',[3 1]));
end