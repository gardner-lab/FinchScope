
function FS_Tiff_Parse(DIR,varargin)

mat_dir='mat';

if exist(mat_dir,'dir') 
    rmdir(mat_dir,'s'); 
end

mkdir(mat_dir);

outlier_flag=0;
if nargin<1 | isempty(DIR), DIR=pwd; end

mov_listing=dir(fullfile(DIR,'*.tif'));
mov_listing={mov_listing(:).name};

filenames=mov_listing;

disp('Parsing Tif files');

for i=1:length(mov_listing)

    [~,file,~]=fileparts(filenames{i});
    file
	FILE = fullfile(DIR,mov_listing{i});

info = imfinfo(FILE);
num_images = numel(info);

for k = 1:num_images
    A = imread(FILE, k, 'Info', info);
    video.frames(k).cdata = A;
end

		save(fullfile(mat_dir,[file '.mat']),'video','-v7.3');

end
fprintf(1,'\n');