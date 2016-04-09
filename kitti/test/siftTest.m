
% Scans through current folder and loads all jpg images. 
% Loops through all the images and displays SURF features.
%use extract feautures to get 64 sized feature vector. use cell to collect
%mean and variance of these vectors. 
clear
close all
S = pwd
S = strcat(S ,'/StereoImages/images/*.jpg')
fileNames = dir(S);
numImages = length(fileNames);

imageName=cell(numImages,1);
strongestPoints=cell(numImages,1);
features=cell(numImages,1);
valid_points=cell(numImages,1);

im=cell(numImages,1);
for i=1:numImages
    imageName{i} = fileNames(i).name;
end

numImages
%{
imageName{1} = 'img_CAMERA1_1261228969.770601_left.jpg';
imageName{2} = 'img_CAMERA1_1261228969.770601_right.jpg';

imageName{3} = 'img_CAMERA1_1261228969.820611_left.jpg';
%}
%im=zeros([size(imread(imageName{1})) 3]);
tic
figure
for i=1:2:numImages
    
left_color = imread(strcat('./StereoImages/images/',imageName{i}));
left=rgb2gray(left_color);
im{i} = im2double(left);


points = detectSURFFeatures(im{i});
strongestPoints{i} = points.selectStrongest(200);

subplot(1,3,1)
imshow(left_color); hold on; %im{i}
strongestPoints{i}.plot('showOrientation',true);
[features{i},valid_points{i}]=extractFeatures(im{i}, strongestPoints{i});
 
 
 
right_color = imread(strcat('./StereoImages/images/',imageName{i+1}));
right=rgb2gray(right_color);
im{i+1} = im2double(right);


points = detectSURFFeatures(im{i+1});
strongestPoints{i+1} = points.selectStrongest(200);

subplot(1,3,2)
imshow(right_color); hold on;%im{i+1}
strongestPoints{i+1}.plot('showOrientation',true);
[features{i+1},valid_points{i+1}]=extractFeatures(im{i+1}, strongestPoints{i+1});
 
%  disparityMap = disparity(left, right);
%  subplot(1,3,3)
% imshow(disparityMap, [0, 64]);
% title('Disparity Map');
% colormap jet
% colorbar
 
indexPairs = matchFeatures(features{i},features{i+1});
matchedPoints1 = valid_points{i}(indexPairs(:,1),:);
matchedPoints2 = valid_points{i+1}(indexPairs(:,2),:);
%{
[~, max_inliers, avg_residual,inlier_indices] = get_transform(matchedPoints1.Location(:,1), matchedPoints1.Location(:,2), matchedPoints2.Location(:,1), matchedPoints2.Location(:,2),1);
matchedPoints1 = matchedPoints1(inlier_indices);
matchedPoints2 = matchedPoints2(inlier_indices);
%}
figure(2); showMatchedFeatures(im{i},im{i+1},matchedPoints1,matchedPoints2);

end
toc


