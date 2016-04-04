function SDI_dat = FSA_SpecDensity(ROI_dat_New)

figure(); 
for i = 1:size(ROI_dat_New,2)
    
    try
    mic_data = cell2mat(ROI_dat_New{i}.analogIO_dat);
    catch 
        mic_data = cell2mat(ROI_dat_New{i}.mic_data');
        mic_data = mic_data';
    end
    
    [SDI F T CONTOURS] = zftftb_sdi(mic_data);
    
    figure(1);
  a(i) = subplot(size(ROI_dat_New,2),1,i)
    imagesc(T,F,flipud(SDI.im));
   figure(2);
  b(i) = subplot(size(ROI_dat_New,2),1,i)
    imagesc(T,F,flipud(SDI.re));
    
    SDI_dat{i} = SDI;
    
    clear mic_data; clear SDI; clear F; clear T;
    
   linkaxes(a,'x');
   linkaxes(b,'x');
end

    
    
    

