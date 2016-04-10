function varargout = run(stepsOrData, dataType, slam, da, updateMethod, pauseLength, makeVideo)
% RUN Vision-Based SLAM
%   RUN(ARG, DATATYPE, SLAM, DA, UPDATEMETHOD, PAUSELENGTH, MAKEVIDEO)
%      ARG - is either the number of time steps, (e.g. 100 is
%            a complete circuit) or a data structure from a
%            previous run.
%      DATATYPE - is either 'sim' or 'kitti' for simulator
%                 or Victoria Park data set, respectively.
%      SLAM - The slam algorithm to use, choices are:
%             'ekf' - Extended Kalman Filter based SLAM.
%             'fast1' - the FastSLAM 1.0 algorithm.
%      DA - data assocation, is one of either:
%           'known' - only available in simulator
%           'nn'    - incremental maximum
%                     likelihood nearest neighbor
%           'nndg'  - nn double gate on landmark creation
%                     (throws away ambiguous observations)
%           'jcbb'  - joint compatability branch and bound
%      UPDATEMETHOD - The tpye of update that should happen
%                     during the correction. Choices are:
%           'batch'  - Batch Updates
%           'seq'    - Sequential Updates
%      PAUSELENGTH - set to `inf`, to manually pause, o/w # of
%                    seconds to wait (e.g., 0.3 is the default).
%
%   [DATA, RESULTS] = RUN(ARG, CHOISE, PAUSELENGTH, DA)
%      DATA - an optional output and contains the data array
%             generated and/or used during the simulation.
%      RESULTS - an optional output that contains the results
%                of the SLAM agorithm after the final time step.

addpath('./kitti/');
addpath('./simulation/');
addpath('./simulation/utils/');
addpath('./tools/');
addpath('./kitti/test');
addpath('./kitti/data/matlab');

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

% Data Type
if ~exist('dataType', 'var') || isempty(dataType)
	dataType = 'sim';
end
Param.dataType = dataType;

% Data Type Error Check
if and(~strcmp(Param.dataType, 'sim'), ~strcmp(Param.dataType, 'kitti'))
	error('Unknown data type: %s', Param.dataType);
end

% SLAM Algorithm Type
if or(~exist('slam', 'var'), isempty(slam))
	slam = 'ekf';
end
Param.slamAlgorithm = slam; 

% SLAM Algorithm Error Check
switch lower(Param.slamAlgorithm)
case {'ekf', 'fast1'}
	% Correct: Pass
otherwise
	error('Unknown SLAM algorithm: %s', Param.slamAlgorithm);
end

addpath(strcat('./simulation/', Param.slamAlgorithm));

% Data Association Type
if or(~exist('da','var'), isempty(da))
	da = 'known';
end
Param.dataAssociation = da;

% Data Association Error Check
switch lower(Param.dataAssociation)
case {'known', 'nn', 'nndg', 'jcbb'}
	% Correct: Pass
otherwise
	error('Unknown data association: %s', Param.dataAssociation);
end

% Update Type
if or(~exist('updateMethod', 'var'), isempty(updateMethod))
	updateMethod = 'seq';
end
Param.updateMethod = updateMethod;

% Update Type Error Check
if and(~strcmp(Param.updateMethod, 'batch'), ~strcmp(Param.updateMethod, 'seq'))
	error('Unkown update method: %s', Param.updateMethod);
end

% Size of bounding box for VP data set plotting.
Param.bbox = 0; % bbox = 20 [m] speeds up graphics

switch lower(dataType)
	case 'sim'
		Data = runsim(stepsOrData, pauseLength, makeVideo);
		if nargout > 1
			varargout{1} = Data;
			varargout{2} = State;
		elseif nargout > 0
			varargout{2} = State;
		end
	case 'kitti'
		runkitti(pauseLength, makeVideo);
		if nargout > 0
			varargout{1} = State;
		end
	otherwise
		error('Unrecognized Selection: "%s"', choice);
end

