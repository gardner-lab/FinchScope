function [AGG_DETRENDED,AGG_DETRENDED_PKONLY]=fb_aggregate_trials(DIR,varargin)
%
%
%
%
%
%

nparams=length(varargin);
dff=1;
fs=22;
win=.4;
per=12;
medfilt_size=.4;
cut=25;
out_dir='extraction';
save_dir='detrended_aligned';
dat_dir='trace_data';
method='prctile'; % 'prctile','medianfilt','mean','fft','highpass'
thresh=1.5;

if mod(nparams,2)>0
	error('Parameters must be specified as parameter/value pairs');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'cut'
			cut=varargin{i+1};
		case 'out_dir'
			out_dir=varargin{i+1};
		case 'dat_dir'
			dat_dir=varargin{i+1};
		case 'thresh'
			thresh=varargin{i+1};
	end
end


if nargin<1 | isempty(DIR), DIR=pwd; end

tmp=dir(fullfile(DIR,'*.mat'));
file_list={tmp(:).name};

load(file_list{1},'align_detrended','align_peak_locs','align_peak_vals');

[nsamples,nrois]=size(align_detrended);

ntrials=length(file_list);

AGG_DETRENDED=zeros(nsamples,nrois,ntrials);

for i=1:nrois
	AGG_PEAK_LOCS{i}=[];
	AGG_PEAK_VALS{i}=[];
	AGG_DETRENDED_PKONLY{i}=[];
end

AGG_ISPEAK=zeros(ntrials,nrois);

for i=1:ntrials

	disp(['Processing file ' file_list{i}]);
	[path file ext]=fileparts(file_list{i});

	% load mat file

	load(file_list{i},'align_detrended','align_peak_locs','align_peak_vals');

    if size(align_detrended,1)~=size(AGG_DETRENDED,1)
        continue;
    end
    
	AGG_DETRENDED(:,:,i)=align_detrended;

	for j=1:nrois

		%AGG_PEAK_LOCS{j}=[AGG_PEAK_LOCS{j} align_peak_locs{j}];
		%AGG_PEAK_VALS{j}=[AGG_PEAK_VALS{j} align_peak_vals{j}];

		if any(align_detrended(:,j)>thresh) 
			AGG_DETRENDED_PKONLY{j}=[AGG_DETRENDED_PKONLY{j} align_detrended(:,j)];
		end

	end

end

