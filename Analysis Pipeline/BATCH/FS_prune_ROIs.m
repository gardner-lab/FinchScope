function FS_prune_ROIs(ROI_dat)

% go through gif and max proj folders, and eliminate traces
% Step one: Load in ROIs for the day.



% Root is where the script is run...
START_DIR_ROOT = pwd;

myfile = '/template/template_data.mat';
[parentdir,~,~]=fileparts(START_DIR_ROOT);

% Get a list of all files and folders in this folder.

files = dir(START_DIR_ROOT)
files(1:2) = [] % Exclude parent directories.
dirFlags = [files.isdir]% Get a logical vector that tells which is a directory.
subFolders = files(dirFlags)% Extract only those that are directories.









for i = 1:length(subFolders)
  cd(START_DIR_ROOT);
  clear nextDir
  nextDir = strcat(subFolders(i).name,'/dff')
  cd(nextDir)

  counter = 1;
  clear NowROI; clear gifListing; clear gifListing2;
    

     gifListing = dir(fullfile(pwd,'*tif'));
     gifListing = {gifListing(:).name};
     for ii = 1:length(gifListing);
     gifListing2{ii} = gifListing{ii}(1:end-8);
     end
     
     
     disp('Extracting good gif trials');
     
   for ii = 1:length(ROI_dat{i}.filename)
         

s1 = ROI_dat{i}.filename{ii};
s1 = s1(1:end-4);
s2 = gifListing2;
tf = strcmp(s1,s2);
disp(max(tf));
clear s1; clear s2; 

if max(tf) ==1;
NewROI_dat{i}.analogIO_dat{1,counter} = ROI_dat{i}.analogIO_dat{1,ii};
NewROI_dat{i}.analogIO_time{1,counter} = ROI_dat{i}.analogIO_time{1,ii};
NewROI_dat{i}.interp_time{1,counter} = ROI_dat{i}.interp_time{1,ii};
for iv = 1:size(ROI_dat{1}.interp_dff,1)
NewROI_dat{i}.interp_dff{iv,counter} = ROI_dat{i}.interp_dff{iv,ii};
NewROI_dat{i}.interp_raw{iv,counter} = ROI_dat{i}.interp_raw{iv,ii};
NewROI_dat{i}.raw_time{iv,counter} = ROI_dat{i}.raw_time{iv,ii};
NewROI_dat{i}.raw_dat{iv,counter} = ROI_dat{i}.raw_dat{iv,ii};
end
NewROI_dat{i}.filename{1,counter} = ROI_dat{i}.filename{1,ii};

counter = counter+1;

end
clear tf;

     end
     clear NowROI;
     ROI_dat_New = NewROI_dat;
end

cd(START_DIR_ROOT);
save('ROI_dat_edited','ROI_dat_New')

