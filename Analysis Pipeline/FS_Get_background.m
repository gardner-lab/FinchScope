function out= FS_Get_background()


mov_listing=dir(fullfile(pwd,'*.mat'));
mov_listing={mov_listing(:).name};
filenames=mov_listing;

for i=1:length(mov_listing)
   
load(fullfile(pwd,mov_listing{i}),'video');

sig_noise = squeeze(video.frames(:,:,2,:)); % green channel
noise = squeeze(video.frames(:,:,3,:)); % blue channel

% get the means
out.mean{i} = squeeze(mean(mean(sig_noise(:,:,:),2)));
out.noise{i} = smooth(squeeze(mean(mean(noise(:,1:80,:),2))));
% plot signal and noise
% figure();
% hold on;
% plot(zscore(out.sig_noise)+4)
% plot(zscore(out.noise));
% plot(zscore(out.sig_noise- out.noise)-4);

end

