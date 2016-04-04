function data = generatedata(initialStateMean, numSteps, maxObservations, alphas, beta, deltaT)
%generateData: Simulates the trajectory of the robot using
%              a square path given by generateMotion.
%
% data = generateData(initialstatemean,numSteps,alphas,betas)
%     generates data of the form
%     [realObservation',
%      noisefreeMotion',
%      noisefreeObservation',
%      realRobot',
%      noisefreeRobot']
%
% realObservation and noisefreeMotion are the only data available
% to the filter. All other data are for debugging/display purposes.
%
% alphas: the 4-d noise for robot motion
% beta: noise for observations

motionDim = 3;
observationDim = 3;

realRobot = initialStateMean;
noisefreeRobot = initialStateMean;

global Param;

nSideMarks = 3;
global FIELDINFO;
FIELDINFO = getFieldInfo(Param.nLandmarksPerSide);

data.time = zeros(1, numSteps);
data.noisefreeControl = zeros(motionDim, numSteps);
data.realObservation = nan(observationDim, maxObservations, numSteps);
data.Sim.realRobot = zeros(motionDim, numSteps);
data.Sim.noisefreeRobot = zeros(motionDim, numSteps);
data.Sim.noisefreeObservation = nan(observationDim, maxObservations, numSteps);

for n = 1:numSteps
	%----------------
	% Simulate Motion
	%----------------
	t = n*deltaT;
	noisefreeMotion = generateMotion(t,deltaT);

	% Shift real robot
	prevNoisefreeRobot = noisefreeRobot;
	noisefreeRobot = sampleOdometry(noisefreeMotion, noisefreeRobot, [0 0 0 0]);

	% Move robot
	realRobot = sampleOdometry(noisefreeMotion, realRobot, alphas);

	%---------------------
	% Simulate Observation
	%---------------------

	% Observation noise
	Q = diag([beta.^2, 0]);

	% Select landmarks for sensing
	noisefreeObservation = senseLandmarks(realRobot, maxObservations, FIELDINFO);
	numObs = size(noisefreeObservation,2);
	realObservation = nan(size(noisefreeObservation));
	for k = 1:numObs
		observationNoise = sample( zeros(observationDim,1), Q, observationDim);
		realObservation(:,k) = noisefreeObservation(:,k) + observationNoise;
	end

	data.time(n) = t;
	data.noisefreeControl(:,n) = noisefreeMotion;
	data.realObservation(:,1:numObs,n) = realObservation;
	data.Sim.realRobot(:,n) = realRobot;
	data.Sim.noisefreeRobot(:,n) = noisefreeRobot;
	data.Sim.noisefreeObservation(:,1:numObs,n) = noisefreeObservation;
end

end % function

function noisefreeObservation = senseLandmarks(realRobot, maxObservations, FIELDINFO, fov)
	M = FIELDINFO.NUM_MARKERS;
	noisefreeObservation = zeros(3, M);
	for m=1:M
		noisefreeObservation(:,m) = observation( realRobot, FIELDINFO, m);
	end

	% Orders landmarks with mininum bearing angle w.r.t robot.
	[dummy, ii] = sort(abs(noisefreeObservation(2,:)));
	noisefreeObservation = noisefreeObservation(:,ii);

	% Keeps those within front plane.
	ii = find(-pi/2 < noisefreeObservation(2,:) & noisefreeObservation(2,:) < pi/2);
	if length(ii) <= maxObservations
		noisefreeObservation = noisefreeObservation(:,ii);
	else
		noisefreeObservation = noisefreeObservation(:,1:maxObservations);
	end
end
