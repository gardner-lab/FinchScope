
% Load DffComposite for each case, which will contain the data for
% alignment.


TotalX = Test;



[optimizer, metric] = imregconfig('multimodal');
for g = 1:size(TotalX,3)
    tiledImage(:,:,g) = imregister(TotalX(:,:,g), TotalX(:,:,1),'rigid',optimizer, metric);
end
 
FrameInfo2 = max(tiledImage,[],3);
imwrite(FrameInfo2,'Dff_composite2','png')

sumIm = double(tiledImage(:,:,1));
for g = 2:size(tiledImage,3);
    sumIm = sumIm + double(tiledImage(:,:,g));
end
MeanIm = uint8(round(sumIm/size(tiledImage,3)));

imwrite(MeanIm,'Dff_AVG','png')
    
    