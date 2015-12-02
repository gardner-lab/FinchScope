function ROI=fb_roi_detrend(ROI,varargin)
%
%
%
%
%
%

% parameter collection

nparams=length(varargin);
dff=1;
fs=22;
win=.4;
per=8;
medfilt_size=.4;

method='prctile'; % 'prctile','medianfilt','mean','fft','highpass'

if mod(nparams,2)>0
	error('Parameters must be specified as parameter/value pairs');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'per'
			per=varargin{i+1};
		case 'dff'
			dff=varargin{i+1};
		case 'method'
			method=varargin{i+1};
		case 'fs'
			fs=varargin{i+1};
		case 'win'
			win=varargin{i+1};
	end
end

% ensure proper formatting

if isvector(ROI), ROI=ROI(:); end

win_samples=round(win*fs);

[nsamples,nrois]=size(ROI);

NEWROI=ROI;

for i=1:nrois

	curr_roi=ROI(:,i);
	curr_roi=[ repmat(curr_roi(1),[win_samples 1]);curr_roi;repmat(curr_roi(end),[win_samples 1]) ];

	counter=1;

	for j=win_samples+1:nsamples+win_samples

		idx=j-win_samples:j+win_samples;
		tmp=curr_roi(idx);

		switch lower(method(1))
			case 'p'
				tmp_baseline=prctile(tmp,per);
		end

		if dff
			tmp=((ROI(j-win_samples,i)-tmp_baseline)./tmp_baseline).*100;
		else
			tmp=(ROI(j-win_samples,i)-tmp_baseline);
		end

		NEWROI(j-win_samples,i)=tmp;
	end
end

ROI=NEWROI;
clear NEWROI;
