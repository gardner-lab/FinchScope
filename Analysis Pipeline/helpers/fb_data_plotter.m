function output=new_data_plotter(DATAFILE,SAVEFILE)
%GUI for choosing a cluster for ephys_cluster.m
%

% load the information collected by outloop

load(DATAFILE,'variableCellArray','peakLocation','property_names')

% load the scores, their locations, the file number, and
% the peak locations for subsequent saving

syllable_data=[];
idx=[];
file_idx=[];
peak_locations=[];
[junk,n_properties]=size(variableCellArray{1});

% everything is collapsed into vectors of the same size for simpler
% processing

for i=1:length(variableCellArray)
	[m,n]=size(variableCellArray{i});
	syllable_data=[syllable_data;variableCellArray{i}];
	idx=[idx;(1:m)'];
	peak_locations=[peak_locations;peakLocation{i}'];
	file_idx=[file_idx;ones(m,1).*i];
end

% run the PCA

[coef score variance t2]=princomp(syllable_data);

for i=1:length(variance)
	disp(['Principal component ' num2str(i) ' explains ' num2str(100*variance(i)/sum(variance)) '% of the variance in the data']);
end

% generate the GUI

for i=1:3
	property_names{end+1}=[ 'PC ' num2str(i)];
end

%if n_properties==8
%	property_names={'angle1', 'angle2', 'deriv1', 'deriv2', 'amp','entropy','product','curvature','PC1','PC2','PC3'};
%else
%	property_names={'angle1', 'angle2', 'deriv1', 'deriv2', 'amp','entropy','product','curvature','ephys_score','PC1','PC2','PC3'};
%	%syllable_data(:,8)=zscore(syllable_data(:,8));
%end
	
syllable_data=[syllable_data,score(:,1:3)];

main_window=figure('Visible','off','Position',[360,500,700,600],'Name','Data Plotter','NumberTitle','off');

plot_axis=axes('Units','pixels','Position',[50,50,400,400]);

pop_up_x= uicontrol('Style','popupmenu',...
	'String',property_names,...
	'Position',[400,90,75,25],'call',@change_plot,...
	'Value',5);
pop_up_x_text= uicontrol('Style','text',...
	'String','X',...
	'Position',[405,130,50,45]);

pop_up_y= uicontrol('Style','popupmenu',...
	'String',property_names,...
	'Position',[495,90,75,25],'call',@change_plot,...
	'Value',6);
pop_up_y_text= uicontrol('Style','text',...
	'String','Y',...
	'Position',[500,130,50,45]);

pop_up_z= uicontrol('Style','popupmenu',...
	'String',property_names,...
	'Position',[595,90,75,25],'call',@change_plot,...
	'Value',7);
pop_up_z_text= uicontrol('Style','text',...
	'String','Z',...
	'Position',[600,130,50,45]);

pop_up_clusters= uicontrol('Style','popupmenu',...
	'String',[2:9],...
	'Position',[475,210,75,25],'call',@change_plot);
pop_up_clusters_text= uicontrol('Style','text',...
	'String','Number of Clusters',...
	'Position',[500,250,100,45]);

pop_up_choice= uicontrol('Style','popupmenu',...
	'String',[1:9],...
	'Position',[475,330,75,25]);
pop_up_choice_text= uicontrol('Style','text',...
	'String','Cluster selection',...
	'Position',[500,370,100,45]);

push_replot_save= uicontrol('Style','pushbutton',...
	'String','Save',...
	'Position',[500,40,100,25],'call',@save_data);

push_draw_mode= uicontrol('Style','pushbutton',...
	'String','Draw mode (x and y only)',...
	'Position',[500,450,100,35],'value',0,...
	'Call',@change_plot);

rows=ceil(length(property_names)/5);

i=1;
while i<=length(property_names)
	row=ceil(i/5);
	column=mod(i,5);
	if column==0, column=5; end

	cluster_data_check{i}=uicontrol('Style','checkbox',...
		'String',property_names{i},...
		'Value',0,'Position',[50+column*60,600-row*35,70,25]);
	set(cluster_data_check{i},'Units','Normalized')
	i=i+1;
end


% now align everything and send the main_window handle to the output
% so we can use the gui with uiwait (requires the handle as a return value)

align([pop_up_clusters,pop_up_clusters_text,pop_up_choice,pop_up_choice_text,push_replot_save],'Center','None');
align([pop_up_x,pop_up_x_text],'Center','None');
align([pop_up_y,pop_up_y_text],'Center','None');
align([pop_up_z,pop_up_z_text],'Center','None');

output=gcf;

% run change_plot, which updates the plot according to the defaults

change_plot();
cluster=guidata(main_window);
[dummy min_centroid]=min(cluster.within_sum);

set(pop_up_choice,'string',[1:length(unique(cluster.labels))])
set(pop_up_choice,'value',min_centroid);

set([main_window,plot_axis,pop_up_x,pop_up_x_text,pop_up_y,pop_up_y_text,pop_up_z,...
	pop_up_z_text,pop_up_clusters,pop_up_clusters_text,pop_up_choice,pop_up_choice_text,...
	push_replot_save,push_draw_mode],'Units','Normalized');
movegui(main_window,'center')
set(main_window,'Visible','On')

%% Callbacks

% this callback changes the plot and returns the sum of the distances
% from the centroid for each point in a cluster

function change_plot(varargin)

% get the number of dimensions for the plot (number of principal components)


colors={'b','r','g','c','m','y','k','r','g','b'};
dim(1)=get(pop_up_x,'value');
dim(2)=get(pop_up_y,'value');
dim(3)=get(pop_up_z,'value');

draw_mode=get(push_draw_mode,'value');

for i=1:length(cluster_data_check)
	set(cluster_data_check{i},'value',0)
end

for i=1:length(dim)
	set(cluster_data_check{dim(i)},'value',1);
end

choices=get(pop_up_clusters,'string');
clusternum=str2num(choices(get(pop_up_clusters,'value')));

% perform the kmeans analysis and return the labels, centroid coordinates,
% sum of all points in each cluster from their respective centroid and
% the distance of all points from all centroids

cluster_data=syllable_data(:,dim);
[cluster.labels cluster.centroids cluster.within_sum cluster.all_dist]=kmeans(cluster_data,clusternum);
guidata(main_window,cluster)

% clear the plot axis

cla;
ndims=length(dim);
% plot in either 2 or 3 dims

% turns out plot is MUCH faster than scatter, changed accordingly...

if draw_mode
	ndims=2;
	plot(cluster_data(:,1),cluster_data(:,2),'o','markerfacecolor',colors{1});view(2);
	hold on
	disp('Select the corners of the enclosing polygon then press RETURN to continue...');
	hold off;
	[xv,yv]=ginput;
	k=convhull(xv,yv);
	plot(xv(k),yv(k),'b-','linewidth',1.25);
	hold on;
	cluster.labels=inpolygon(cluster_data(:,1),cluster_data(:,2),xv(k),yv(k))+1;
	cluster.inpolygon=1;
	cluster.convhull=[xv(k) yv(k)];
	clusternum=2;
end


switch ndims
	case 2
		for i=1:clusternum
			clusterid{i}=num2str(i);
			points=find(cluster.labels==i);
			h(:,i)=plot(cluster_data(points,1),cluster_data(points,2),...
				'o','markerfacecolor',colors{i},'markeredgecolor','none');hold on
		end
		view(2)
	case 3
		for i=1:clusternum
			clusterid{i}=num2str(i);
			points=find(cluster.labels==i);
			h(:,i)=plot3(cluster_data(points,1),cluster_data(points,2),cluster_data(points,3),...
				'o','markerfacecolor',colors{i},'markeredgecolor','none');hold on

		end
		grid on
		view(3)

end


% label everything

xlabel(property_names{dim(1)});ylabel(property_names{dim(2)});zlabel(property_names{dim(3)})
set(pop_up_choice,'string',[1:length(unique(cluster.labels))])
L=legend(h,clusterid,'Location','NorthEastOutside');legend boxoff


set(L,'FontSize',20,'FontName','Helvetica')

% pass the labels back to main function via guidata since
% we share with save_data

guidata(main_window,cluster);

end	


function save_data(varargin)

% get the labels from the main_window

cluster=guidata(main_window);
choices=get(pop_up_choice,'string');
cluster.choice=str2num(choices(get(pop_up_choice,'value')));
cluster.selection=find(cluster.labels==cluster.choice);

%[cluster.center cluster.edistance]=...
%	cluster_dispersion(syllable_data(cluster.selection,1:end-3),syllable_data(cluster.selection,end-2:end));

% can alternately just use pdist to compute the pairwise distance!

% now return the indices of our selection 

idxs=idx(cluster.selection);

% get the file each index comes from

file_idxs=file_idx(cluster.selection);
peak_locs=peak_locations(cluster.selection);

% put everything back into a cell array where
% each cell is a data file 

for i=1:length(variableCellArray)
	temp=find(file_idxs==i);
	sorted_syllable{i}=peak_locs(temp);
end

% save to syllable_data.mat for extract

% train a Naive Bayes classifier based on the sellection

% use all dimensions except PCA

%bayesobject=NaiveBayes.fit(syllable_data(:,[1:6]),cluster.labels);
disp('Training classifier on your selection...');

% fix for MATLAB 2010a complaining about too many iterations...enforce that method=smo
% switched to quadratic kernel function 5/28/13, linear was found to be insufficient in edge-cases

classobject=svmtrain(syllable_data(:,[1:6]),cluster.labels,'method','smo','kernel_function','quadratic');

[path,file,ext]=fileparts(SAVEFILE);
cluster_choice=cluster.choice;

save(SAVEFILE,'sorted_syllable','syllable_data','cluster','property_names','classobject')

% store classify data, place in a separate directory with template for automatic clustering

save(fullfile(path,['classify_data.mat']),'classobject','cluster_choice');

disp(['Data successfully saved!']);

end

end
