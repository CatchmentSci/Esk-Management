function [] = Figure4_JoEM(scratch)

% Usage:  [] = Figure4_JoEM(scratch);

% Required input:
% scratch: The working directory where the raw data files, and dependancies
% will be downloaded to. It is recommended that pwd is used as this is
% commonly the MATLAB folder. If an alternative folder is desired this
% should be assigned using quotation marks (e.g. 'C:\Users\nm785\Documents').

% Outputs:
% None

% Description: This script utilises data deposited at 
% https://doi.pangaea.de/10.1594/PANGAEA.867534.
% This script is used to reproduce Figure 4 within the research
% paper of Perks et al (2016) Use of spatially distributed time-integrated 
% sediment sampling networks and distributed fine sediment modeling to inform 
% catchment management. Journal of Environmental Management (SI: Enlarging 
% spatial and temporal scales for biophysical diagnosis and sustainable river
% management). Citation: Perks, MT (2016) Figure 4 of 'Use of spatially 
% distributed time-integrated sediment sampling networks and distributed fine
% sediment modeling to inform catchment management, GitHub repository.
%
% Dependencies: This script is designed for machines running MATLAB v9.0 or 
% above and Statistics and Machine Learning Toolbox v10.2.

cd(scratch); % Use the pre-assigned temporary space
outfilename = websave('rawData.txt','https://doi.pangaea.de/10.1594/PANGAEA.867522?format=textfile'); % Download data
websave('readtext.m', 'https://raw.githubusercontent.com/CatchmentSci/Glaisdale-Beck-diversion-scheme/master/readtext.m'); % Download dependancy
[data_text,~] = readtext(outfilename, '	', '','','textual'); % read in the tab delimeted data
siteNames = data_text(15:end,1); % Create the site name array
timeStamp = data_text(15:end,2); % Create the timestamp array
timeStamp = regexprep(timeStamp,'T',' ');
L_est = str2double(data_text(15:end,3)); % Create the L_est array

siteNamesUse = {'6 Arch Bridge';'Beck Hole (Eller Beck)';'Butter Beck';'Commondale';'Danby 9A (L)';'Danby Beck';'Egton Bridge';'Esk at Glaisdale';'Glaisdale Beck';'Great Fryup';'Grosmont';'Hob Hole';'Lealholm';'Stonegate';'Tower Beck';'West Beck';'Westerdale'};
for a = 1:length(siteNamesUse)
    in = find(strcmp(siteNamesUse(a,1),siteNames) == 1);
    Lin(a,1:length(in)) = L_est(in);
    clear in
end
    
cellstr(datestr(datenum(timeStamp,'yyyy-mm-dd'),'dddd,HHMM,dd'));
split1 = regexp(ans, ',', 'split');

period_load_tonnes = 28.4446.*Lin.^0.8363; %non-linear least squares
catchment_area_km = [87.4982500000000;29.7387500000000;8.84180000000000;25.0100000000000;95.7400000000000;12.3878500000000;188.892250000000;177.650250000000;15.5596750000000;14.0410500000000;286.570000000000;17.3403500000000;128.110000000000;16.5616250000000;6.72145000000000;42.9900000000000;18.9987750000000];
in1 = repmat(catchment_area_km,[1,23]);
period_yield_tonnes = period_load_tonnes./in1;
[a1,b] = sort(catchment_area_km);
siteNamesUse = siteNamesUse(b);

period_yield_tonnes = period_yield_tonnes(b,:);
period_yield_tonnes(period_yield_tonnes==0) = NaN;
period_yield_tonnes = period_yield_tonnes(:,[1:2,4:end]); % Remove the 4/12/07 collection
proportion_of_year = [2.08219178082192;2.08219178082192;2.08219178082192;2.08219178082192;2.08219178082192;2.08219178082192;2.08219178082192;2.08219178082192;2.08219178082192;1.59726027397260;2.08219178082192;1.62465753424658;1.98630136986301;1.87671232876712;2.08219178082192;2.08219178082192;2.08219178082192;2.08219178082192;1.45753424657534;1.72328767123288;2.00821917808219;2.00821917808219];
proportion_of_year = proportion_of_year([1:5,7:10,15:22],:);
annualYields = nansum(period_yield_tonnes')'./proportion_of_year;

collectionDates = {'24/10/2007 00:00', '16/11/2007 00:00', '22/12/2007 00:00', '27/01/2008 00:00', '26/02/2008 00:00',...
    '05/04/2008 00:00', '03/05/2008 00:00', '07/06/2008 00:00', '03/07/2008 00:00', '03/08/2008 00:00', '30/08/2008 00:00', ...
    '28/09/2008 00:00', '12/11/2008 00:00', '17/12/2008 00:00', '30/01/2009 00:00', '06/03/2009 00:00', '04/04/2009 00:00', ...
    '09/05/2009 00:00', '10/06/2009 00:00', '13/07/2009 00:00', '22/08/2009 00:00', '20/10/2009 00:00'};
formatIn = 'dd/mm/yyyy HH:MM';
collectionDates = datenum(collectionDates,formatIn);

% Process the rainfall for the Danby MIDAS station for 2007-10
outfilename = websave('rawData.txt','https://doi.pangaea.de/10.1594/PANGAEA.867519?format=textfile'); % Download data
[data_text,~] = readtext(outfilename, '	', '','','textual'); % read in the tab delimeted data
dailyRainfallDates = data_text(15:end,1);
dailyRainfallDates = regexprep(dailyRainfallDates,'T',' ');
dailyRainfallDates = datenum(dailyRainfallDates ,'yyyy-mm-dd');
dailyRainfall = str2double(data_text(15:end,2));

rainfallPeriods = datenum('22/09/2007 00:00' ,'dd/mm/yyyy HH:MM');
rainfallPeriods(2:length(collectionDates)+1,1) = collectionDates;
for a = 1:length(rainfallPeriods);
    index(a,1) = find(dailyRainfallDates == rainfallPeriods(a,1));
    if a < 23
        centralXvalue(a,1) = (rainfallPeriods(a+1,1)-rainfallPeriods(a,1))/2+rainfallPeriods(a,1);
    end
end

for a = 1:length(rainfallPeriods);
    index(a,1) = find(dailyRainfallDates == rainfallPeriods(a,1));
    if a < 23
        rainfalltotalPeriod(a,1) = sum(dailyRainfall(index(a,1):index(a+1,1)));
    end
end

% This section produces the multi-panel SSY figure
f1 = figure();
set(f1,'DefaultTextFontname', 'cmr12');
set(f1,'DefaultAxesFontName', 'cmr12');
set(f1,'DefaultAxesFontSize',14);
axes1 = axes('Parent',f1,...
    'Position',[0.13 0.252482517482517 0.102256944444444 0.672517482517483]);
hold(axes1,'on');
subplot(6,6,[1 7 13 19 25]);
plot(a1,annualYields,'k'); hold on; %cannot use loads
scatter(a1,annualYields,'kx');
camroll(270);
set(gca,'XScale','log');
set(gca,'YTick',[0,1500]);

L1 = [6, 300];
set(gca,'XLim',L1);
grid on; box on;
xlabel('Catchment Area (km^{2})');
ylabel('SSY (t km^{-2} yr^{-1})');

subplot(6,6,[2:6 8:12 14:18 20:24 26:30]);
originalSize = get(subplot(6,6,[2:6 8:12 14:18 20:24 26:30]), 'Position');
collectionDates = {'24/10/2007 00:00', '16/11/2007 00:00', '22/12/2007 00:00', '27/01/2008 00:00', '26/02/2008 00:00',...
    '05/04/2008 00:00', '03/05/2008 00:00', '07/06/2008 00:00', '03/07/2008 00:00', '03/08/2008 00:00', '30/08/2008 00:00', ...
    '28/09/2008 00:00', '12/11/2008 00:00', '17/12/2008 00:00', '30/01/2009 00:00', '06/03/2009 00:00', '04/04/2009 00:00', ...
    '09/05/2009 00:00', '10/06/2009 00:00', '13/07/2009 00:00', '22/08/2009 00:00', '20/10/2009 00:00'};
formatIn = 'dd/mm/yyyy HH:MM';
collectionDates = datenum(collectionDates,formatIn);

%Plot the main image
[X,Y] = meshgrid(collectionDates,a1);
c = period_yield_tonnes;
[ax, p1, p2] = plotyy(X(:), Y(:), X(:), Y(:), @scatter, @scatter);
set(p2,'Visible','off') % remove duplicate data
set(p1,'MarkerFaceColor','k')
set(p1,'MarkerEdgeColor','k')
set(p1,'SizeData', c(:)*0.5)
set(ax,'layer','top');
set(ax,'YScale','log');
set(ax,'YDir','reverse');
set(ax,'YLim',L1)
set(ax(1),'YAxisLocation','left');
set(ax(1),'YTick',[10,100]); %set the major grid lines
set(ax(1),'YTickLabel',[]); % remove the catchment area lables
set(ax(2),'YTick',[])
grid on; box off;
set(ax(2),'YAxisLocation','right');
set(ax(2),'YTick',Y(:,1)) %assign ticks based on catchment area
set(ax(2),'YTickLabel',1:17); %display the id for each site
ylabel(ax(2),'Site Identifier') % right y-axis
L2 = [733300, 734100];
set(ax,'XLim',L2);
NumTicks = 7;
set(ax,'XTick',linspace(L2(1),L2(2),NumTicks));
set(ax,'xaxisLocation','top')
datetick('x','mmm yy', 'keepticks');
set(ax, 'Position', originalSize); % reset the size of the graph

% Plot the colormap
inv = subplot (6,6,[31]);
set(inv,'Visible','off');
set(get(inv,'Children'),'Visible','off');

c1 = ~isnan(c); c1 = c(c1)*0.5;
bubsizes = [min(c1) quantile(c1,[0.85, 0.9, 0.95]) max(c1)];legentry=cell(size(bubsizes));
for ind = 1:numel(bubsizes)
   bubleg(ind) = plot(0,0,'ro','MarkerFaceColor','black'); hold on
   set(bubleg(ind),'visible','off')
   set(bubleg(ind),'MarkerEdgeColor','black')
   set(bubleg(ind),'MarkerSize',sqrt(bubsizes(ind)))
   legentry{ind} = num2str(bubsizes(ind)*2);
end
l1 = legend(legentry);
hlt = text(...
    'Parent', l1.DecorationContainer, ...
    'String', 'SSY over interval (t km^{-2})', ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', ...
    'Position', [0.5, 1.05, 0],...;
    'FontSize', 14,...
    'Rotation',90,...
    'Position',[-0.134615384615385 1.14302325581395 0]);
axis off

%Plot the rainfall bar chart
hold on
subplot (6,6,[32:36])
originalSize3 = get(subplot (6,6,[32:36]), 'Position');
figD = bar(centralXvalue,rainfalltotalPeriod, 'hist');
set(figD,'FaceColor','k')
sh = findobj(gca,'Type','line');
set(sh,'Marker','none'); 
set(sh,'Color','k')
set(gca,'YAxisLocation','right');
grid on; box on;
NumTicks = 7;
L2 = [733300, 734100];
set(ax,'XLim',L2);
set(gca,'XTick',linspace(L2(1),L2(2),NumTicks));
datetick('x','mmm yy', 'keepticks');
ylabel('Rainfall (mm)');

pos = [420,207,924,648];
set(gcf,'Position',pos);


