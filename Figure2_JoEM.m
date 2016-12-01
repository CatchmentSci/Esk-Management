function [] = Figure2_JoEM(scratch)

% Usage:  [] = Figure2_JoEM(scratch);

% Required input:
% scratch: The working directory where the raw data files, and dependancies
% will be downloaded to. It is recommended that pwd is used as this is
% commonly the MATLAB folder. If an alternative folder is desired this
% should be assigned using quotation marks (e.g. 'C:\Users\nm785\Documents').

% Outputs:
% None

% Description: This script utilises data deposited at 
% https://doi.pangaea.de/10.1594/PANGAEA.867534.
% This script is used to reproduce Figure 2 within the research
% paper of Perks et al (2016) Use of spatially distributed time-integrated 
% sediment sampling networks and distributed fine sediment modeling to inform 
% catchment management. Journal of Environmental Management (SI: Enlarging 
% spatial and temporal scales for biophysical diagnosis and sustainable river
% management). Citation: Perks, MT (2016) Figure 2 of 'Use of spatially 
% distributed time-integrated sediment sampling networks and distributed fine
% sediment modeling to inform catchment management, GitHub repository.

% Dependencies: This script is designed for machines running MATLAB 9.0 or 
% above and Statistics and Machine Learning Toolbox 10.2.

cd(scratch); % Use the pre-assigned temporary space
outfilename = websave('rawData.txt','https://doi.pangaea.de/10.1594/PANGAEA.867520?format=textfile'); % Download data
websave('readtext.m', 'https://raw.githubusercontent.com/CatchmentSci/Glaisdale-Beck-diversion-scheme/master/readtext.m'); % Download dependancy
websave('replace.m','https://raw.githubusercontent.com/CatchmentSci/Glaisdale-Beck-diversion-scheme/master/replace.m');
[data_text,~] = readtext(outfilename, '	', '','','textual'); % read in the tab delimeted data


t1 = datetime(2007,09,21,12,0,0);
t2 = datetime(2007,11,22,4,30,1);
t = (t1:0.0104166666666667:t2)';
t = cellstr(datestr(t,'yyyy-mm-dd HH:MM'));
timeStamp = vertcat(t,data_text(15:end,1)); % Create the timestamp array
buffer(1:5923,1)= NaN;
ssc = vertcat(buffer, str2double(data_text(15:end,2))); % Create the ssc array
missing_data = [6233:6545, 7329:7424, 7685:10450, 10810:11530, 11890:12730, 13360:15860, 16470:16820, 18440:18880, 19480:20540,...
    24660:25640, 27440:29570, 37040:38370, 48880:49220, 52190:52530, 63630:63810, 65800:67990];
ssc(missing_data) = NaN; % Replace blanks with NaN

timeStamp = regexprep(timeStamp,'T',' ');
cellstr(datestr(datenum(timeStamp,'yyyy-mm-dd HH:MM'),'dddd,HHMM,dd'));
split1 = regexp(ans, ',', 'split');

Weekends = {'Saturday   ', 'Sunday   '};
workingHours(1:length(split1),1) = 1;
monthStart(1:length(split1),1) = 0;

for a = 1:length(split1); % one means working day/time
    if sum(strcmp(split1{a, 1}{1, 1},Weekends)) > 0 || str2double(split1{a, 1}{1, 2}) < 0900 || str2double(split1{a, 1}{1, 2}) > 1700
        workingHours(a,1) = 0;
    end
    if strcmp(split1{a, 1}{1, 2},'0000') && strcmp(split1{a, 1}{1, 3},'01')
        monthStart(a,1) = 1;
    end
end

reference_conc = nanmedian(ssc);

%find the first one and then first zero
s1 = 1; s2 = length(timeStamp); aa=1; en2 = 0;
while s1 < length(timeStamp);
    %calculate the reference over the whole week inc.
    en1 = find(monthStart(s1:s2) == 1,1)+en2; % Find the first 1st of the month series
    en2 = find(monthStart(en1+1:s2) == 1,1)+en1-1; % Find the last day of month
    fullMonth = en1:en2;
    if fullMonth > 0
        xTime1(aa,1) = timeStamp(round((en2-en1)/2+en1));
    else
        xTime1(aa,1) = timeStamp(round(mean([en1,s2])));
    end
    mean_ssc1 (aa,1) = nanmean(ssc(fullMonth)); %actual mean over month
    workingWeek = find(workingHours(fullMonth) == 1)+en1-1;
    working_ssc1(1:length(workingWeek),aa) = ssc(workingWeek); %Working week ssc
    working_ssc1 = replace(working_ssc1,0,NaN);

    prctile(working_ssc1(:,aa),50);
    if ~isnan(ans)
        output_ssc1(aa,1) = prctile(working_ssc1(1:length(workingWeek),aa),50);
        output_ssc1(aa,2) = prctile(working_ssc1(1:length(workingWeek),aa),25);
        output_ssc1(aa,3) = prctile(working_ssc1(1:length(workingWeek),aa),75);
        output_ssc1(aa,4) = (output_ssc1(aa,1)-mean_ssc1(aa,1))/mean_ssc1(aa,1)*100;
        output_ssc1(aa,5) = (output_ssc1(aa,2)-mean_ssc1(aa,1))/mean_ssc1(aa,1)*100; %Q25 as %
        output_ssc1(aa,6) = (output_ssc1(aa,3)-mean_ssc1(aa,1))/mean_ssc1(aa,1)*100; %Q75 as %
    end
    s1 = en2+1; aa = aa+1;
end


% Import Grosmont datset for analysis
outfilename = websave('rawData.txt','https://doi.pangaea.de/10.1594/PANGAEA.867521?format=textfile'); % Download data
websave('readtext.m', 'https://raw.githubusercontent.com/CatchmentSci/Glaisdale-Beck-diversion-scheme/master/readtext.m'); % Download dependancy

t1 = datetime(2007,09,21,12,0,0);
t2 = datetime(2008,02,01,08,15,0);
t = (t1:0.0104166666666667:t2)';
t = cellstr(datestr(t,'yyyy-mm-dd HH:MM'));
[data_text,~] = readtext(outfilename, '	', '','','textual'); % read in the tab delimeted data
timeStamp = vertcat(t,data_text(15:end,1)); % Create the timestamp array
buffer(1:12753,1)= NaN;
ssc = vertcat(buffer, str2double(data_text(15:end,2))); % Create the ssc array
missing_data = [28400:29580, 64770:65960, 66240:72990];
ssc(missing_data) = NaN; % Replace blanks with NaN

timeStamp = regexprep(timeStamp,'T',' ');
cellstr(datestr(datenum(timeStamp,'yyyy-mm-dd HH:MM'),'dddd,HHMM,dd'));
split1 = regexp(ans, ',', 'split');

Weekends = {'Saturday   ', 'Sunday   '};
workingHours(1:length(split1),1) = 1;
monthStart(1:length(split1)) = 0;

for a = 1:length(split1); % one means working day/time
    if sum(strcmp(split1{a, 1}{1, 1},Weekends)) > 0 || str2double(split1{a, 1}{1, 2}) < 0900 || str2double(split1{a, 1}{1, 2}) > 1700
        workingHours(a,1) = 0;
    end
    if strcmp(split1{a, 1}{1, 2},'0000') && strcmp(split1{a, 1}{1, 3},'01')
        monthStart(a,1) = 1;
    end
end


reference_conc = nanmedian(ssc);
reference_95th = prctile(ssc,95);

%find the first one and then first zero
s1 = 1; s2 = length(timeStamp); aa=1; en2 = 0;
while s1 < length(timeStamp);
    %calculate the reference over the whole week inc.
    en1 = find(monthStart(s1:s2) == 1,1)+en2; % Find the first 1st of the month series
    en2 = find(monthStart(en1+1:s2) == 1,1)+en1-1; % Find the last day of month
    fullMonth = en1:en2;
    if fullMonth > 0
        xTime2(aa,1) = timeStamp(round((en2-en1)/2+en1));
    else
        xTime2(aa,1) = timeStamp(round(mean([en1,s2])));
    end
    mean_ssc2 (aa,1) = nanmean(ssc(fullMonth)); %actual mean over month
    workingWeek = find(workingHours(fullMonth) == 1)+en1-1;
    working_ssc2(1:length(workingWeek),aa) = ssc(workingWeek); %Working week ssc
    working_ssc2 = replace(working_ssc2,0,NaN);
    
    prctile(working_ssc2(:,aa),50);
    if ~isnan(ans)
        output_ssc2(aa,1) = prctile(working_ssc2(1:length(workingWeek),aa),50);
        output_ssc2(aa,2) = prctile(working_ssc2(1:length(workingWeek),aa),25);
        output_ssc2(aa,3) = prctile(working_ssc2(1:length(workingWeek),aa),75);
        output_ssc2(aa,4) = (output_ssc2(aa,1)-mean_ssc2(aa,1))/mean_ssc2(aa,1)*100;
        output_ssc2(aa,5) = (output_ssc2(aa,2)-mean_ssc2(aa,1))/mean_ssc2(aa,1)*100; %Q25 as %
        output_ssc2(aa,6) = (output_ssc2(aa,3)-mean_ssc2(aa,1))/mean_ssc2(aa,1)*100; %Q75 as %%
    end
    s1 = en2+1; aa = aa+1;
end

% Plot the data
h = figure();
set(h,'DefaultTextFontname', 'cmr12');
set(h,'DefaultAxesFontName', 'cmr12');
set(h,'DefaultAxesFontSize',14);
ax1 = subplot(2,1,1);
x = 1:length(output_ssc1(:,1));
inc = find(output_ssc1(:,4) ~= 0);
h0 =errorbar(datenum(xTime1(inc),'yyyy-mm-dd HH:MM'),output_ssc1(inc,4),output_ssc1(inc,4)-output_ssc1(inc,6),output_ssc1(inc,5)-output_ssc1(inc,4));
set(h0,'LineStyle','none');
set(h0,'color', [0,0,0]);
hold on
h1 = scatter(datenum(xTime1(inc),'yyyy-mm-dd HH:MM'),output_ssc1(inc,4),'xk');
xLims = [733300, 734100];
set(ax1,'XLim',xLims);
datetick('x','mmm yy', 'keepticks');
hold on
h11 = fill([xLims(1,1), xLims(1,2),xLims(1,2),xLims(1,1)],[20,20,-20,-20],[0.5 0.5 0.5]);
set(h11,'facealpha',.5);
set(h11,'LineStyle','none');

ax2 = subplot(2,1,2);
inc = find(output_ssc2(:,4) ~= 0);
h2 = errorbar(datenum(xTime2(inc),'yyyy-mm-dd HH:MM'),output_ssc2(inc,4),output_ssc2(inc,4)-output_ssc2(inc,6),output_ssc2(inc,5)-output_ssc2(inc,4));
set(h2,'LineStyle','none');
set(h2,'color', [0,0,0]);
hold on
h3 = scatter(datenum(xTime2(inc),'yyyy-mm-dd HH:MM'),output_ssc2(inc,4),'xk');
set(ax2,'XLim',xLims);
datetick('x','mmm yy', 'keepticks');
hold on
t2 = ylabel('\% Deviation from reference ($\overline{ssc}) $','Interpreter','latex');
set(get(gca,'ylabel'),'Position',[733241.1386873496 96.05275078823702 0])
h4 = fill([xLims(1,1), xLims(1,2),xLims(1,2),xLims(1,1)],[20,20,-20,-20],[0.5 0.5 0.5]);
set(h4,'facealpha',.5);
set(h4,'LineStyle','none');
pos = [346,329,884,556];
set(gcf,'Position',pos);
    
    