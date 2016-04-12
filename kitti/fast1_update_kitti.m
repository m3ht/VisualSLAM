function fast1_update_kitti(z)

if isempty(z)
	return;
end

global Param;
global State;

for i = 1:length(z)
	initialize_new_landmark(1,z{i});
end