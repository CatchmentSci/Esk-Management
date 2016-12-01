function [RHO,PVAL] = Figure5_JoEM(scratch)

% Usage:  [] = Figure5_JoEM(scratch);

% Required input:
% scratch: The working directory where the raw data files, and dependancies
% will be downloaded to. It is recommended that pwd is used as this is
% commonly the MATLAB folder. If an alternative folder is desired this
% should be assigned using quotation marks (e.g. 'C:\Users\nm785\Documents').

% Outputs:
% RHO: Spearman rank correlation between model results and sediment yields
% PVAL: Statistical significane (P-value) associated with RHO

% Description:
% This script is used to reproduce Figure 5 within the research
% paper of Perks et al (2016) Use of spatially distributed time-integrated 
% sediment sampling networks and distributed fine sediment modeling to inform 
% catchment management. Journal of Environmental Management (SI: Enlarging 
% spatial and temporal scales for biophysical diagnosis and sustainable river
% management). Citation: Perks, MT (2016) Figure 5 of 'Use of spatially 
% distributed time-integrated sediment sampling networks and distributed fine
% sediment modeling to inform catchment management, GitHub repository.

% Dependencies: This script is designed for machines running MATLAB v9.0 or 
% above and Statistics and Machine Learning Toolbox v10.2.

cd(scratch); % Use the pre-assigned temporary space
scimapRisk = log10([0.0500696785750000;0.124422878030000;0.0706260651350000;0.0887788161640000;0.0756649523970000;0.0486190617080000;0.0274819396440000;0.0439084917310000;0.0379221141340000;0.0225262418390000;0.0276222657410000;0.0455056354400000;0.0456813089550000;0.0589798204600000;0.0607714913790000;0.0638281404970000;0.0561028234660000]);
annualYields = log10([109.490369895938;1411.15704703869;413.565264217057;322.204829193034;841.128917733550;249.071218627134;119.784008612723;110.877184738487;124.724811001765;118.350593700028;97.6227982618723;227.733634854065;130.369585800263;176.731446699968;177.917003776008;108.707679246916;87.1338006826739]);
h1 = figure();
set(h1,'DefaultTextFontname', 'cmr12');
set(h1,'DefaultAxesFontName', 'cmr12');
set(h1,'DefaultAxesFontSize',14);
h3 = scatter(annualYields,scimapRisk,'k+');
xlabel('Log_{10} (Specific Sediment Yield)');
ylabel('Log_{10} (Predicted In-channel Risk, \it{C_{j }})');
[RHO,PVAL] = corr(scimapRisk,annualYields,'type','Spearman');
