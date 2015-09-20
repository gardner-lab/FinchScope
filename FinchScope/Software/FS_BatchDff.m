function FS_BatchDff2(DIR, varargin)

%run thorough directory and make DfF movies in AVI format
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
vidObj.Quality = 100;
vidObj.FrameRate = 30;
open(vidObj);
colormap(bone);

%%%%
for i=1:length(mov_data)
   mov_data2(:,:,i) = rgb2gray(mov_data(i).cdata);
end
test=mov_data2;
test=imresize(double(test),.25);

h=fspecial('disk',50);
bground=imfilter(test,h);
% bground=smooth3(bground,[1 1 5]);
test=test-bground;


h=fspecial('disk',1);
test2=imfilter(test,h);

%%%%%
LinKat =  cat(1,test2(:,1,10)); % initilaize linkat
for i = 2:size(test2,2)
Lin = cat(1,test2(:,i,size(test2,3)));
LinKat = cat(1,LinKat,Lin);
end


H = prctile(LinKat,95)+20; % take the pixel value equal to the 70th percentile value
L = prctile(LinKat,5);

test2=imresize(test2,4);


%# create movie
for i=1:length(mov_data)
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

% [optimizer, metric] = imregconfig('multimodal');
% for g = 1:size(TotalX,3)
%     tiledImage(:,:,g) = imregister(TotalX(:,:,g), TotalX(:,:,1),'rigid',optimizer, metric);
% end
%  


FrameInfo2 = max(TotalX,[],3);
imwrite(FrameInfo2,'Dff_composite','png')
Test = TotalX;
mov_data = FrameInfo2;
im_resize = 1;

save('DffComposite.mat','Test','mov_data','im_resize')
