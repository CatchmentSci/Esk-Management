function [siteNames, catchmentArea] = Figure1_JoEM(scratch)

% Usage:  [siteNames, catchmentArea] = Figure1_JoEM(scratch);

% Required input:
% scratch: The working directory where the raw data files, and dependancies
% will be downloaded to. It is recommended that pwd is used as this is
% commonly the MATLAB folder. If an alternative folder is desired this
% should be assigned using quotation marks (e.g. 'C:\Users\nm785\Documents').

% Outputs
% SiteNames: Name of each monitoring station
% catchmentArea: Catchment area of each monitoring station

% Description: This script utilises data deposited at 
% https://doi.pangaea.de/10.1594/PANGAEA.867534.
% This script is used to reproduce Figure 1 within the research
% paper of Perks et al (2016) Use of spatially distributed time-integrated 
% sediment sampling networks and distributed fine sediment modeling to inform 
% catchment management. Journal of Environmental Management (SI: Enlarging 
% spatial and temporal scales for biophysical diagnosis and sustainable river
% management). Map providing the regional setting of the Esk catchment (white 
% outline)in the NE of England, UK (inset). Map projection: OSGB 1936 British
% National Grid. Filled circles with numeric values represent the monitoring
% station locations and identifiers. Identifier names with (T) appended
% indicate turbidity monitoring stations. Background map: USGS Landsat 8
% imagery. Citation: Perks, MT (2016) Figure 1 of 'Use of spatially 
% distributed time-integrated sediment sampling networks and distributed fine
% sediment modeling to inform catchment management, GitHub repository.
%
% Dependencies: This script is designed for machines running MATLAB v9.0 
% or above and Mapping Toolbox v4.3 or above.

cd(scratch); % Use the pre-assigned temporary space
outfilename = websave('EskCatchmentOutline.zip','http://store.pangaea.de/Publications/PerksM-etal_2016/EskCatchmentOutline.zip'); % Download data
unzip('EskCatchmentOutline.zip',scratch); % Unzip the shapefiles
outfilename2 = websave('EskDrainageLine.zip','http://store.pangaea.de/Publications/PerksM-etal_2016/EskDrainageLine.zip'); % Download data
unzip('EskDrainageLine.zip',scratch); % Unzip the shapefiles
outfilename3 = websave('LandsatEsk.tif','http://store.pangaea.de/Publications/PerksM-etal_2016/LandsatEsk.tif'); % Download data
websave('readtext.m', 'https://raw.githubusercontent.com/CatchmentSci/Glaisdale-Beck-diversion-scheme/master/readtext.m'); % Download dependancy

filename = 'LandsatEsk.tif';
im = imread(filename);
[A, R] = geotiffread(filename); % Load in the background image
h = figure();
set(h,'DefaultTextFontname', 'cmr12');
set(h,'DefaultAxesFontName', 'cmr12');
set(h,'DefaultAxesFontSize',12);
mapshow(im,R); hold on;
S = shaperead([scratch, '\EskCatchmentOutline.shp']); % Load in the catchment outline
h1 = plot(S.X,S.Y,'w'); hold on % Plot the catchment outline;
set(h1,'LineWidth',2);
S2 = shaperead([scratch, '\EskDrainageLine.shp']); % Load in the river network
for a = 1:length(S2);
    h2 = plot(S2(a).X,S2(a).Y,'b'); set(h2,'LineWidth',3); % Plot the river network
end

% Define the locations of the sediment sampling stations
siteNames = {'Tower Beck';'Butter Beck';'Danby Beck';'Great Fryup';'Glaisdale Beck';'Stonegate Beck';'Baysdale Beck';'Esk at Westerdale';'Commondale Beck';'Eller Beck';'West Beck';'Esk at 6 Arch Bridge';'Esk at Danby (T)';'Esk at Lealholm';'Esk at Glaisdale';'Esk at Egton Bridge';'Esk at Grosmont (T)'};
catchmentArea = [6.72145000000000;8.84180000000000;12.3878500000000;14.0410500000000;15.5596750000000;16.5616250000000;17.3403500000000;18.9987750000000;25.0100000000000;29.7387500000000;42.9900000000000;87.4982500000000;95.7400000000000;128.110000000000;177.650250000000;188.892250000000;286.570000000000];
locationBNG(:,1) = [467500;479700;469200;474200;478300;478000;465300;466200;466415.98726015916327015;482500;481462.52259716374101117;469692.6966394690098241;471700;476298.0679671568213962;478500;480300;482488.39082530373707414];
locationBNG(:,2) = [507100;504900;508100;506900;505500;506700;507400;506200;509947.96178047760622576;502200;500242.57383639144245535;508279.05174862430430949;508300;507543.50533970160176978;505600;505200;505513.40220360283274204];
h3 = scatter(locationBNG(:,1),locationBNG(:,2),'k');% Scatter plot locations of the sediment sampling stations
set(h3,'MarkerFaceColor',h3.MarkerEdgeColor')
set(h3,'SizeData',50);
labels = num2str((1:size(locationBNG,1))','%d');
h4 = text(locationBNG(:,1), locationBNG(:,2), labels, 'horizontal','center', 'vertical','middle');
set(h4,'Color','w');
in1 = char(siteNames);
S1 = strcat(labels,{'    '},in1);
h5 = text(496726.268937393, 507058.982603746, vertcat('Legend',S1),...
    'horizontal','center',...
    'vertical','middle',...
    'Color', [.3 .3 .3]);
set(h5,'HorizontalAlignment','left')
hXlabel = xlabel('Eastings (m)'); % Create xlabel
hYlabel = ylabel('Northings (m)'); % Create ylabel
set([hXlabel, hYlabel]  , ...
    'FontSize'   , 14          );
set(gca,'XTick',[460000 470000 480000 490000],...
    'XTickLabel',{'460000','470000','480000','490000'},...
    'YMinorTick','on',...
    'XMinorTick','on',...
    'YTick',[500000 510000],...
    'YTickLabel',{'500000','510000'},...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3],...
    'FontSize', 12,...
    'Box'   ,'off');
grid on
set(gca, 'Layer', 'top')
pos = [335,325,1085,420];
set(gcf,'Position',pos);
end

