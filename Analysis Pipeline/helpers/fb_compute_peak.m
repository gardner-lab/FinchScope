function [LOCS,VALS]=fb_compute_peak(CA_DATA,varargin)
% Computes the peaks for a calcium trace or series of calcium traces
%
%
%
% algorithm:  schmitt trigger, double exponential fit (for now)
%
%

thresh_hi=1.2;
thresh_lo=-1;
thresh_t=.1;
thresh_int=8;

fs=22;
method='p'; % f-min, simulated annealing, pattern search, etc.
max_iter=1000; % maximum iterations for optimization
t_1=.07;
spk_delta=.04;
fit_window=[ .1 .4 ];

onset_init_guess= [ 1 .1 ];
onset_lbound= [ 0 .002  ];
onset_hbound= [ 10 .2 ];

full_init_guess= [ 1 1 .1 .1 ];
full_lbound= [ 0 0 .05 .05 ];
full_hbound= [ 10 10 2 2 ];

onset_only=1;

baseline=0;

debug=1;
debug_dir='debug_peak';
debug_filename='';

nparams=length(varargin);

if mod(nparams,2)>0
	error('Parameters must be specified as parameter/value pairs');
end

for i=1:2:nparams
	switch lower(varargin{i})	
		case 'roi_map'
			roi_map=varargin{i+1};
		case 'thresh_hi'
			thresh_hi=varargin{i+1};
		case 'thresh_lo'
			thresh_lo=varargin{i+1};
		case 'thresh_t'
			thresh_t=varargin{i+1};
		case 'thresh_int'
			thresh_int=varargin{i+1};
		case 'fs'
			fs=varargin{i+1};
		case 'method'
			method=varargin{i+1};
		case 't_1'
			t_1=varargin{i+1};
		case 'max_iter'
			max_iter=varargin{i+1};
		case 'onset_init_guess'
			onset_init_guess=varargin{i+1};
		case 'onset_lbound'
			onset_lbound=varargin{i+1};
		case 'onset_only'
			onset_only=varargin{i+1};
		case 'spk_delta'
			spk_delta=varargin{i+1};
		case 'full_init_guess'
			full_init_guess=varargin{i+1};
		case 'full_lbound'
			full_lbound=varargin{i+1};
		case 'full_hbound'
			full_hbound=varargin{i+1};
		case 'fit_window'
			fit_window=varargin{i+1};
		case 'debug'
			debug=varargin{i+1};
		case 'baseline'
			baseline=varargin{i+1};
		case 'debug_dir'
			debug_dir=varargin{i+1};
		case 'debug_filename'
			debug_filename=varargin{i+1};
	end
end

thresh_t=round(thresh_t*fs);
fit_window=round(fit_window*fs);

% ensure formatting is correct

if isvector(CA_DATA), CA_DATA=CA_DATA(:); end
[samples,nrois]=size(CA_DATA);

LOCS={};
VALS={};
idx=1:samples-1;

options.Display = 'off';
options.MaxIter = max_iter;
options.UseParallel = 'always';
options.ObjectiveLimit = 0;
options.TolX=1e-9;
options.TolFun=1e-9;
options.MaxFunEvals= max_iter;

[nblanks formatstring]=fb_progressbar(100);
fprintf(1,['Progress:  ' blanks(nblanks)]);

if debug
	mkdir('debug_peak');
end

for i=1:nrois

	fprintf(1,formatstring,round((i/nrois)*100));

	LOCS{i}=[];
	VALS{i}=[];

	% find first threshold crossing
	% center at 0

	curr_roi=CA_DATA(:,i)-prctile(CA_DATA(:,i),5);
    	%curr_roi=CA_DATA(:,i);

	% get the positive threshold crossings

	pos_crossing=find(curr_roi(idx)<thresh_hi&curr_roi(idx+1)>thresh_hi)+1;
	schmitt_flag=zeros(1,length(pos_crossing));
	
	for j=1:length(pos_crossing)

		init_guess=pos_crossing(j);

		% do we stay above the low threshold for a sufficient amount of time?

       
		if init_guess+thresh_t<samples
			schmitt_flag(j)=all(curr_roi(init_guess+1:init_guess+thresh_t)>thresh_lo);
		else
			schmitt_flag(j)=all(curr_roi(init_guess:end)>thresh_lo);
		end

		% attempt to fit the double exponential model, fit A, onset time, and tau

	end

	schmitt_flag
	pos_crossing=pos_crossing(schmitt_flag==1);
	
	time_vec=[1:length(curr_roi)]./fs;
	samples_vec=1:length(curr_roi);

	if isempty(pos_crossing)
		continue;
	end

	if debug
		fig=figure(1);
		cla;plot(time_vec,curr_roi);
		ylabel('df/f (Percent)');
		xlabel('Time (s)');
		hold on;
	end



	for j=1:length(pos_crossing)
		
		spk_t=pos_crossing(j)./fs;	

		%if ~(curr_roi(pos_crossing(j)+1)>thresh_hi)
			%continue;
		%end

		%spk_t=fit_window(1)/fs;

		%fit_win=fit_window;
		
		%if pos_crossing(j)-fit_window(1)<1
		%	fit_win(1)=pos_crossing(j)-fit_window(1);
		%end
		%
		%if pos_crossing(j)+fit_window(2)>length(curr_roi)
		%	fit_win(2)=length(curr_roi)-pos_crossing(j);
		%end

		%tmp_dff=curr_roi(pos_crossing(j)-fit_win(1):pos_crossing(j)+fit_win(2));

		tmp_dff=curr_roi;
		tmp_dff(samples_vec<(pos_crossing(j)-fit_window(1)))=0;
		tmp_dff(samples_vec>(pos_crossing(j)+fit_window(2)))=0;

		switch lower(method(1))

		
			case 'f'
				[x]=fminsearch(@(x) obj_function_onset(x,tmp_dff,fs,t_1),...
					[ onset_init_guess spk_t ],options);
			case 's'
				x=simulannealbnd(@(x) obj_function_onset(x,tmp_dff,fs,t_1),... 
					[ onset_init_guess spk_t ] ,...
					[ onset_lbound spk_t-spk_delta ],...
					[ onset_hbound spk_t+spk_delta ],...
					options);
			case 'p'
				[x] = patternsearch(@(x) obj_function_onset(x,tmp_dff,fs,t_1),[onset_init_guess spk_t],...
					[],[],[],[],...
					[onset_lbound spk_t-spk_delta],...
					[onset_hbound spk_t+spk_delta],[],options);
			case 'g'
				[x, fval , exitFlag, output] = ga(@(x) obj_function_onset(x,tmp_dff,fs,t_1),...
					length(onset_init_guess)+1,[],[],[],[],...
					[onset_lbound spk_t-spk_delta],...
					[onset_hbound spk_t+spk_delta],[],options);

			otherwise
				error('Did not understand optimization method');
		
		end

		A=x(1);
		t_on=x(2)
		t_0=x(3);

		%onset_time=(t_0+pos_crossing(j)/fs)-fit_window(1)/fs
		onset_time=t_0;
		%new_time_vec=-5:1/fs:time_vec(end)+5;
		y1=calcium_model_onset(A,t_on,onset_time,t_1,time_vec);


		if onset_only
			LOCS{i}(end+1)=round(onset_time*fs);
			VALS{i}(end+1)=max(y1);
			continue;
		end
			
		switch lower(method(1))

			case 'f'
				[x]=fminsearch(@(x) obj_function_full(x,tmp_dff,fs,t_0,t_on),...
					[ full_init_guess spk_t ],options);
			case 's'
				x=simulannealbnd(@(x) obj_function_full(x,tmp_dff,fs,t_0,t_on),... 
					[ full_init_guess ] ,...
					[ full_lbound ],...
					[ full_hbound ],...
					options);
			case 'p'
				[x] = patternsearch(@(x) obj_function_full(x,tmp_dff,fs,t_0,t_on),full_init_guess,...
					[],[],[],[],full_lbound,full_hbound,[],options);
			case 'g'
				[x, fval , exitFlag, output] = ga(@(x) obj_function_full(x,tmp_dff,fs,t_0,t_on),...
					length(full_init_guess),[],[],[],[],full_lbound,full_hbound,[],options);
			otherwise
				error('Did not understand optimization method');
		
		end
		
		A_1=x(1);
		A_2=x(2);
		t_1=x(3);
		t_2=x(4);

		%y2=calcium_model_full(onset_time,t_on,A_1,A_2,t_1,t_2,new_time_vec);
		y2=calcium_model_full(onset_time,t_on,A_1,A_2,t_1,t_2,time_vec);

		if trapz(y2)<thresh_int
			continue;
		end	

		[maxval onset_time]=max(y2);
		
		%LOCS{i}(end+1)=round(onset_time*fs);
		%VALS{i}(end+1)=max(y2);
		%
		
		LOCS{i}(end+1)=onset_time;
		VALS{i}(end+1)=maxval;

		if debug
			figure(1);
			hold on;		
			
			h(1)=plot(time_vec,y1,'g-');
			h(2)=plot(time_vec,y2,'r-');

			legend(h,'Onset fit','Full model');
			title(['ROI:  ' num2str(i)]);
	
		end

		curr_roi=curr_roi-y2(:);

		%if debug
		%	figure(2);
		%	plot(curr_roi);
		%end

	end

	if debug
		multi_fig_save(fig,debug_dir,[ debug_filename '_roi_' sprintf('%04.0f',i) ],'eps,fig');	
	end

end

fprintf(1,'\n');

end

function res = obj_function_onset(x,dff,fs,t_1)
%
%
%
%

A=x(1);
t_on=x(2);
t_0=x(3);

time_vec=[1:length(dff)]./fs;

y=calcium_model_onset(A,t_on,t_0,t_1,time_vec);
res=sum((y(:)-dff(:)).^2);

end

function res = obj_function_full(x,dff,fs,t_0,t_on)

A_1=x(1);
A_2=x(2);
t_1=x(3);
t_2=x(4);

time_vec=[1:length(dff)]./fs;

y=calcium_model_full(t_0,t_on,A_1,A_2,t_1,t_2,time_vec);
res=sum((y(:)-dff(:)).^2);

end

function y = calcium_model_onset(A,t_on,t_0,t_1,t)
%
%
%
%

y = A.*(1-exp(-(t-t_0)./t_on)).*exp(-(t-t_0)./t_1);
y(t<=t_0)=0;

end

function y = calcium_model_full(t_0,t_on,A_1,A_2,t_1,t_2,t)

y=(1-exp(-(t-t_0)./t_on)).*(A_1.*exp(-(t-t_0)./t_1)+A_2.*exp(-(t-t_0)./t_2));
y(t<=t_0)=0;

end
