function LNY13_time_offset

% this finction adds time to LNY13, who is loosing time in the
% videoalignment

Sdate = '2015-08-04 09 09 34'
SD = datevec(Sdate,'yyyy-mm-dd HH MM SS');
mov_listing=dir(fullfile(pwd,'*.mat'));
mov_listing={mov_listing(:).name};
filenames=mov_listing;
g = 170/24/60/60/1000;



for i=1:length(mov_listing)
    
     [path,file,ext]=fileparts(filenames{i});
	         load(fullfile(pwd,mov_listing{i}),'video');  %load movie data
             
S = filenames{i}(1:end-4);
S2 = datevec(S,'yyyy-mm-dd HH MM SS');


S3 = etime(S2,SD);
try
    g2 = video.alignment;
    disp('video already aligned! doing it again...');
    video.times = video.TimeOriginal;
    video.times = video.times + S3*g;
    video.alignment = g;
save(fullfile(path,[file '.mat']),'video','-append');
    
catch
video.TimeOriginal = video.times;
video.times = video.times + S3*g;
video.alignment = g;

save(fullfile(path,[file '.mat']),'video','-append');
end;

clear S; clear S2; clear S3; clear video;

end



