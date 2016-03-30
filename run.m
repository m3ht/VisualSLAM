function varargout = run(stepsOrData, choice, slam, da, pauseLength, makeVideo)
% RUN Vision-Based SLAM
%   RUN(ARG)
%   RUN(ARG, CHOICE, PAUSELENGTH)
%   RUN(ARG, CHOICE, PAUSELENGTH, DA)
%      ARG - is either the number of time steps, (e.g. 100 is
%            a complete circuit) or a data structure from a
%            previous run.
%      CHOICE - is either 'sim' or 'seg' for simulator
%               or Victoria Park data set, respectively.
%      DA - data assocation, is one of either:
%           'known' - only available in simulator
%           'nn'    - incremental maximum
%                     likelihood nearest neighbor
%           'nndg'  - nn double gate on landmark creation
%                     (throws away ambiguous observations)
%           'jcbb'  - joint compatability branch and bound
%      SLAM - The slam algorithm to use, choices are:
%             'ekf' - Extended Kalman Filter based SLAM.
%             'fast' - the FastSLAM 2.0 algorithm.
%      PAUSELEN - set to `inf`, to manually pause, o/w # of
%                 seconds to wait (e.g., 0.3 is the default).
%
%   [DATA, RESULTS] = RUN(ARG, CHOISE, PAUSELENGTH, DA)
%      DATA - an optional output and contains the data array
%             generated and/or used during the simulation.
%      RESULTS - an optional output that contains the results
%                of the SLAM agorithm after the final time step.
%
%   Note: more parameters can be controlled in
%         the run.m file itself via fields of
%         the Param structure.

addpath('./segway/');
addpath('./simuation/');

if ~exist('pauseLength', 'var') || isempty(pauseLength)
	pauseLength = [];
end
if ~exist('makeVideo', 'var') || isempty(makeVideo)
	makeVideo = false;
end

clear global Data;
clear global Param;
clear global State;

global Data;
global Param;
global State;

% SLAM Algorithm Type:
%   'ekf'  - Extended Kalman Filter SLAM
%   'fast' - Rao-Blackwellized Particle Filter
if ~exist('slam', 'var') || isempty(slam)
	slam = 'ekf';
end
Param.slamAglorithm = slam;

% Data Association Type:
%   known - only available in simulator
%   nn    - incremental maximum likelhood nearest neighbor
%   nndg  - nn double gate on landmark creation
%           (throws away ambiguous observations)
%   jcbb  - joint compatability branch and bound
if ~exist('da','var') || isempty(da)
	da = 'known';
end
Param.dataAssociation = da;

% Update Type:
%   batch  - Batch Updates
%   seq    - Sequential Updates
Param.updateMethod = 'seq';

% Simulator Type:
%    'sim' - Simulator
%    'seg' - New College
% data set, respectively.
if ~exist('choice', 'var') || isempty(choice)
	choice = 'sim';
end
Param.choice = choice;

% Size of bounding box for VP data set plotting.
Param.bbox = 0; % bbox = 20 [m] speeds up graphics

% Structure of global State variable
%===================================================
State.Ekf.t     = 0;          % time
State.Ekf.mu    = zeros(3,1); % robot initial pose
State.Ekf.Sigma = zeros(3,3); % robot initial covariance
State.Ekf.iR    = 1:3;        % 3 vector containing robot indices
State.Ekf.iM    = [];         % 2*nL vector containing map indices
State.Ekf.iL    = {};         % nL cell array containing indices of landmark i
State.Ekf.sL    = [];         % nL vector containing signatures of landmarks
State.Ekf.nL    = 0;          % scalar number of landmarks
%===================================================

switch lower(choice)
	case 'sim'
		Data = runsim(stepsOrData, pauseLength, makeVideo);
		if nargout > 1
			varargout{1} = Data;
			varargout{2} = State.Ekf;
		elseif nargout > 0
			varargout{2} = State.Ekf;
		end
	case 'seg'
		runseg(stepsOrData, pauseLength, makeVideo);
		if nargout > 0
			varargout{1} = State.Ekf;
		end
	otherwise
		error('Unrecognized Selection: "%s"', choice);
end

