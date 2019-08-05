function [yCoordinates, xCoordinates] = Get_ring(ROI_dat,row,col)

  G = boundary(ROI_dat);
  G2 = round(G*1);

  scalF = 1.5;
  scalF2 = scalF-1;


  h = poly2mask(ROI_dat(G,1)*scalF-mean(ROI_dat(G,1))*scalF2 ,ROI_dat(G,2)*scalF -mean(ROI_dat(G,2)*scalF2),row,col);
  h2 = poly2mask(ROI_dat(G,1),ROI_dat(G,2),row,col);

  h3 = h-h2;
  % figure(); imagesc(h3)


  [yCoordinates, xCoordinates] = find(h3);

  % figure(); plot(ROI.coordinates{1}(:,1),ROI.coordinates{1}(:,2)); hold on; plot(xCoordinates,yCoordinates,'*');
  %
  % annul=mov_data(yCoordinates,xCoordinates,k);
