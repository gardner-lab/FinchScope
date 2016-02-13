function FS_BatchDff_TM(DIR, varargin)

%run thorough directory and make DfF movies in AVI format
% This is for data that has been Template matched via 'FS_TemplateMatch'
% WALIII
% 09.05.15


mat_dir='DFF_MOVIES';
counter = 1;

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

    [path,file,ext]=fileparts(filenames{i});
	fprintf(1,formatstring,round((i/length(mov_listing))*100));

	load(fullfile(DIR,mov_listing{i}),'mov_data');

    %create DFF
    figure, set(gcf, 'Color','white')
      axis tight
      set(gca, 'nextplot','replacechildren', 'Visible','off');

%# create AVI object

save_filename=[ fullfile(mat_dir,file) ];

vidObj = VideoWriter(save_filename);
vidObj.Quality = 30;
vidObj.FrameRate = 30;
open(vidObj);
colormap(bone);



%%%%
for i=1:(length(mov_data)-2)
   mov_data3 = single(rgb2gray(mov_data(i).cdata));
   mov_data4 = single(rgb2gray(mov_data(i+1).cdata));
   %mov_data5 = single(rgb2gray(mov_data(i+2).cdata));
   mov_data2(:,:,i) = uint8((mov_data3 + mov_data4)/2);
end

test=mov_data2;
test=imresize((test),.25);

h=fspecial('disk',50);
bground=imfilter(test,h);
% bground=smooth3(bground,[1 1 5]);
test=test-bground;
h=fspecial('disk',1);
test2=imfilter(test,h);

%%%%%
% Scale videos by pixel value intensities
LinKat =  cat(1,test2(:,1,10));
for i = 2:size(test2,2)
Lin = cat(1,test2(:,i,size(test2,3)));
LinKat = cat(1,LinKat,Lin);
end
H = prctile(LinKat,95)+20; % clip pixel value equal to the 95th percentile value
L = prctile(LinKat,20);% clip the pixel value equal to the bottem 20th percentile value
%%%%%

test2=imresize(test2,4);

[optimizer, metric] = imregconfig('multimodal');
%# create movie
for i=1:(length(mov_data)-2);
    %test3(:,:,i) = imregister(test2(:,:,i),test2(:,:,1),'rigid',optimizer,metric);
   image(test2(:,:,i),'CDataMapping','scaled');
   caxis([double(L),double(H)])%caxis([0,70]) % change caxis
   writeVideo(vidObj, getframe(gca));
end
close(gcf)

%# save as AVI file, and open it using system video player
close(vidObj);

FrameInfo = max(test2,[],3);
%figure();
colormap(bone)
imagesc(FrameInfo);
%set(gca,'ydir','normal'); % Otherwise the y-axis would be flipped
X = mat2gray(FrameInfo);
X = im2uint8(X);
imwrite(X,save_filename,'png')

TotalX(:,:,counter) = X;
TotalX2{counter} = X;

    counter = counter+1;

end
fprintf(1,'\n');
%%
%% Register Images
% [optimizer, metric] = imregconfig('multimodal');
% for g = 1:size(TotalX,3)
%     tiledImage(:,:,g) = imregister(TotalX(:,:,g), TotalX(:,:,1),'rigid',optimizer, metric);
% end



FrameInfo2 = max(TotalX,[],3);
imwrite(FrameInfo2,'Dff_composite','png')

%% Save Data from aggregate
% Test = TotalX2;
%mov_data = video.frames;
%im_resize = 1;

%save(save_filename,'Test','mov_data','im_resize','-v7.3')
