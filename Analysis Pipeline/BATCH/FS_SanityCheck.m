
close all



figure();

 cell = 1; 
 clear G_c;
 clear G_uc;
 clear G;
 pdata = roi_ave_c;
 counter = 1;
 for cell = 1:6;
 for i = 1:18 %[8 9 10 11 12 17 18 20 21 22]
     if min(pdata.raw_dat{cell,i}(2:end))>30;
    plot(pdata.raw_time{cell,i}(2:end),zscore(pdata.raw_dat{cell,i}(2:end))+cell*4,'b'); 
     end
     G(counter,:) = zscore(pdata.interp_raw{cell,i}(2:end));
    hold on; 
    counter = counter+1;
   
 end
 G_c(cell,:) = zscore(mean(G,1));
clear G;
 end
 
 figure();
 for cell = 1:6
 plot((1:size(pdata.interp_time{1,1}(2:end),2))/3/30,G_c(cell,:)+cell*2);
 hold on;
 end
 
x=[0.25, 0.25];
y=[0,15];
plot(x,y,'--r')

length(pdata.interp_time{1,1})
l2 = pdata.interp_time{1,1}(:,end)-0.75
x=[l2, l2];
y=[0,15];
plot(x,y,'--r')
 
 figure(); imagesc(G_c(:,:)); colormap(jet);
 
 
 
 figure(); imagesc(G_c(:,20:end-60)); colormap(jet);
 
 
 A    = (G_c(:,20:end-60));
maxA = max(A, [], 2);
[dummy, index] = sort(maxA);
B    = A(index, :);
figure();
colormap(jet);
imagesc(B);
 
%  counter = 1;
%  pdata = roi_ave_c;
%   
%  for i = [8 9 10 11 12 17 18 20 21 22]
%      if min(pdata.raw_dat{cell,i}(2:end))>30;
%     plot(pdata.raw_time{cell,i}(2:end),zscore(pdata.raw_dat{cell,i}(2:end)),'r'); 
%      end
%      G_uc(counter,:) = pdata.interp_raw{cell,i};
%     hold on; 
%     counter = counter+1;
%  end
%  
%  hold off
%  

%  plot((1:size(pdata.interp_time{1,1},2))/3/30,zscore(mean(G_uc,1)));
%  hold on;
 
  
 
%  hold off
%  
%  figure();
%  
%  imagesc(ROI.reference_image);
%  hold on;
%  plot(ROI.coordinates{1,1}(:,1),ROI.coordinates{1,1}(:,2))
