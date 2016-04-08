S = pwd;
S = strcat(S ,'/StereoImages/images/*.jpg');
fileNames = dir(S);
numImages = length(fileNames);
imageName=cell(numImages,1);
for i=1:numImages
    imageName{i} = fileNames(i).name;
end





left_color = imread(strcat('./StereoImages/images/',imageName{1}));
left=rgb2gray(left_color);
left = im2double(left);

points = detectSURFFeatures(left);
left_points = points.selectStrongest(50);

subplot(1,3,1)
imshow(left); hold on;
left_points.plot('showOrientation',true);