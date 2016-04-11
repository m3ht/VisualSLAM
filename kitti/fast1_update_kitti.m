function fast1_update_kitti(z)

if isempty(z)
	return;
end

global Param;
global State;

state = State.Fast.particles{1}.x;

x = state(1);
y = state(2);
t = state(3);

H_i_to_w = [cos(t) -sin(t) x;
            sin(t)  cos(t) y;
            0       0      1];
projection_matrix = [1 0 0 0;
                     0 1 0 0;
                     0 0 0 1];

z = [z; ones(1,size(z,2))];
landmarks = H_i_to_w * projection_matrix * z;

figure(1);
for i = 1:size(landmarks,2)
	plotMarker(landmarks(1:2,i),'green');

end