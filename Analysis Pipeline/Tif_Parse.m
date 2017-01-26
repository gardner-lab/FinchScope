
function Tif_Parse(DIR,varargin)
  % Tif_Parse

  % Parse Data from Tif stacks into MATLAB
  %   Created: 2016/02/12
  %   By: WALIII
  %   Updated: 2016/02/15
  %   By: WALIII

  % Tif_parse will do several things:
  %
  %   1. Put Tif files into .mat files, such that theey will work with the FreedomScope
  %      pipeline

  % Run in the Directory of the .tif files. 



mat_dir=[pwd, '/mat'];



if exist(mat_dir,'dir') rmdir(mat_dir,'s'); end


mkdir(mat_dir);





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
    A = imresize(A,.25);
    video.frames(k).cdata = double(A);
end


		save(fullfile(mat_dir,[file '.mat']),'video','-v7.3');

clear video;

end
fprintf(1,'\n');
