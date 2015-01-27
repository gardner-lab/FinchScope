
function FS_mov(framerate,videodata)

% Convert FS to avi

% WALIII
% 12.26.14


files = videodata;
writerObj = VideoWriter( 'Output.avi' );
writerObj.FrameRate = framerate;
open(writerObj);
figure;
for i=1:length(files) %number of images to be read
    a = files(:,:,:,i);  
    f.cdata = a;
    f.colormap = [];
    writeVideo(writerObj,f);
end
close(writerObj);