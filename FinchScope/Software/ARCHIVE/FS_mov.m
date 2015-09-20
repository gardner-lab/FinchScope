
function FS_mov(framerate,videodata)

% Convert FS to avi

% WALIII
% 02.09.15

files = videodata;
writerObj = VideoWriter( 'Output_new','Grayscale AVI' ); % include grayscale AVI if one channel
writerObj.FrameRate = framerate;
open(writerObj);

figure;
for i=1:length(files) %number of images to be read
    a = files(:,:,1,i); %1 = just get green channel
    f.cdata = a;
    f.colormap = [];
    writeVideo(writerObj,f);
end
close(writerObj);