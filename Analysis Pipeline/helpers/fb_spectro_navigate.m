function [EXTRACTED_SOUND,EXTRACTED_IMAGE,TIME_POINTS]=spectro_navigate(DATA)
%simple GUI for selecting a sound using its spectrogram
%
%	[EXTRACTED_SOUND,EXTRACTED_IMAGE]=spectro_navigate(DATA,DIR)
%
%
% DIR
% if given then brings up an interface to select a particular file
%
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parameters for constructing the spectrogram image

FFTWINDOW=500;
NOVERLAP=400;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DATA=DATA./abs(max(DATA));

% sampling rate doesn't matter here at all, just using a dummy value, 48e3

sonogram_im=fb_pretty_sonogram(DATA,48e3,'n',FFTWINDOW,'overlap',NOVERLAP,'low',1);
sonogram_im=flipdim(sonogram_im,1);
%sonogram_im=spectrogram(DATA,FFTWINDOW,NOVERLAP);
%sonogram_im=abs(flipdim(sonogram_im,1));
%sonogram_im=sonogram_im-min(min(sonogram_im));
%sonogram_im=log(sonogram_im);
%sonogram_im=125*sonogram_im/(max(max(sonogram_im)));

[height,width]=size(sonogram_im);

disp('Generating interface...');

overview_fig=figure('Toolbar','none','Menubar','none');
overview_img=imshow(uint8(sonogram_im),hot);

overview_scroll=imscrollpanel(overview_fig,overview_img);
imoverview(overview_img);

EXTRACTED_SOUND=[];

rect_handle=imrect(get(overview_fig,'CurrentAxes'),[width/2 height/2 width/4 height/4]);

while isempty(EXTRACTED_SOUND)

	rect_position=wait(rect_handle);

	if rect_position(1)<1, rect_position(1)=1; end
	
	selected_width=rect_position(1)+rect_position(3);

	if selected_width>width, selected_width=width; end
	
	EXTRACTED_IMAGE=sonogram_im(:,rect_position(1):selected_width);
	
	extract_idxs=[fix((length(DATA)-FFTWINDOW)*(rect_position(1)/width)) ceil((length(DATA)-FFTWINDOW)*(selected_width)/width)];
	TIME_POINTS=extract_idxs;

	temp_fig=figure('Toolbar','None','Menubar','None');imshow(uint8(EXTRACTED_IMAGE),hot);
	
	validate=[];
	while isempty(validate)
		validate=input('(D)one or (c)ontinue selecting?  ','s');
		drawnow;commandwindow;

		switch lower(validate(1))
			case 'd'
				EXTRACTED_SOUND=DATA(extract_idxs(1):extract_idxs(2));

			case 'c'
				continue;
			otherwise
				disp('Invalid response!');
				validate=[];
		end
	end
	close(temp_fig);
end

close(overview_fig);
