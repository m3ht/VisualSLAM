function varargout = runsim(stepsOrData, pauseLength, makeVideo)

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

% Initalize Params
Param.initialStateMean = [180 50 0]';

% Maximum number of landmark
% observations per timestep.
Param.maxObs = 2;

% Number of landmarks per sideline
% of the field (the minimum is 3).
Param.nLandmarksPerSide = 4;

% Motion noise (in odometry space, see p.134 in book).
Param.alphas = [0.05 0.001 0.05 0.01].^2;

% Standard deviation of Gaussian sensor
% noise (independent of the distance).
Param.beta = [10, deg2rad(10)]; % [cm, rad]
Param.R = diag(Param.beta.^2);

% Step size between filter updates, can be less than 1.
Param.deltaT=0.1; % [s]

if ~isstruct(stepsOrData)
	% Generate a data set of motion
	% and sensor info consistent with
	% noise models.
	numSteps = stepsOrData;
	Data = generateScript(Param.initialStateMean, numSteps, Param.maxObs, Param.alphas, Param.beta, Param.deltaT);
else
	% Use a user supplied data
	% set from a previous run.
	Data = stepsOrData;
	numSteps = length(Data.time);
	global FIELDINFO;
	FIELDINFO = getfieldinfo(Param.nLandmarksPerSide);
end

State.Ekf.mu = Param.initialStateMean;
State.Ekf.Sigma = zeros(3);

if strcmp(Param.dataAssociation, 'known')
	determinants = {};
else
	hypothesis = [];
	ground_truth = [];
end

for t = 1:numSteps
	plotsim(t);

	u = getControl(t);
	z = getObservations(t);

	if strcmp(Param.slamAlgorithm, 'ekf')
		ekfpredict_sim(u);
		ekfupdate(z);
	elseif strcmp(Param.slamAlgorithm, 'fast')
		fastpredict_sim(u);
		fastupdate(z);
	end

	plotcov2d(State.Ekf.mu(1), State.Ekf.mu(2), State.Ekf.Sigma(State.Ekf.iR, State.Ekf.iR), 'blue', false, '', NaN, 3);
	plotmarker(State.Ekf.mu, 'red');

	for i = 1:length(State.Ekf.sL)
		iL = State.Ekf.iL{i};
		mu = [State.Ekf.mu(iL(1)); State.Ekf.mu(iL(2))];
		Sigma(1, :) = [State.Ekf.Sigma(iL(1), iL(1)) State.Ekf.Sigma(iL(1), iL(2))];
		Sigma(2, :) = [State.Ekf.Sigma(iL(2), iL(1)) State.Ekf.Sigma(iL(2), iL(2))];
		plotcov2d(mu(1), mu(2), Sigma, 'red', false, '', NaN, 3);
	end

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

function u = getControl(t)
	global Data;
	% 3x1 [drot1; dtrans; drot2]
	u = Data.noisefreeControl(:,t);
end

function z = getObservations(t)
	global Data;
	% Return Noisy Observations
	% 3xn [range; bearing; markerID];
	z = Data.realObservation(:,:,t);
	ii = find(~isnan(z(1,:)));
	z = z(:,ii);
end

function plotsim(t)
	global Data;

	NOISEFREE_PATH_COL = 'green';
	ACTUAL_PATH_COL = 'blue';

	NOISEFREE_BEARING_COLOR = 'cyan';
	OBSERVED_BEARING_COLOR = 'red';

	GLOBAL_FIGURE = 1;

	% Ground Truth
	x = Data.Sim.realRobot(1,t);
	y = Data.Sim.realRobot(2,t);
	theta = Data.Sim.realRobot(3,t);

	% Real Observation
	observation = Data.realObservation(:,:,t);

	% Noise-free Observation
	noisefreeObservation = Data.Sim.noisefreeObservation(:,:,t);

	figure(GLOBAL_FIGURE); clf; hold on; plotfield(observation(3,:));

	% Draw the ground truth.
	plot(Data.Sim.realRobot(1,1:t), Data.Sim.realRobot(2,1:t), 'Color', ACTUAL_PATH_COL);
	plotrobot( x, y, theta, 'black', 1, ACTUAL_PATH_COL);

	% Draw the noise-free motion command path.
	plot(Data.Sim.noisefreeRobot(1,1:t), Data.Sim.noisefreeRobot(2,1:t), 'Color', NOISEFREE_PATH_COL);
	plot(Data.Sim.noisefreeRobot(1,t), Data.Sim.noisefreeRobot(2,t), '*', 'Color', NOISEFREE_PATH_COL);

	for k=1:size(observation,2)
		rng = Data.Sim.noisefreeObservation(1,k,t);
		ang = Data.Sim.noisefreeObservation(2,k,t);
		noisy_rng = observation(1,k);
		noisy_ang = observation(2,k);

		% Indicate observed range and angle relative to actual position.
		plot([x x+cos(theta+noisy_ang)*noisy_rng], [y y+sin(theta+noisy_ang)*noisy_rng], 'Color', OBSERVED_BEARING_COLOR);

		% Indicate ideal noise-free range and angle relative to actual position.
		plot([x x+cos(theta+ang)*rng], [y y+sin(theta+ang)*rng], 'Color', NOISEFREE_BEARING_COLOR);
	end
end
