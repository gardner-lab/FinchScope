function FS_SortMotif2
% Sort each .mat file by its identified motif in the .mat file

mat_dir=[pwd,'/', 'MOTIF2'];
counter = 1;
 if exist(mat_dir,'dir'); rmdir(mat_dir,'s'); end
mkdir(mat_dir);
Dir01 = strcat(mat_dir,'/Motif_first');
Dir02 = strcat(mat_dir,'/Motif_second');
Dir03 = strcat(mat_dir,'/Motif_third');
Dir04 = strcat(mat_dir,'/Motif_fourth');
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

    if motif ==1;
        copyfile(filenames{iii},Dir01);
    elseif motif == 2;
        copyfile(filenames{iii},Dir02); 
    elseif motif == 3;
        copyfile(filenames{iii},Dir03);
    elseif motif == 4;
        copyfile(filenames{iii},Dir04);
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
