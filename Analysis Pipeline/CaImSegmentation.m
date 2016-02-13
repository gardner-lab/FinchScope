function [SpatMap,CaSignal] = CaImSegmentation(VideoFileName,maxNeurons,estNeuronSize)
%CaImSegmentation.m
%   See Pnevmatikakis & Paninski, 2014 & 2016, for their matrix factorization
%     algorithm to automate image segmentation for calcium imaging data.
%     Briefly, if d is the total number of pixels in an image, T is the number
%     of time steps in a video, and K is the maximum number of neurons, then 
%     the observed fluorescence signal Y (matrix size d-by-T) can be
%     regarded as a noisy function of the true signal,F, by Y = F + E, where E is
%     Gaussian noise.  F, in turn, can be regarded as a signal of the form
%     F = AC+B, where A is a d-by-K matrix representing the spatial footprint
%     of neuron k, C is a K-by-T matrix representing the calcium activity of
%     the k-th neuron, and B is a d-by-T matrix representing the background
%     fluorescence at each pixel.  The algorithm infers the matrices
%     A and C from the observed fluorescence signal Y using matrix factorization
%     and convex optimization based on several assumptions:
%       1) the difference between F = AC+B and Y will be the noise E, thus
%        constraining the following steps to find values for A, C, and B
%        that force abs(Y-F) < noise ... they make an estimate of the noise
%        as a first step in the algorithm
%       2) each neuron will be small relative to the size of the original
%        image, of approximate size based on the input estNeuronSize, so 
%        the matrix A should be sparse.
%       3) the calcium signal, C, for each neuron will be an AR(p) process
%        of the following form, for an individual neuron, 
%          c(t) = SUM [j=1 to p] gamma-p*c(t-j) + s(t), where s(t) is the
%          number of actual spikes at time t. 
%
%  This code must be run after downloading ca_source_extraction-master 
%   from the GitHub repository created for the papers referenced above -
%   Go to: https://github.com/epnev/ca_source_extraction.git
%  You also need CVX placed in your MATLAB directory - http://cvxr.com/cvx/download/
%
%INPUT: VideoFileName - file name of the video to be segmented as a string,
%          'Video.tif'
%       maxNeurons - maximum neurons in the video, this is an estimate that
%        constrains the maximum number of neurons, this value will affect
%        the number of neurons found by the algorithm
%       estNeuronSize - estimate of the average neuron size in pixels
%OUTPUT: SpatMap - d-by-K matrix representing the spatial map for the
%         k-th neuron, to view the maps, run the following code:
%          % if d = width*height; in pixels
%          myMap = zeros(width,height,K);
%          for ii=1:K 
%             myMap(:,:,ii) = reshape(SpatMap(:,ii),[width,height]);
%          end
%          % make figure with a representative example
%          figure();imagesc(squeeze(myMap(:,:,1)));colormap jet;
%
%        CaSignal - a K-by-T matrix representing the inferred calcium
%         signal for the k-th neuron across all time steps, dF/F
%    
%Created: 2016/02/09, 24 Cummington, Boston
% Byron Price
%Updated: 2016/02/09
% By: Byron Price

addpath(genpath('utilities'));
             
nam = VideoFileName; % insert path to tiff stack here
startFrame=1; % user input: first frame to read (optional, default 1)

Y = bigread2(nam,startFrame);
Y = Y - min(Y(:)); 
if ~isa(Y,'double');    Y = double(Y);  end         % convert to double

[d1,d2,T] = size(Y);                                % dimensions of dataset
d = d1*d2;                                          % total number of pixels

% Set parameters
K = maxNeurons;                       % number of components to be found
tau = estNeuronSize;                  % std of gaussian kernel (size of neuron) 
p = 2;                                % order of autoregressive system (p = 0 no dynamics, p=1 just decay, p = 2, both rise and decay)
merge_thr = 0.8;                      % merging threshold

options = CNMFSetParms(...                      
    'd1',d1,'d2',d2,...                         % dimensions of datasets
    'search_method','ellipse','dist',3,...      % search locations when updating spatial components
    'deconv_method','constrained_foopsi',...    % activity deconvolution method
    'temporal_iter',2,...                       % number of block-coordinate descent steps 
    'fudge_factor',0.98,...                     % bias correction for AR coefficients
    'merge_thr',merge_thr,...                    % merging threshold
    'gSig',tau...
    );
% Data pre-processing

[P,Y] = preprocess_data(Y,p);

% fast initialization of spatial components using greedyROI and HALS

[Ain,Cin,bin,fin,center] = initialize_components(Y,K,tau,options);  % initialize

% display centers of found components
Cn =  correlation_image(Y); %max(Y,[],3); %std(Y,[],3); % image statistic (only for display purposes)
% figure;imagesc(Cn);
%     axis equal; axis tight; hold all;
%     scatter(center(:,2),center(:,1),'mo');
%     title('Center of ROIs found from initialization algorithm');
%     drawnow;

% update spatial components
Yr = reshape(Y,d,T);
clear Y;
[A,b,Cin] = update_spatial_components(Yr,Cin,fin,Ain,P,options);

% update temporal components
[C,f,P,S] = update_temporal_components(Yr,A,b,Cin,fin,P,options);

% merge found components
[Am,Cm,K_m,merged_ROIs,P,Sm] = merge_components(Yr,A,b,C,f,P,S,options);

% repeat
[A2,b2,Cm] = update_spatial_components(Yr,Cm,f,Am,P,options);
[C2,f2,P,S2] = update_temporal_components(Yr,A2,b2,Cm,f,P,options);


[A_or,C_or,S_or,P] = order_ROIs(A2,C2,S2,P); % order components
K_m = size(C_or,1);
[C_df,~,S_df] = extract_DF_F(Yr,[A_or,b2],[C_or;f2],S_or,K_m+1); % extract DF/F values (optional)

SpatMap = A_or;
CaSignal = C_df(1:end-1,:);

% contour_threshold = 0.95;                       % amount of energy used for each component to construct contour plot
% figure;
% [Coor,json_file] = plot_contours(A_or,reshape(P.sn,d1,d2),contour_threshold,1); % contour plot of spatial footprints

end

