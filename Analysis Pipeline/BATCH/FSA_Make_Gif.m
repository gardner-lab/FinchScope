function FSA_Make_Gif(ROI_dat_New)

StartDir = pwd;
for iv= 1:size(ROI_dat_New,2)
    cd(StartDir);
    gif_dir = strcat('gif_',num2str(iv));
    mkdir(gif_dir);
    cd(gif_dir);
    
    
for i = 1:size(ROI_dat_New{iv}.analogIO_dat,2);
    
mic_data = ROI_dat_New{iv}.analogIO_dat{i};
fs = 48000;

file = ROI_dat_New{iv}.filename{i}
file = file(1:end-4);

		[b,a]=ellip(5,.2,80,[500]/(fs/2),'high');
		plot_data=mic_data./abs(max(mic_data));

		[s,f,t]=fb_pretty_sonogram(filtfilt(b,a,mic_data./abs(max(mic_data))),fs,'low',1.5,'zeropad',0);

		minpt=1;
		maxpt=min(find(f>=10e3));

		imwrite(flipdim(uint8(s(minpt:maxpt,:)),1),hot,fullfile(pwd,[file '.gif']),'gif');
		
        
end
end

