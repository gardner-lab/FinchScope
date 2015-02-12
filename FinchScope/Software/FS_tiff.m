



function FS_tiff(framerate,videodata)

% Convert FS to tiff- for 16 bit images

% WALIII
% 02.12.14

videodata = double(videodata);


files = videodata(:,:,1,:);

imwrite(uint16(files(:,:,:,1)),'myMultipageFile4.tif');


for i=2:size(files,4) %number of images to be read

imwrite(uint16(files(:,:,:,i)),'myMultipageFile4.tif','WriteMode','append');
end


