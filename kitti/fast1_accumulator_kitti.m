function [stable_surf_points, stable_surf_descriptors] = fast1_accumulator_kitti(t)

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

% Temporal feature matching.
if t > 1
	index_pairs = matchFeatures(...
		left_surf_descriptors,...
		State.previous.leftSURFDescriptors,...
		'Method', 'Approximate',...
		'Unique', true,...
		'MatchThreshold',1.0);
	matched_points_current = left_surf_valid_points(index_pairs(:,1),:);
	matched_points_previous = State.previous.leftSURFValidPoints(index_pairs(:,2),:);
	
	figure(2);
	% Again, displaying the matched features for sanity check.
	showMatchedFeatures(...
		left,...
		Data.leftCameraImages{t-1},...
		matched_points_current,...
		matched_points_previous);
end

if rem(t, Param.maxAccumulateFrames) == 1
	State.previous.leftSURFValidPoints = left_surf_valid_points;
else
	State.previous.leftSURFValidPoints = matched_points_current;
end

State.previous.leftSURFDescriptors = extractFeatures(...
	Data.leftCameraImages{t},...
	State.previous.leftSURFValidPoints);

stable_surf_points = [];
stable_surf_descriptors = [];

if (rem(t, Param.maxAccumulateFrames)==0)
	stable_surf_points = matched_points_current;
	stable_surf_descriptors = State.previous.leftSURFDescriptors;
end

end