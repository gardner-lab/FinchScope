
function FS_mov(framerate,videodata)

% Convert FS to avi

% WALIII
% 02.09.15

files = uint8(videodata);
writerObj = VideoWriter( 'Output_new','Grayscale AVI' ); % include grayscale AVI if one channel
writerObj.FrameRate = framerate;
open(writerObj);

figure;
if size(size(files)) ==4;
for i=1:size(files,4) %number of images to be read
    a = files(:,:,1,i); %1 = just get green channel
    f.cdata = a;
    f.colormap = [];
    writeVideo(writerObj,f);
end
else
    for i=1:size(files,3) %number of images to be read
    a = files(:,:,i); %1 = just get green channel
    f.cdata = a;
    f.colormap = [];
    writeVideo(writerObj,f);
    end
end
    
close(writerObj);