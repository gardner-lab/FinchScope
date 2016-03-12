function FS_BatchJob_Pt01()
% FS_BatchJob_Pt01.m


% Run thorough 5 Day Longitudinal studies, and directory and:
%  -- Template Match (Based on a template stored in some subfolder)
%  -- Send a text when manual intervention is required (song clustering)
%  -- Local image alignment
%  -- Make STD and MAX images ( in order to check local alignment)

% Subfolder contents
%  -- Template
% This Script is the pre-processing for batch-ROIs (  )


%   Created: 2016/03/09
%   By: WALIII
%   Updated: 2016/03/10
%   By: WALIII



[nblanks formatstring]=fb_progressbar(100);
fprintf(1,['Progress:  ' blanks(nblanks)]);

% Root is where the script is run...
START_DIR_ROOT = pwd;
% Get a list of all files and folders in this folder.

files = dir(START_DIR_ROOT)
files(1:2) = []
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir]
% Extract only those that are directories.
subFolders = files(dirFlags)
% Print folder names to command window.
for k = 1 : length(subFolders)
	% fprintf('Sub folder #%d = %s\n', k, subFolders(k).name);
  nextDir = strcat(subFolders(k),'/mat')
  cd(nextDir)
FS_Batch_TemplateMatch
disp('moving to the next day')

end






START_DIR_ROOT = pwd;
day_listing=dir(fullfile(pwd,'*.mat'));


current_path = strcat(START_DIR_ROOT,'/',BOX_ID{i});

mov_listing={mov_listing(:).name};
filenames=mov_listing;


disp('Creating .tif movies');
