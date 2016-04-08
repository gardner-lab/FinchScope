



figure(); 

colores = {'r','g','b'}


 counter2 = 1;
 clear HoldingV;
 cf = [1 2 3]
 for c = 1:3;
    

  color = colores{c};
  counter2 = 1;
  HoldingV = [];
  roi_ave = ROI_dat{cf(c)};
  
for trial = 1:size(roi_ave.raw_dat,2)
   clear Y; 
counter = 1; 

    for i = 1:size(roi_ave.interp_raw,1)
HoldingV{i,counter2} = roi_ave.interp_raw{i,trial};
    end
counter2 = counter2+1;

end


x=[0.25, 0.25];
y=[0,55];
plot(x,y,'--r')

length(roi_ave.interp_time{1,1})
l2 = roi_ave.interp_time{1,1}(:,end)-0.75
x=[l2, l2];
y=[0,55];
plot(x,y,'--r')
axis tight;
xlabel('time(s)');
 
hold on;

%%AVERAGED CELL RESPONSES





for  cell = 1:13  %[2 4 5 8 12 14  16 17 22 23  25 26] ;
    clear Meen;
    
for  j = 1:size(HoldingV,2)
    
  Meen(j,:) =   zscore(HoldingV{cell,j})+counter*4;
    
end

 
 y = (Meen);
 x = roi_ave.interp_time{1,1};
 
 shadedErrorBar(x,y,{@mean,@std},color,1); 
    
 counter = counter+1;
end

% clear HoldingV;
    clear x;
    clear y;
    hold on;
    
end;


x=[0.25, 0.25];
y=[0,55];
plot(x,y,'--r')

length(roi_ave.interp_time{1,1})
l2 = roi_ave.interp_time{1,1}(:,end)-0.75
x=[l2, l2];
y=[0,55];
plot(x,y,'--r')

axis tight;




    
