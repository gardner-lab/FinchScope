FSA_SpecDensity(ROI_dat_New);

figure(); 
for i = 1:size(ROI_dat_New,2)
    
    mic_data = ROI_dat_New{i}.analogIO_dat;
    [SDI F T] CONTOURS] = zftftb_sdi(mic_data);
    
    subplot(size(ROI_dat_New,2),1,i)
    imagesc(T,F,flipud(SDI.im));
    
    clear mic_data; clear SDI; clear F; clear T;
    
end

    
    
    

