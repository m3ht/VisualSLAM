function Output = camera_transform_pixel2world(Input,Z)
global calib;
%converts a pixel coordinates (origin bottom left) 2x1 vector and depth
%(scalar) to world coordinates [X,Y,Z] from point of view of camera center.
%

%pre computed inverse does not give same result. 
T = calib.P_rect{1}(:,1:3);
%units depend on unit of zS
Output = T\[Input; 1]*Z;