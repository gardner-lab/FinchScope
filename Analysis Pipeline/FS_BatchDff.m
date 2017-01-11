function FS_BatchDff(DIR, varargin)

%run thorough directory and make Background Subtracted Movies in AVI format
% This Script is for 'unprocessed' videos


% WALIII
% For unprocessed videos
% 09.05.15

%% Default Paramaters:
filt_rad=10; % gauss filter radius
filt_alpha=30; % gauss filter alpha
lims=3; % contrast prctile limits (i.e. clipping limits lims 1-lims)
cmap=colormap('jet');
per=4; % baseline percentile (0 for min)
counter = 1;
mat_dir='DFF_MOVIES';
counter = 1;
sT = 1;
resize = 1;



%% Custom Paramaters
nparams=length(varargin);

if mod(nparams,2)>0
	error('Parameters must be specified as parameter/value pairs');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'filt_rad'
			filt_rad=varargin{i+1};
		case 'filt_alpha'
			filt_alpha=varargin{i+1};
		case 'lims'
			lims=varargin{i+1};
		case 'baseline'
			per=varargin{i+1};
        case 'start'
            sT=varargin{i+1};
        case 'resize'
            resize=varargin{i+1};
            filt_rad= round(filt_rad*resize); % gauss filter radius
            filt_alpha= round(filt_alpha*resize); % gauss filter alpha
	end
end



if exist(mat_dir,'dir') rmdir(mat_dir,'s'); end
mkdir(mat_dir);


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
clear NormIm;
clear dff2;
clear dff;
clear mov_data3;
clear mov_data2;
clear mov_data;

    [path,file,ext]=fileparts(filenames{i});
    save_filename=[ fullfile(mat_dir,file) ];
	fprintf(1,formatstring,round((i/length(mov_listing))*100));
try
load(fullfile(DIR,mov_listing{i}),'video');

mov_data = video.frames(:,:,:,sT:end);
catch
    load(fullfile(DIR,mov_listing{i}),'mov_data');

    mov_data = mov_data(:,:,:,sT:end);
end

mov_data = imresize(mov_data,resize);

%%%%
% Detect Bad frames
counter = 1;
TERM_LOOP = 0;
for i=sT:(size(mov_data,4))
   mov_data2(:,:,counter) = single(rgb2gray(mov_data(:,:,:,counter)));

      if mean(mean(mov_data2))< 20;
        dispword = strcat(' WARNING:  Bad frame(s) detected on frame: ',num2str(i));
        disp(dispword);
        TERM_LOOP = 1;
        break
      end
      counter = counter+1;

end



if TERM_LOOP ==1;
    disp(' skipping to nex mov file...')
    continue
end

mov_data3 = convn(mov_data2, single(reshape([1 1 1] / 3, 1, 1, [])), 'same');


 test = single(mov_data3(:,:,1:end));
[rows,columns,frames]=size(test);

%%%=============[ FILTER Data ]==============%%%

disp('Gaussian filtering the movie data...');

h=fspecial('gaussian',filt_rad,filt_alpha);
test=imfilter(test,h,'circular','replicate');

disp(['Converting to df/f using the ' num2str(per) ' percentile for the baseline...']);

baseline=repmat(prctile(test,per,3),[1 1 frames]);

h=fspecial('gaussian',10,10);
baseline = imfilter(baseline,h,'circular','replicate'); % filter baseline

dff2 = (test.^2-baseline.^2)./baseline;

h=fspecial('disk',2);
dff2=imfilter(dff2,h); %Clean up
% baseline2=mean(tot,3);
% for iii=1:size(tot,3)
%   dff2 =  tot(:,:,iii)./baseline2.*100;
% end

dff2 = imresize(dff2,(1/resize));



H = prctile(max(max(dff2(:,:,:))),70);
L = 20;%prctile(mean(max(dff2(:,:,:))),3); Good to fix lower bound

    clim = [double(L) double(H)];


NormIm(:,:,:) = mat2gray(dff2, clim);


%figure(1); for  iii = 7:size(NormIm,3);  IM(:,:) = NormIm(:,:,iii); imagesc(IM); pause(0.05); end



%% Write VIDEO


v = VideoWriter(save_filename,'MPEG-4');
v.Quality = 30;
v.FrameRate = 30;

open(v)


for ii = 2:size(NormIm,3);
colormap(gray);
IM(:,:) = NormIm(:,:,ii);
writeVideo(v,IM)
imagesc(IM);
end
close(v)

figure(1);
imagesc(max(NormIm,[],3));

imwrite(max(NormIm,[],3),strcat(save_filename,'_max_','.png'));


end


%% Save Data from aggregate
% Test = TotalX2;
%mov_data = video.frames;
%im_resize = 1;

%save(save_filename,'Test','mov_data','im_resize','-v7.3')
