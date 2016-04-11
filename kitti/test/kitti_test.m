function kitti_test(base_dir)

addpath('../data/matlab');

global calib;
global Params;

Params.NumFrames = 5;
Params.SurfPoints = 200;

%take active landmarks, track them across frames. implement data
%association once they have been concluded to be stable.

%% load calibration file
calFileLocation = fullfile(base_dir, 'calibration', 'calib_cam_to_cam.txt');
calib = loadCalibrationCamToCam(calFileLocation);

baselineDist = norm(calib.T{2});
focalLength = calib.P_rect{1}(1,1);

%% load rectified images
leftPath = fullfile(base_dir, 'image_00', 'data');
leftFileNames = dir(fullfile(leftPath,'*.png'));
leftNumImages = length(leftFileNames);

rightPath = fullfile(base_dir, 'image_01', 'data');
rightFileNames = dir(fullfile(rightPath,'*.png'));
rightNumImages = length(rightFileNames);

if(rightNumImages~=leftNumImages)
    error('unequal left and right images');
end

%% iterate over time steps
for t=1:leftNumImages
    
    %% read images, convert to double (optional), histogram equalization
    left = imread(fullfile(leftPath,leftFileNames(t).name));
    left = histeq(left);
    leftPoints = detectSURFFeatures(left);
    leftStrongestPoints = leftPoints.selectStrongest(Params.SurfPoints);
    
    right = imread(fullfile(rightPath,rightFileNames(t).name));
    right = histeq(right);
    rightPoints = detectSURFFeatures(right);
    rightStrongestPoints = rightPoints.selectStrongest(Params.SurfPoints);
    
    
    %%  display (sanity check)
    %{
    figure(1)
    subplot(1,2,1)
    imshow(left); hold on;%im{i+1}
    leftStrongestPoints.plot('showOrientation',true);
    
    subplot(1,2,2)
    imshow(right); hold on;%im{i+1}
    rightStrongestPoints.plot('showOrientation',true);
    %}
    
    %% extract features
    [leftFeatures,leftValidPoints]=extractFeatures(left, leftStrongestPoints);
    [rightFeatures,rightValidPoints]=extractFeatures(right, rightStrongestPoints);
    
    %% temporal feature matching
    if(t>1)
        indexPairs = matchFeatures(leftFeatures,previousLeftFeatures,'Method','Approximate','Unique',true,'MatchThreshold',1.0);
        matchedPointsCurrent = leftValidPoints(indexPairs(:,1),:);
        matchedPointsPrevious = previousLeftValidPoints(indexPairs(:,2),:);
        s(1) = subplot(1,2,1);
        showMatchedFeatures(left,previousLeft,matchedPointsCurrent,matchedPointsPrevious);
        title(s(1),'Left - 1 time step');
        s(2) = subplot(1,2,2);
        title(s(2),'Stereo - 5 time steps');
    end
    
    if(rem(t,Params.NumFrames)==1)
        temporalCount=1;
        previousLeftValidPoints = leftValidPoints;
        
    else
        previousLeftValidPoints = matchedPointsCurrent;
        temporalCount = temporalCount + 1;
    end
    previousLeft = left;
    previousLeftFeatures = extractFeatures(previousLeft, previousLeftValidPoints); %same as extractFeatures(left, matchedPointsCurrent);
    
    if (rem(t,Params.NumFrames)==0)
        stableLeftPoints = matchedPointsCurrent;
        stableLeftFeatures = previousLeftFeatures;
    end
    
    if(rem(t,Params.NumFrames)==0)
        %% match stereo features
        indexPairs = matchFeatures(stableLeftFeatures,rightFeatures,'Method','Approximate','Unique',true,'MatchThreshold',1.0);
        matchedPoints1 = stableLeftPoints(indexPairs(:,1),:);
        matchedPoints2 = rightValidPoints(indexPairs(:,2),:);
        
        disparity = sum((matchedPoints1.Location - matchedPoints2.Location).^2,2).^0.5;
        depth = baselineDist * focalLength./disparity;

        k = find(and(disparity >= 8, disparity <= 55));
        disparity = disparity(k);
        depth = depth(k);
        matchedPoints1 = matchedPoints1(k,:);
        matchedPoints2 = matchedPoints2(k,:);
    
         s(2) = subplot(1,2,2);
        showMatchedFeatures(left,right,matchedPoints1,matchedPoints2);
        title(s(1),'Left - 1 time step');
        title(s(2),'Stereo - 5 time steps');
        % %% sanity check for disparity
        % figure(4)
        % for j=1:10
        %     showMatchedFeatures(left,right,matchedPoints1(j),matchedPoints2(j));
        %     disparity(j);
        %     depth(j);
        %     pause
        % end
        
    end
    
    %% track features: match landmarks in "active landmarks" to the current frame.
    % Update the active landmarks.
    %Discard unmatached landmarks with no. of frames tracked<param.
    %Push to landmarks if unmatached and stable.
    
end

end % function

function Output = camera_transform_pixel2world(Input,Z)

global calib;
%converts a pixel coordinates (origin bottom left) 2x1 vector and depth
%(scalar) to world coordinates [X,Y,Z] from point of view of camera center.
%

%pre computed inverse does not give same result. 
T = calib.P_rect{1}(:,1:3);
%units depend on unit of zS
Output = T\[Input; 1]*Z;

end

function Output = camera_transform_world2pixel(Input)

%intrinsic camera transformation from world coordinates to pixel
%coordinates
global calib;
%http://www.robots.ox.ac.uk/NewCollegeData/index.php?n=Main.Details
%x along width of image. coordinate system origin left bottom.

% input [x y z 1]' of real world. output [x y 1]' in pixels

Output = calib.P_rect{1}*Input;
Output = Output./Output(3);

end