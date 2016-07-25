function FS_MotifSort
% Sort each .mat file by its identified motif

% mat_dir='DFF_Images2';
counter = 1;
% if exist(mat_dir,'dir'); rmdir(mat_dir,'s'); end
% mkdir(mat_dir);
Dir01 = strcat(mat_dir,'/Motif01');
Dir02= strcat(mat_dir,'/Motif02');
Dir03 = strcat(mat_dir,'/Motif03');
Dir04 = strcat(mat_dir,'/Motif_other');
Dir05 = strcat(mat_dir,'/Motif_first');
Dir06 = strcat(mat_dir,'/Motif_last');


mkdir(MaxDir);
mkdir(StdDir);


outlier_flag=0;
if nargin<1 | isempty(DIR), DIR=pwd; end
mov_listing=dir(fullfile(DIR,'*.mat'));
mov_listing={mov_listing(:).name};
filenames=mov_listing;


disp('Creating Dff movies');

[nblanks formatstring]=fb_progressbar(100);
fprintf(1,['Progress:  ' blanks(nblanks)]);

for i=1:length(mov_listing)
clear video;
