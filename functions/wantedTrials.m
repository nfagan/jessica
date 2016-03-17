% wantedTrials.m - function for separating trial data by reward
% outcome and foraging time
%
% Required inputs:
%
%       outcomes - 'self', 'both', 'other', 'neither', 'pro', or 'anti',
%           where 'pro' is ('both' & 'other') and 'anti' is ('self' &
%           neither')
%       forageLength - 'short' or 'long'. You'll want to edit this function
%           to indicate which times pertain to 'short' vs. 'long'
%       completedForage - 1, 0, or []. Specify whether extracted data
%           includes [1] only trials in which foraging was completed; [0]
%           only trials in which foraging *was not* completed; [] all trials,
%           regardless of whether foraging was completed.
%
% Optional inputs - specify these in 'name','value' pairs; e.g.:
%   trials = wantedTrials(...,'trialTypes','choice');
%       
%       'startDir' - optionally specify the directory housing
%           the .txt files you want to analyze. If you know you'll always
%           store the files in one place, you can edit this function such
%           that startDir defaults to some directory.  
%       'trialTypes' - 'choice' (default) or 'cued', or any other string value to
%           include all trials.
%       'rewardMag' - optionally separate by reward magnitude. By default,
%       	all reward mag values will be included; set 'rewardMag',[1] for
%       	small rewards, 'rewardMag',[2], for med rewards, ... etc.

function extrData = wantedTrials(outcomes,forageLength,completedForage,varargin)

% -- extract optional params -- 

params = struct(...
    'rewardMag','all',...
    'trialTypes','choice', ...
    'stimColor','all', ...
    'startDir',[] ...
    );

params = structInpParse(params,varargin);

% -- load files --

if isempty(params.startDir);
    startDir = ('/Volumes/My Passport/NICK/Chang Lab 2016/jessica');
else
    startDir = params.startDir;
end

cd(startDir);

files = dir('*.txt'); %get all data files (.txt) in current directory

storeFile = cell(1,length(files)); %preallocate storeFile
for i = 1:length(files);
    storeFile{i} = dlmread(files(i).name); %storeFile is a cell array where
                                           %each cell is a file
end
concatFiles = concatenateData(storeFile);  %transform cell array to one matrix
                                           %housing all of the data
                                           
% -- define forage times as short v. long --

switch forageLength
    case 'short'
        forageTimes = 0;
    case 'long'
        forageTimes = [100 350 700]; 
end
                                           
% -- get index of completed foraging --

if completedForage == 1;
    foraged = concatFiles(:,9) ~= 0; %find trials where rwd mag was *not* empty
elseif completedForage == 0;
    foraged = concatFiles(:,9) == 0; %find trials where rwd mag *was* empty
else
    foraged = ones(size(concatFiles,1),1); %else keep all trials
end

% -- get index of desired fix times --

forageTimeInds = zeros(size(concatFiles,1),length(forageTimes));
for i = 1:length(forageTimes); %determine which foraging times equal the 
                               %current foraging time, as pulled from
                               %forageTimes
    forageTimeInds(:,i) = concatFiles(:,11) == forageTimes(i);
end
forageTimeInds = sum(forageTimeInds,2); %create one index of desired foraging times

% -- get index of reward outcomes --

cueType = concatFiles(:,5);
fixedOn = concatFiles(:,8);

self = (cueType == 0 & fixedOn == 1) | (cueType == 1 & fixedOn == 1); %check to confirm these!!!
both = (cueType == 0 & fixedOn == 2) | (cueType == 1 & fixedOn == 2);
other = (cueType == 2 & fixedOn == 1) | (cueType == 3 & fixedOn == 2); 
neith = (cueType == 2 & fixedOn == 2) | (cueType == 3 & fixedOn == 1);

switch outcomes
    case 'self'
        outInd = self;
    case 'both'
        outInd = both;
    case 'other'
        outInd = other;
    case 'neither'
        outInd = neith;
    case 'pro'
        outInd = both | other;
    case 'anti'
        outInd = self | neith;
end

% -- get index of choice trials -- 

if strcmp(params.trialTypes,'choice')
    trialTypeInd = logical(concatFiles(:,2));
elseif strcmp(params.trialTypes,'cued');
    trialTypeInd = ~logical(concatFiles(:,2));
else
    trialTypeInd = ones(size(concatFiles,1),1);
end

% -- get index of stim colors --

if strcmp(params.stimColor,'all');
    stimColorInd = ones(size(concatFiles,1),1);
else
    %%% fill in
    stimColorInd = ones(size(concatFiles,1),1);
end

% -- get index of desired reward magnitude --

if strcmp(params.rewardMag,'all')
    rewardMagInd = ones(size(concatFiles,1),1);
else
    rewardMagInd = concatFiles(:,9) == params.rewardMag;
end

% -- extract desired data --

allInds = outInd & foraged & forageTimeInds & trialTypeInd & ...
    rewardMagInd & stimColorInd;
extrData = concatFiles(allInds,:);











    