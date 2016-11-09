function FS_MotifSort
% Sort each .mat file by its identified motif

mat_dir='MOTIF';
counter = 1;
 if exist(mat_dir,'dir'); rmdir(mat_dir,'s'); end
mkdir(mat_dir);
Dir01 = strcat(mat_dir,'/Motif_first');
Dir02 = strcat(mat_dir,'/Motif_Middle');
Dir03 = strcat(mat_dir,'/Motif_last');
Dir04 = strcat(mat_dir,'/Motif_only');
mkdir(Dir01);
mkdir(Dir02);
mkdir(Dir03);
mkdir(Dir04);






outlier_flag=0;
if nargin<1 | isempty(DIR), DIR=pwd; end
mov_listing=dir(fullfile(DIR,'*.mat'));
mov_listing={mov_listing(:).name};
filenames=mov_listing;




[nblanks formatstring]=fb_progressbar(100);
fprintf(1,['Progress:  ' blanks(nblanks)]);


mov_listing=dir(fullfile(pwd,'*.mat')); % Get all .mat file names
mov_listing={mov_listing(:).name};
filenames=mov_listing;
DIR = pwd;


for  iii = 1:length(mov_listing)

  [path,file,ext]=fileparts(filenames{iii});
	load(fullfile(DIR,mov_listing{iii}),'mov_data','motif');

    try
  if motif ==1;
    if filenames{iii}(1:end-9) == filenames{iii+1}(1:end-9)
      copyfile(filenames{iii},Dir01); % if this is in the beginning of a series, put it in the 01 folder
    else
      copyfile(filenames{iii},Dir04); % if tthere is only one, put it in the only folder
    end
  else
    if filenames{iii}(1:end-9) == filenames{iii+1}(1:end-9)
      copyfile(filenames{iii},Dir02); % if this is in the middle of a series, put it in the middle
    else
      copyfile(filenames{iii},Dir03); % if not, put it at the end.
    end
  end
    catch
if motif ==1;
copyfile(filenames{iii},Dir01);
else
  copyfile(filenames{iii},Dir03);
end

    end

end

disp( 'Making Dff Images....');
H = {Dir01,Dir02,Dir03,Dir04};
Here = pwd;

for i = 1:size(H,2);
cd(H{i});
FS_DFF_STD_Image;
cd(Here);
disp( 'Moving to next Directory.....');
end

% Make DFF videos
