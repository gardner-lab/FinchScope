function FS_DFF_STD_Image(DIR,varargin)
% FS_DFF_STD_Image.m


%run thorough directory and make STD and MAX images for every mat file in directory
% This Script is for 'unprocessed' videos
%
%   Created: 2016/03/09
%   By: WALIII
%   Updated: 2016/03/10
%   By: WALIII




%% Custom Paramaters
nparams=length(varargin);

if mod(nparams,2)>0
	error('Parameters must be specified as parameter/value pairs');
end
startFrame = 1;
maxDff = 9;
minDff = 2;

for i=1:2:nparams
	switch lower(varargin{i})
		case 'filt_rad'
			filt_rad=varargin{i+1};
        case 'start'
            startFrame=varargin{i+1};
        case 'max_dff'
            maxDff = varargin{i+1};
        case 'min_dff'
            minDff = varargin{i+1};
        case 'resize'
            resize=varargin{i+1};
            filt_rad= round(filt_rad*resize); % gauss filter radius
            filt_alpha= round(filt_alpha*resize); % gauss filter alpha
	end
end


% startFrame can equal 7, for full files

dispword = strcat('Start frame is set to:  ', ' ', num2str(startFrame));
disp(dispword);
% Make directory for all subsequent videos...
mat_dir='DFF_Images';
counter = 1;
counter2 = 1;
if exist(mat_dir,'dir'); rmdir(mat_dir,'s'); end
mkdir(mat_dir);
MaxDir = strcat(mat_dir,'/MAX');
StdDir = strcat(mat_dir,'/STD');
AvgDir = strcat(mat_dir,'/AVG');
mkdir(MaxDir);
mkdir(StdDir);
mkdir(AvgDir)

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

    [path,file,ext]=fileparts(filenames{i});
	fprintf(1,formatstring,round((i/length(mov_listing))*100));

    warning('off','all')
	load(fullfile(DIR,mov_listing{i}),'video','mov_data');
    warning('on','all')

save_filename_MAX=[ fullfile(MaxDir,file) ];
save_filename_STD=[ fullfile(StdDir,file) ];
save_filename_AVG=[ fullfile(AvgDir,file) ];

try
[mov_data2, n] = FS_Format(mov_data,1);
catch
[mov_data2, n] = FS_Format(video.frames,10);
end

a = 6;
counter = 1;
			for iii = startFrame: size(mov_data2,3)
                mov_data3(:,:,counter) = wiener2(mov_data2(:,:,iii),[a a]);
                counter = counter+1;
            end
test= convn(mov_data3, single(reshape([1 1 1] / 3, 1, 1, [])), 'same');
rTest = test;

test=imresize((test),.25);

h=fspecial('disk',50);
bground=imfilter(test,h);
% bground=smooth3(bground,[1 1 5]);
test=test-bground;
h=fspecial('disk',1);
test=imfilter(test,h);


test=imresize(test,4);

FrameInfo = max(test,[],3);


colormap(gray)
image(FrameInfo);

% X = uint16((2^16)*mat2gray(FrameInfo.^2));

X = mat2gray(FrameInfo);
X = im2uint16(X);
save_filename_MAX = strcat(save_filename_MAX,'_MAX','.tif');
imwrite(X,save_filename_MAX,'tif')

%% AVG movie

clear FrameInfo; FrameInfo = mean(rTest,3);
clear rTest;

colormap(gray); image(FrameInfo);

% X = uint16((2^16)*mat2gray(FrameInfo.^2));

X = mat2gray(FrameInfo);
X = im2uint16(X);
save_filename_AVG = strcat(save_filename_AVG,'_AVG','.tif');
imwrite(X,save_filename_AVG,'tif')

%%



clear FrameInfo; FrameInfo = std(double(test),[],3); image(FrameInfo);



X = uint16((2^16)*mat2gray(FrameInfo.^2,[minDff.^2 maxDff.^2])); % Square the signal of the STD image, higher contrast...



save_filename_STD = strcat(save_filename_STD,'_STD','.tif');
imwrite(X,save_filename_STD,'tif')

TotalX(:,:,counter2) = X;

counter2 = counter2+1; % Up the counter

% Clear all used Variables
clear mov_data;
clear LastFrame;
clear h;
clear bground;
clear X;
clear FrameInfo;
clear test;
clear LinKat;
clear Kat;
clear H;
clear L;
clear mov_data2;
clear mov_data3;
clear mov_data4;

end
fprintf(1,'\n');


% try
% if size(TotalX,3) >1;
% 	% Register Images
% 	disp('Registering Images...')
% 	 [optimizer, metric] = imregconfig('multimodal');
% 	 for g = 1:size(TotalX,3)
% 	     tiledImage(:,:,g) = imregister(TotalX(:,:,g), TotalX(:,:,1),'rigid',optimizer, metric);
% 	end
% 	clear TotalX;
% 	TotalX = tiledImage;
% FrameInfo2 = max(TotalX,[],3);
% imwrite(uint16(FrameInfo2),'Dff_composite_MAX.tif','tif')
% 
% FrameInfo3 = std(double(TotalX),[],3);
% imwrite(uint16(FrameInfo3),'Dff_composite_STD.tif','tif')
% 
% FrameInfo4 = mean(TotalX,3);
% imwrite(uint16(FrameInfo3),'Dff_composite_AVG.tif','tif')
% 
% else
% FrameInfo2 = TotalX;
% imwrite(uint16(FrameInfo2),'Dff_composite_MAX_ONE.tif','tif')
% imwrite(uint16(FrameInfo2),'Dff_composite_STD_ONE.tif','tif')
% imwrite(uint16(FrameInfo2),'Dff_composite_AVG_ONE.tif','tif')
% end
% 
% catch
%     disp('No images to process')
% end
