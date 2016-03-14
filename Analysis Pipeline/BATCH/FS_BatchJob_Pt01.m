function FS_BatchJob_Pt01()
% FS_BatchJob_Pt01.m

% Part one aligns data to song.
% Part two performs within trial, within day and across-day motion correction
% Part three performs ROI extraction



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



% [nblanks formatstring]=fb_progressbar(100);
% fprintf(1,['Progress:  ' blanks(nblanks)]);


% Root is where the script is run...
START_DIR_ROOT = pwd;

myfile = '/template/template_data.mat';
[parentdir,~,~]=fileparts(START_DIR_ROOT);

load(fullfile(START_DIR_ROOT,myfile),'TEMPLATE');


% Get a list of all files and folders in this folder.

files = dir(START_DIR_ROOT)
files(1:2) = [] % Exclude parent directories.
dirFlags = [files.isdir]% Get a logical vector that tells which is a directory.
subFolders = files(dirFlags)% Extract only those that are directories.


for i = 1:length(subFolders)
  clear nextDir
  nextDir = strcat(subFolders(i).name,'/mat')

try
    cd(nextDir)
catch
  disp('could not enter file...')
end


try
FS_BatchJob_TemplateMatch(TEMPLATE)
catch
  disp('could not match template')
end
disp('Processing for day X moving to the next day')
cd(START_DIR_ROOT)
end

send_text_message('617-529-0762','Verizon', ...
         'Calculation Complete','FS_BatchJob_Pt01 has completed')
