function FS_BatchJob_Pt02_B()
% FS_BatchJob_Pt02.m

% Part one aligns data to song.
% * Part two performs within trial, within day and across-day motion correction
% Part three performs ROI extraction



% Run thorough 5 Day Longitudinal studies, and directory and:
%  -- Within session alignment ** not in place
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
      catch
        disp(' could not enter DIR...')
      end

% Make subdirectories:
    MaxDir = strcat(nextDir,'/MAX')
    StdDir = strcat(nextDir,'/STD')
    mkdir(MaxDir);
    mkdir(StdDir);
% Go to new Dir:
      cd(nextDir)
    mov_listing=dir(fullfile(pwd,'*.mat')); % Get all .mat file names
    mov_listing={mov_listing(:).name};
    filenames=mov_listing;


  for ii=1:length(mov_listing) % for all .mat files in directory,
      clear mov_data; % Make sure the buffer is clear...

        [path,file,ext]=fileparts(filenames{ii});
            load(fullfile(pwd,mov_listing{ii}),'mov_data');

        for iii = 1:size(mov_data,2) % Load in data
          mov_data2(:,:,iii) = rgb2gray(mov_data(iii).cdata(:,:,:,:)); % convert to
        end

        MaxProj(:,:,ii) = max(mov_data2,[],3); % Take MAx projection of the video

                %  clear mov_data2; clear mov_data;

                disp('Performing Motion Correction transform calculation on Within day');

                % TO DO: ** do we want to do an average here?

      [optimizer, metric] = imregconfig('multimodal');
        for ii = 1:size(mov_data2,3)
          tform = imregtform(MaxProj(:,:,ii),MaxProj(:,:,1),'rigid',optimizer,metric); % Compare Max projections to the first video
          mov_data3(:,:,ii) = imwarp(mov_data2(:,:,ii),tform,'OutputView',imref2d(size(X2))); % align frames locally
          mov_data_aligned(ii).cdata(:,:,:) = mov_data2(:,:,ii); %% keep this data propogating through function....
        end

        X3(:,:,i) = mean(MaxProj2,3); % Take the mean of the aligned max projection for across day alignment....

       % SAVE the data in the matlab structure..
        mov_data_aligned =  []; % clear out the variable....
          save(fullfile(path,[file '.mat']),'mov_data_aligned','-append');
        mov_data_aligned =  mov_data_aligned_actual;
          save(fullfile(path,[file '.mat']),'mov_data_aligned','-append'); % store data here temporarily...

  end

disp('Performing Motion Correction transform calculation across days');
X5 = X3(:,:,1); % Take the first days's aligned, mean projeciton....


tform = imregtform(X3(:,:,ii),X3(:,:,1),'rigid',optimizer,metric); %create transform for Max projection comparison across days
  %%--- Loop through each movie and perform intensity based image correction, based on aligning the average max projection.
  for  iii = 1:length(mov_listing)
        clear mov_data_aligned; clear mov_data2; clear mov_data; % Clear out remining buffer...
       [path,file,ext]=fileparts(filenames{iii});
           load(fullfile(pwd,mov_listing{iii}),'mov_data_aligned');

          for ii = 1:size(mov_data_aligned,2)
            mov_data_aligned_actual(ii).cdata(:,:,:) = imwarp(mov_data_aligned(ii).cdata(:,:,:),tform,'OutputView',imref2d(size(X5))); % Align Video
          end


          mov_data_aligned =  []; % clear out the variable....
            save(fullfile(path,[file '.mat']),'mov_data_aligned','-append');
          mov_data_aligned =  mov_data_aligned_actual;
            save(fullfile(path,[file '.mat']),'mov_data_aligned','-append'); % store data here temporarily...

            FS_Write_IM(MaxDir,StdDir,file,mov_data_aligned)
         clear mov_data_aligned_actual;   clear mov_data_aligned;
   end

   cd(START_DIR_ROOT)
   clear mov_listing; clear filenames;

end


send_text_message('617-529-0762','Verizon', ...
         'Calculation Complete','FS_BatchJob_Pt02 has completed')
