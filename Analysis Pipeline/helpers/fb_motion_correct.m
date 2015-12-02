function MOV_DATA=fb_motion_correct(MOV_DATA,TEMPLATE,varargin)
%motion corrects the data in MOV_DATA to match a template image using xcorr
%
%
%

upsample_factor=100;

nparams=length(varargin);

if mod(nparams,2)>0
	error('Parameters must be specified as parameter/value pairs');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'upsample_factor'
			upsample_factor=varargin{i+1};
	end
end


[nrows,ncolumns,nframes]=size(MOV_DATA);

[nblanks formatstring]=fb_progressbar(100);
fprintf(1,['Progress:  ' blanks(nblanks)]);

correction_fft=fft2(TEMPLATE);

for i=1:frames

	fprintf(1,formatstring,round((i/frames)*100));	

	% uncomment to test for motion correction, introduces random x,y shifts

	%tmp=circshift(MOV_DATA(y_segment,x_segment,j),[randi(100) randi(100)]);

	tmp=MOV_DATA(y_segment,x_segment,i);

	% last argument is upsample factor

	[output Greg]=dftregistration(correction_fft,fft2(tmp),upsample_factor);
	MOV_DATA(:,:,i)=abs(ifft2(Greg)); % recover corrected image

end


