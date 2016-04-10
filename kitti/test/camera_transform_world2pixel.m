function Output = camera_transform_world2pixel(Input)
%intrinsic camera transformation from world coordinates to pixel
%coordinates
global calib;
%http://www.robots.ox.ac.uk/NewCollegeData/index.php?n=Main.Details
%x along width of image. coordinate system origin left bottom.

% input [x y z 1]' of real world. output [x y 1]' in pixels


%T = [389.956085 0 254.903519; 0 389.956085 201.899490; 0 0 1];



Output = calib.P_rect{1}*Input;
Output = Output./Output(3);