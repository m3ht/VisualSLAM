function fast1_update_kitti(z)

if isempty(z)
	return;
end

global Param;
global State;

for k = 1:1
	for i = 1:length(z)
		initialize_new_landmark(k,z{i});
	end
end

