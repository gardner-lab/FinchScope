function [IMAGE,F,T]=pretty_sonogram(SIGNAL,FS,varargin)
%simple 2-taper histogram (Gauss and DGauss)
%
%
%
%

if nargin<2 | isempty(FS)
	disp('Setting FS to default: 48e3');
	FS=48e3;
end

overlap=2000;
tscale=2;
N=2048;
postproc='y';
nparams=length(varargin);
nfft=[];
low=3;
high=10;
zeropad=[];

if mod(nparams,2)>0
	error('Parameters must be specified as parameter/value pairs!');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'overlap'
			overlap=varargin{i+1};
		case 'n'
			N=varargin{i+1};
		case 'tscale'
			tscale=varargin{i+1};
		case 'postproc'
			postproc=varargin{i+1};
		case 'nfft'
			nfft=varargin{i+1};
		case 'low'
			low=varargin{i+1};
		case 'high'
			high=varargin{i+1};
        case 'zeropad'
            zeropad=varargin{i+1};
		otherwise
	end
end

if length(SIGNAL)<=N
	%disp(['Length of signal shorter than N, truncating N to ' num2str(floor(length(SIGNAL)/5))]);
	warning('Length of signal shorter than N, trunacting N to %g',num2str(floor(length(SIGNAL)/5)));
    fprintf(1,'\n\n');
    difference=N-overlap;
	N=floor(length(SIGNAL)/3);
	overlap=N-difference;
	nfft=[];
end

if isempty(nfft)
    nfft=2^nextpow2(N);
else
    nfft=2^nextpow2(nfft);
end

if zeropad==0
    zeropad=round(N/2);
end

if ~isempty(zeropad)
    SIGNAL=[zeros(zeropad,1);SIGNAL(:);zeros(zeropad,1)];
end

if any(SIGNAL>1)
    SIGNAL=SIGNAL./max(abs(SIGNAL));
end

t=-N/2+1:N/2;
sigma=(tscale/1e3)*FS;
w = exp(-(t/sigma).^2);
dw = -2*w.*(t/(sigma^2));

[S,F,T]=spectrogram(SIGNAL,w,overlap,nfft,FS);
[S2]=spectrogram(SIGNAL,dw,overlap,nfft,FS);

if ~isempty(zeropad)
	T=T-zeropad/FS; % correct time to reflect the zeropad
end

if lower(postproc(1))=='y'
	IMAGE=100*((abs(S)+abs(S2))/2);
	IMAGE=log(IMAGE+2);
	IMAGE(IMAGE>high)=high;
	IMAGE(IMAGE<low)=low;
	IMAGE=IMAGE-low;
	IMAGE=IMAGE/(high-low);
	IMAGE=63*(IMAGE); % 63 is the cutoff for GIF
else
	IMAGE=(abs(S)+abs(S2))/2;
end


