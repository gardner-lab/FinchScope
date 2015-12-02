function DFF=fb_compute_dff(CA_DATA,varargin)
%fb_select_roi selects an arbitrary number of roi's for plotting
%
%
%
%
%

per=2.5;
baseline=3;

nparams=length(varargin);

if mod(nparams,2)>0
	error('Parameters must be specified as parameter/value pairs');
end

for i=1:2:nparams
	switch lower(varargin{i})	

	end
end

DFF=zeros(size(CA_DATA));

[nsamples,nrois]=size(CA_DATA);

% interpolate ROIs to a common timeframe

[nblanks formatstring]=fb_progressbar(100);
fprintf(1,['Progress:  ' blanks(nblanks)]);

% unfortunately we need to for loop by frames, otherwise
% we'll eat up too much RAM for large movies



for i=1:nrois

	fprintf(1,formatstring,round((i/nrois)*100));
	tmp=CA_DATA(:,i);

	if baseline==0
		norm_fact=mean(tmp,3);
	elseif baseline==1
		norm_fact=median(tmp,3);
	elseif baseline==2
		norm_fact=trimmean(tmp,trim_per,'round',3);
	else
		norm_fact=prctile(tmp,per);
	end

	DFF(:,i)=((tmp-norm_fact)./norm_fact).*100;
end

fprintf(1,'\n');
