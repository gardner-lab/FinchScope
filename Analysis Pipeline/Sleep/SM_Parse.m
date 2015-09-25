
function SM_Parse(DIR,varargin)



mat_dir='mat';
Dff_dir='Dff';


if exist(mat_dir,'dir') rmdir(mat_dir,'s'); end
if exist(Dff_dir,'dir') rmdir(Dff_dir,'s'); end

mkdir(mat_dir);
mkdir(Dff_dir);




outlier_flag=0;
if nargin<1 | isempty(DIR), DIR=pwd; end

mov_listing=dir(fullfile(DIR,'*.tif'));
mov_listing={mov_listing(:).name};



filenames=mov_listing;


disp('Parsing Tif files');

[nblanks formatstring]=fb_progressbar(100);
fprintf(1,['Progress:  ' blanks(nblanks)]);

for i=1:length(mov_listing)

    [path,file,ext]=fileparts(filenames{i});

    
	fprintf(1,formatstring,round((i/length(mov_listing))*100));
    FILE = fullfile(DIR,mov_listing{i})
%     [video, audio] = mmread(FILE)

info = imfinfo(FILE);
num_images = numel(info);
for k = 1:num_images
    A = imread(FILE, k, 'Info', info);
%     A = imresize(A,.5);
    video.frames(k).cdata = A;
end


		save(fullfile(mat_dir,[file '.mat']),'video','-v7.3');



end
fprintf(1,'\n');