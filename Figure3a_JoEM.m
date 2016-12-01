function [] = Figure3a_JoEM(scratch)

% Usage:  [] = Figure3a_JoEM(scratch);

% Required input:
% scratch: The working directory where the raw data files, and dependancies
% will be downloaded to. It is recommended that pwd is used as this is
% commonly the MATLAB folder. If an alternative folder is desired this
% should be assigned using quotation marks (e.g. 'C:\Users\nm785\Documents').

% Outputs:
% None

% Description: This script utilises data deposited at 
% https://doi.pangaea.de/10.1594/PANGAEA.867534.
% This script is used to reproduce Figure 3 within the research
% paper of Perks et al (2016) Use of spatially distributed time-integrated 
% sediment sampling networks and distributed fine sediment modeling to inform 
% catchment management. Journal of Environmental Management (SI: Enlarging 
% spatial and temporal scales for biophysical diagnosis and sustainable river
% management). Citation: Perks, MT (2016) Figure 3a of 'Use of spatially 
% distributed time-integrated sediment sampling networks and distributed fine
% sediment modeling to inform catchment management, GitHub repository.
%
% Dependencies: This script is designed for machines running MATLAB v9.0 or 
% above and Statistics and Machine Learning Toolbox v10.2.

% Load the datasets
cd(scratch); % Use the pre-assigned temporary space
outfilename = websave('rawData.txt','https://doi.pangaea.de/10.1594/PANGAEA.867520?format=textfile'); % Download data
websave('readtext.m', 'https://raw.githubusercontent.com/CatchmentSci/Glaisdale-Beck-diversion-scheme/master/readtext.m'); % Download dependancy
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

% This is the sub-daily spot sample extraction section
Weekends = {'Saturday   ', 'Sunday   '};
workingHours(1:length(split1),1) = 1;
for a = 1:length(split1); % one means working day/time
    if sum(strcmp(split1{a, 1}{1, 1},Weekends)) > 0 || str2double(split1{a, 1}{1, 2}) < 0900 || str2double(split1{a, 1}{1, 2}) > 1700
        workingHours(a,1) = 0;
    end
end

me = 1;
c = 1; % Start at 1
loop_value = 1;
reference_conc = nanmean(ssc);
inputSSC = ssc(find((workingHours>0)&~isnan(ssc)));

while c < length(inputSSC)/2;
    aa = 1;
    while aa < 1001;
        a = 1;
        b = 1;
        iterations = length(inputSSC)/c;
        iterations = floor(iterations); % Remove last section as it is not complete
        
        % Produce completely random numbers
        p = randperm(length(inputSSC),iterations);
        sub_daily (1:length(p),1) = inputSSC(p,1);
        
        % Store the data
        mean_ssc (aa,1) = nanmean(sub_daily);
        if aa == 1000;
            prctile(mean_ssc(:,1),50);
            output_ssc(me,1) = (ans/reference_conc)*100;
            prctile(mean_ssc(:,1),25);
            output_ssc(me,2) = (ans/reference_conc)*100;
            prctile(mean_ssc(:,1),75);
            output_ssc(me,3) = (ans/reference_conc)*100;
        end
        
        aa = aa + 1;
    end
    
    me = me + 1;
    c = c + loop_value; % Increase by 1 each time
    clear  cell_number iterations p q a b cell_number_use number_of_seconds sub_daily
end
clear aa c iterations number_of_seconds cell_number_use ans sub_daily loop_value me

DaysElapsed = etime(datevec(timeStamp{end,1},'yyyy-mm-dd HH:MM'),datevec(timeStamp{1,1},'yyyy-mm-dd HH:MM'))/86400 ;
xFrac = length(output_ssc)./DaysElapsed;

x = 1:length(output_ssc);
x = x/32;%based on 9-5(8hr day), 32 points represnts one day
y1=output_ssc(:,2);%create first curve
y2=output_ssc(:,3); %create second curve
X=[x,fliplr(x)]; %create continuous x value array for plotting
Y=vertcat(y1,flipud(y2))';%create y values for out and then back
Y = Y - 100; % Deviation from reference (i.e. 100%)
h1 = figure();
set(h1,'DefaultTextFontname', 'cmr12');
set(h1,'DefaultAxesFontName', 'cmr12');
set(h1,'DefaultAxesFontSize',14);
h2 = fill(X,Y,'b'); hold on % plot filled area
set(h2,'EdgeColor','None')
set(h2,'FaceColor',[[186/255],[186/255],[186/255]])
plot(x,output_ssc(:,1)-100,'k');% Plot main dataset
set(gca,'XScale','log');
set(gca,'xtick',[0.1, 1, 10, 100]);
axis tight
grid on;
xlabel('Sample Interval (working days)');
ylabel('\% Deviation from reference ($\overline{ssc}) $','Interpreter','latex');
i1 = legend ('Interquartile Range','Median');
set(i1,'Location','northwest')

