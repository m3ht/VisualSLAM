clear
close all
addpath('../data/matlab');
global calib;
global Params;
global landmark; %stored landmarks
global active_landmark; %currently in frame
Params.NumFrames = 4;
Params.SurfPoints = 200;
%take active landmarks, track them across frames. implement data
%association once they have been concluded to be stable.

activePoints = cell(Params.NumFrames,1);


%% load calibration file
calFileLocation = fullfile('~','Desktop','eecs-568-project','kitti','2011_09_26','calib_cam_to_cam.txt');
calib = loadCalibrationCamToCam(calFileLocation);

baselineDist = norm(calib.T{2});
focalLength = calib.P_rect{1}(1,1);
%% load rectified images
leftPath = fullfile('~','Desktop','eecs-568-project','kitti','2011_09_26','2011_09_26_drive_0002_sync','image_00','data');
leftFileNames = dir(fullfile(leftPath,'*.png'));
leftNumImages = length(leftFileNames);

rightPath = fullfile('~','Desktop','eecs-568-project','kitti','2011_09_26','2011_09_26_drive_0002_sync','image_01','data');
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
        figure(2)
        showMatchedFeatures(left,previousLeft,matchedPointsCurrent,matchedPointsPrevious);
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
        figure(3)
        showMatchedFeatures(left,right,matchedPoints1,matchedPoints2);
        
        disparity = sum((matchedPoints1.Location - matchedPoints2.Location).^2,2).^0.5;
        depth = baselineDist * focalLength./disparity;
        
        %% sanity check for disparity
        %{
            figure(4)
            for j=1:10
            showMatchedFeatures(left,right,matchedPoints1(j),matchedPoints2(j));
            depth(j)
            end
        %}
        
    end
    
    %% track features: match landmarks in "active landmarks" to the current frame.
    % Update the active landmarks.
    %Discard unmatached landmarks with no. of frames tracked<param.
    %Push to landmarks if unmatached and stable.
    
end

