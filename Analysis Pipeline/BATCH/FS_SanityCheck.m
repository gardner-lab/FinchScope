figure();

 cell = 7; 
 pdata = roi_ave1;
 
 for i = [1 2 3 4 10 11 12 13] %[8 9 10 11 12 17 18 20 21 22]
     if min(pdata.raw_dat{cell,i}(2:end))>30;
    plot(pdata.raw_time{cell,i}(2:end),zscore(pdata.raw_dat{cell,i}(2:end)),'r'); 
     end
     
    hold on; 
 end
 
 pdata = roi_ave2;
  
 for i = [8 9 10 11 12 17 18 20 21 22]
     if min(pdata.raw_dat{cell,i}(2:end))>30;
    plot(pdata.raw_time{cell,i}(2:end),zscore(pdata.raw_dat{cell,i}(2:end)),'b'); 
     end
     
    hold on; 
 end
 
  
 
%  hold off
%  
%  figure();
%  
%  imagesc(ROI.reference_image);
%  hold on;
%  plot(ROI.coordinates{1,1}(:,1),ROI.coordinates{1,1}(:,2))
