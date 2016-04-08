images = imageSet('~/Desktop/EECS568_project/malaga-urban-dataset_bumblebee2_images_for_calibration/left');
imageFileNames = images.ImageLocation;

%% Detect the calibration pattern.
[imagePoints, boardSize] = detectCheckerboardPoints(imageFileNames);
%% Generate the world coordinates related to the corners of the squares. Square size is in millimeters.
squareSize = 34; 
worldPoints = generateCheckerboardPoints(boardSize, squareSize); 
%% Calibrate the camera.
params = estimateCameraParameters(imagePoints, worldPoints);
%% Load an image and detect the checkerboard points.
I = images.read(10);
points = detectCheckerboardPoints(I);
%% Undistort the points.
undistortedPoints = undistortPoints(points, params);
%% Undistort the image.
[J, newOrigin] = undistortImage(I, params, 'OutputView', 'full');
%% Translate the undistorted points.
undistortedPoints = [undistortedPoints(:,1) - newOrigin(1), undistortedPoints(:,2) - newOrigin(2)];
%% Display the results.
   figure; 
   imshow(I); 
   hold on;
   plot(points(:, 1), points(:, 2), 'r*-');
   title('Detected Points'); 
   hold off;

   figure; 
   imshow(J); 
   hold on;
   plot(undistortedPoints(:, 1), undistortedPoints(:, 2), 'g*-');
   title('Undistorted Points'); 
   hold off;