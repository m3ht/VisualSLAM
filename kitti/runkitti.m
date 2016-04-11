function varargout = runkitti(dataDirectory, pauseLength, makeVideo)

global Param;
global Data;
global State;

if ~exist('pauseLength','var')
	pauseLength = 0.3; % seconds
end

if makeVideo
	try
		votype = 'avifile';
		vo = avifile('video.avi', 'fps', min(5, 1/pauseLength));
	catch
		votype = 'VideoWriter';
		vo = VideoWriter('video', 'Motion JPEG AVI');
		set(vo, 'FrameRate', min(5, 1/pauseLength));
		open(vo);
	end
end

if ~exist('dataDirectory','var') || isempty(dataDirectory)
	error('Please specify the base directory of the data.');
end

% ============ %
% Extract Data %
% ============ %

% Load odometry data.
Data.odometry = loadOxtsliteData(dataDirectory);

% Load the images from the left camera.
left_images_path = strcat(dataDirectory, 'image_00/data/');
left_images_filenames = dir(strcat(left_images_path, '*.png'));
Data.leftCameraImages = cell(length(left_images_filenames),1);
for i = 1:length(left_images_filenames)
	left_image_filename = strcat(left_images_path, left_images_filenames(i).name);
	Data.leftCameraImages{i} = imread(left_image_filename);
	Data.leftCameraImages{i} = histeq(Data.leftCameraImages{i});
end

% Load the images from the right camera.
right_images_path = strcat(dataDirectory, 'image_01/data/');
right_images_filenames = dir(strcat(right_images_path, '*.png'));
Data.rightCameraImages = cell(length(right_images_filenames),1);
for i = 1:length(right_images_filenames)
	right_image_filename = strcat(right_images_path, right_images_filenames(i).name);
	Data.rightCameraImages{i} = imread(right_image_filename);
	Data.rightCameraImages{i} = histeq(Data.rightCameraImages{i});
end

if length(left_images_filenames) ~= length(right_images_filenames)
	error('The number of images from the left anf right cameras is unequal.');
end

% Transform to poses to obitan ground truth.
Data.groundTruth = convertOxtsToPose(Data.odometry);

l = 0; % coordinate axis length
A = [0 0 0 1; 
	 l 0 0 1; 
	 0 0 0 1; 
	 0 l 0 1; 
	 0 0 0 1; 
	 0 0 l 1]';
figure(1);
axis equal;

% =================== %
% Initialize Paramers %
% =================== %

calibration_files_path = strcat(dataDirectory, 'calibration/');

% Extract the intrisic and extrinsic parameters of the cameras.
camera_calibration_filename = strcat(calibration_files_path, 'calib_cam_to_cam.txt');
Param.cameraCalibration = loadCalibrationCamToCam(camera_calibration_filename);

% Compute the transformation matrix to go from camera frame to IMU frame.
velodyne_to_camera_calibration_filename = strcat(calibration_files_path, 'calib_velo_to_cam.txt');
imu_to_velodyne_calibration_filename = strcat(calibration_files_path, 'calib_imu_to_velo.txt');

H_v_to_c = loadCalibrationRigid(velodyne_to_camera_calibration_filename);
H_i_to_v = loadCalibrationRigid(imu_to_velodyne_calibration_filename);

Param.H_c_to_i = inv(H_v_to_c*H_i_to_v);

% Max number of frame to accumulate in the accumulator.
Param.maxAccumulateFrames = 5;

% Max number of SURF descriptors to detect per image.
Param.maxSURFDescriptors = 200;

Param.minDisparity = 8;
Param.maxDisparity = 55;

% Initalize Params
Param.initialStateMean = [0; 0; 0];

% Motion Noise
Param.alphas = [0.1, 0.1]; % [m/s,rad/s]
Param.R = diag(Param.alphas.^2);

% Measurement Noise
Param.beta = [3, 3, 6]; % [pixel, pixel, units]
Param.Q = diag(Param.beta.^2);

% Step size between filter updates (seconds).
Param.deltaT= 0.1;

% Total number of particles to use.
if ~strcmp(Param.slamAlgorithm, 'ekf')
	Param.M = 10;
end

Param.maxTimeSteps = length(Data.odometry');

% ==================== %
% State Initialization %
% ==================== %
State.Fast.particles = cell(Param.M,1);
for i = 1:Param.M
	State.Fast.particles{i}.x = Param.initialStateMean;
	State.Fast.particles{i}.mu = [];
	State.Fast.particles{i}.Sigma = [];
	State.Fast.particles{i}.weight = 1/Param.M;
	State.Fast.particles{i}.sL = [];
	State.Fast.particles{i}.iL = [];
	State.Fast.particles{i}.nL = 0;
end

for t = 1:Param.maxTimeSteps
	% ================= %
	% Plot Ground Truth %
	% ================= %
	B = Data.groundTruth{t}*A;
	figure(1); plotMarker([B(1,1),B(2,1)],'blue');

	% =========== %
	% Filter Info %
	% =========== %
	u = getControl(t);
	[points, descriptors] = fast1_accumulator_kitti(t);
	z = fast1_get_observations_kitti(t, points, descriptors);

	% ========== %
	% Run Filter %
	% ========== %
	fast1_predict_kitti(u);
	fast1_update_kitti(z);

	figure(1); plotParticles(State.Fast.particles);

	drawnow;
	if pauseLength > 0
		pause(pauseLength);
	end

	if makeVideo
		F = getframe(gcf);
		switch votype
		case 'avifile'
			vo = addframe(vo, F);
		case 'VideoWriter'
			writeVideo(vo, F);
		otherwise
			error('Unrecognized Video Type!');
		end
	end
end

if nargout >= 1
	varargout{1} = Data;
end

end % function

function u = getControl(t)
	global Data;
	oxts = Data.odometry(t);
	u = [oxts{1}(9);oxts{1}(23)];
end
