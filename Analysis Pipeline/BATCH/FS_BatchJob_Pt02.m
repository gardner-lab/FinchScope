function FS_BatchJob_Pt02()
% FS_BatchJob_Pt02.m

% Part one aligns data to song.
% Part two performs within trial, within day and across-day motion correction
% Part three performs ROI extraction



% Run thorough 5 Day Longitudinal studies, and directory and:
%  -- Within session alignment
%  -- Within day image alignment
%  -- Across day image alignment
%  -- Create STD and MAX images ( in order to manually check local alignment, and make XMASS tree images)


% Run in Root (animal ID) folder


%   Created: 2016/03/14
%   By: WALIII
%   Updated: 2016/03/14
%   By: WALIII

START_DIR_ROOT = pwd;

% Get a list of all files and folders in this folder.

files = dir(START_DIR_ROOT)
files(1:2) = [] % Exclude parent directories.
dirFlags = [files.isdir]% Get a logical vector that tells which is a directory.
subFolders = files(dirFlags)% Extract only those that are directories.


for i = 1:length(subFolders)
nextDir = strcat(subFolders(i).name,'/mat/extraction/mov')
try
  cd(nextDir)

FS_DFF_STD_Image(pwd,1);
catch
disp('could not enter file')
end
disp('Processing for day X moving to the next day')
cd(START_DIR_ROOT)
end


send_text_message('617-529-0762','Verizon', ...
         'Calculation Complete','FS_BatchJob_Pt02 has completed')
