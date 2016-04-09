
% Scans through current folder and loads all jpg images. 
% Loops through all the images and displays SURF features.
%use extract feautures to get 64 sized feature vector. use cell to collect
%mean and variance of these vectors. 
clear
close all
S = pwd
%S = strcat(S ,'/StereoImages/2011_09_26/images/*.jpg')
S = strcat(S ,'/kitti/data/image_00/data/*.png')
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

tic
figure
for i=1:numImages
S = pwd
S = strcat(S, '/kitti/data/image_00/data/')
left = imread(strcat(S,imageName{i}));
% left=rgb2gray(left_color);
im{i} = im2double(left);


points = detectSURFFeatures(im{i});
strongestPoints{i} = points.selectStrongest(200);

subplot(1,3,1)
imshow(left); hold on; %im{i}
strongestPoints{i}.plot('showOrientation',true);
[features{i},valid_points{i}]=extractFeatures(im{i}, strongestPoints{i});
 
 
 
S = pwd
S = strcat(S, '/kitti/data/image_01/data/')
right = imread(strcat(S,imageName{i}));
% right=rgb2gray(right_color);
im{i+1} = im2double(right);


points = detectSURFFeatures(im{i+1});
strongestPoints{i+1} = points.selectStrongest(200);

subplot(1,3,2)
imshow(right); hold on;%im{i+1}
strongestPoints{i+1}.plot('showOrientation',true);
[features{i+1},valid_points{i+1}]=extractFeatures(im{i+1}, strongestPoints{i+1});
 
indexPairs = matchFeatures(features{i},features{i+1});
matchedPoints1 = valid_points{i}(indexPairs(:,1),:);
matchedPoints2 = valid_points{i+1}(indexPairs(:,2),:);

subplot(1,3,3)
showMatchedFeatures(im{i},im{i+1},matchedPoints1,matchedPoints2);

end
toc


