function Output = camera_transform_pixel2world(Input,Z)

%converts a pixel coordinates (origin bottom left) 2x1 vector and depth
%(scalar) to world coordinates [X,Y,Z] from point of view of camera center.
%
T = [389.956085 0 254.903519; 0 389.956085 201.899490; 0 0 1];
%{
Tinv= [0.0026         0   -0.6537;...
         0    0.0026   -0.5177;...
         0         0    1.0000];
     %}
%pre computed inverse does not give same result. 

%units depend on unit of zS
Output = T\[Input; 1]*Z;