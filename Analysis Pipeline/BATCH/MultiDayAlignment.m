
close all



figure();

 cell = 1; 
 clear G_c;
 clear G_uc;
 clear G;
 days = [1 2 3 4 5]
colr = {'r' 'g' 'b' 'm' 'y' };
 figcount = 1;
 for ii =  days; % [1 3 4 6 8];
     color = char(colr(figcount));
 clear G_c;
 clear G_uc;
 clear G;
 
 pdata = ROI_dat{ii};
 counter = 1;
 for cell = 1:size(pdata.raw_dat,1);
 for i = 1:size(pdata.raw_dat,2); %[8 9 10 11 12 17 18 20 21 22]
     if min(pdata.raw_dat{cell,i}(2:end))>30;
 figure(1);
 plot(pdata.raw_time{cell,i}(2:end),zscore(pdata.raw_dat{cell,i}(2:end))+cell*6,color); 
 hold on;
     end
     G(counter,:) = zscore(pdata.interp_raw{cell,i}(30:end-40));
    hold on; 
    counter = counter+1;
   
 end
 G_c(cell,:) = zscore(mean(G,1));
clear G;
 end

 
 figure(7);
 hold on;
 y = G_c
 
 
  figure(6);
  hold on;
 for cell = 1:13
 plot((1:size(pdata.interp_time{1,1}(30:end-40),2))/3/30,G_c(cell,:)+cell*4,color);
 hold on;
 end

 
x=[0.25, 0.25];
y=[0,45];
plot(x,y,'--r')

length(pdata.interp_time{1,1})
l2 = pdata.interp_time{1,1}(:,end)-0.75
x=[l2, l2];
y=[0,45];
plot(x,y,'--r')
hold off;
 
%  figure(); imagesc(G_c(:,:)); colormap(jet);
%  
%  
%  
%  figure(); imagesc(G_c(:,20:end-60)); colormap(jet);
  A    = (G_c(:,:));
 if ii ==1; % sort on day one
[maxA, Ind] = max(A, [], 2);
[dummy, index] = sort(Ind);
 end
 
B  = A(index, :);

% colormap(jet);
% imagesc(B);
figure(10);
% whole image
C  = G_c(index,:);%G_c(index,20:end-50);
subplot(5,1,figcount);
% try
%     colormap(mycmap)
% catch
    colormap(jet);
% end

imagesc(C);
figcount = figcount+1;
 end
 


