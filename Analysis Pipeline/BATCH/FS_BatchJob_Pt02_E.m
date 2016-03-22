function FS_BatchJob_Pt02_E()
% FS_BatchJob_Pt02_D.m

% This variant is the most riggoius ofr motion correction, designed for LNY13


% Part one aligns data to song.
% * Part two performs within trial, within day and across-day motion correction
% Part three performs ROI extraction



% Run thorough 5 Day Longitudinal studies, and directory and:
%  -- Within session alignment
%  -- Within day image alignment (using selected  MAX projection )
%  -- Across day image alignment (using selected  MAX projection )
%  -- Create STD and MAX images ( in order to manually check local alignment, and make XMASS tree images)


% Run in Root (animal ID) folder


%   Created: 2016/03/14
%   By: WALIII
%   Updated: 2016/03/19
%   By: WALIII


%%========================================%%




START_DIR_ROOT = pwd;

% Get a list of all files and folders in this folder.
files = dir(START_DIR_ROOT)
files(1:2) = [] % Exclude parent directories.
dirFlags = [files.isdir]% Get a logical vector that tells which is a directory.
subFolders = files(dirFlags)% Extract only those that are directories.


for i = 1:length(subFolders)
      cd(START_DIR_ROOT);
      clear nextDir; clear mov_listing; clear filenames;

      try % in case there are Directories you can't enter...
        nextDir = strcat(subFolders(i).name,'/mat/extraction/mov')
        cd(nextDir);
      catch
        disp(' could not enter DIR...')
      end

% Make subdirectories:
    MaxDir = ('MAX')
    StdDir = ('STD')
    
if exist(MaxDir,'dir'); rmdir(MaxDir,'s'); end; mkdir(MaxDir);
if exist(StdDir,'dir'); rmdir(StdDir,'s'); end; mkdir(StdDir);
%     mkdir(MaxDir);
%     mkdir(StdDir);
% Go to new Dir:

    mov_listing=dir(fullfile(pwd,'*.mat')); % Get all .mat file names
    mov_listing={mov_listing(:).name};
    filenames=mov_listing;


  % for ii=1:length(mov_listing) % for all .mat files in directory,
  %     clear mov_data2; clear mov_data3; clear mov_data; clear mov_data_aligned; clear mov_data_aligned_actual; % Make sure the buffer is clear...
if i == 1;
        [path,file,ext]=fileparts(filenames{1});
            load(fullfile(pwd,mov_listing{1}),'mov_data');
        for iii = 1%:size(mov_data,2) % Load in data
          mov_data2(:,:,iii) = rgb2gray(mov_data(iii).cdata(:,:,:,:)); % convert to
        end
        MaxProj(:,:,1) = max(mov_data2,[],3); % Take MAx projection of the video
        disp('Performing Motion Correction transform calculation for the first day');
end






disp('Performing Motion Correction transform calculation across days');
% X5 = X3(:,:,1); % Take the first days's aligned, mean projeciton....
%

%tform = imregtform(X3(:,:,i),X3(:,:,1),'rigid',optimizer,metric); %create transform for Max projection comparison across days
  %%--- Loop through each movie and perform intensity based image correction, based on aligning the average max projection.
  for  iii = 1:length(mov_listing)
        clear mov_data_aligned; clear mov_data2; clear mov_data; clear mov_data_actual; clear mov_data3; % Clear out remining buffer...
       [path,file,ext]=fileparts(filenames{iii});
           load(fullfile(pwd,mov_listing{iii}),'mov_data');

           for iiv = 1:size(mov_data,2) % Load in data
             mov_data2(:,:,iiv) = rgb2gray(mov_data(iiv).cdata(:,:,:)); % convert to
           end

           for ii = 1:size(mov_data,2)
           [temp Greg] = dftregistration(fft2(MaxProj(:,:,1)),fft2(mov_data2(:,:,ii)),100);
           mov_data_aligned_actual(ii).cdata(:,:,:) = abs(ifft2(Greg)); %% keep this data propogating through function....
           end


          mov_data_aligned =  []; % clear out the variable....
            save(fullfile(path,[file '.mat']),'mov_data_aligned','-append');
          mov_data_aligned =  mov_data_aligned_actual;
            save(fullfile(path,[file '.mat']),'mov_data_aligned','-append'); % store data here temporarily...

            FS_Write_IM(file,mov_data_aligned)
         clear mov_data_aligned_actual;   clear mov_data_aligned;
   end

   cd(START_DIR_ROOT)
   clear mov_listing; clear filenames; clear path; clear file;

end


send_text_message('617-529-0762','Verizon', ...
         'Calculation Complete','FS_BatchJob_Pt02 has completed')
