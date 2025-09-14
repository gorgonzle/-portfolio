%---------------------------- PSO fitting --------------------------------%
% Writer: Minsang Kim                                                     %
%Date 2024-07-10                                                          %
%-------------------------------------------------------------------------%
function [data,space,path,opt] = GC_9()
%%---------------------------------------------------create 'expdat' STRUCT
time_s = cell(1,3);
time_s{1} = [
    5.92E+02	7.56E+02	9.20E+02	1.08E+03	1.25E+03...
    1.41E+03    1.58E+03	1.74E+03	1.91E+03	2.07E+03	2.23E+03...
    2.40E+03    2.56E+03	2.73E+03	2.89E+03	3.06E+03	3.22E+03...
    3.39E+03    3.55E+03	3.71E+03	3.88E+03	4.04E+03	4.21E+03...
    4.37E+03    4.54E+03	4.70E+03	4.86E+03	5.03E+03	5.19E+03...
    5.36E+03    5.52E+03	5.69E+03	5.85E+03	6.01E+03	6.18E+03...
    6.34E+03    6.51E+03	6.67E+03	6.84E+03	7.00E+03
    ];

time_s{2} = [
    5.88E+02	6.62E+02	7.35E+02	8.09E+02	8.82E+02...
    9.55E+02    1.03E+03	1.10E+03	1.18E+03	1.25E+03	1.32E+03...
    1.40E+03    1.47E+03	1.54E+03	1.62E+03	1.69E+03	1.76E+03...
    1.84E+03    1.91E+03	1.98E+03	2.06E+03	2.13E+03	2.20E+03...
    2.28E+03    2.35E+03	2.42E+03	2.50E+03	2.57E+03	2.64E+03...
    2.72E+03    2.79E+03	2.86E+03	2.94E+03	3.01E+03	3.08E+03...
    3.16E+03    3.23E+03	3.30E+03	3.38E+03	3.45E+03
    ];

time_s{3} = [
    8.07E+02	8.51E+02	8.95E+02	9.39E+02	9.83E+02...
    1.03E+03	1.07E+03	1.11E+03	1.16E+03	1.20E+03	1.25E+03...
    1.29E+03	1.33E+03	1.38E+03	1.42E+03	1.47E+03	1.51E+03...
    1.55E+03	1.60E+03	1.64E+03	1.68E+03	1.73E+03	1.77E+03...
    1.82E+03	1.86E+03	1.90E+03	1.95E+03	1.99E+03	2.04E+03...
    2.08E+03	2.12E+03	2.17E+03	2.21E+03	2.25E+03	2.30E+03...
    2.34E+03	2.39E+03	2.43E+03	2.47E+03	2.52E+03
    ];

sim_x = cell(1,3);

for i = 1:numel(time_s)
    sim_x{i} = time_s{i};
end

temp = readmatrix("sealant7001.csv", 'Range', 'A2:A47');
exp_x{1} = temp.';
temp = readmatrix("sealant7001.csv", 'Range', 'B2:B47');
exp_y{1} = temp.';

temp = readmatrix("sealant7501.csv", 'Range', 'A2:A29');
exp_x{2} = temp.';
temp = readmatrix("sealant7501.csv", 'Range', 'B2:B29');
exp_y{2} = temp.';

temp = readmatrix("sealant800.csv", 'Range', 'A2:A21');
exp_x{3} = temp.';
temp = readmatrix("sealant800.csv", 'Range', 'B2:B21');
exp_y{3} = temp.';

data = struct('exp_x',exp_x,'exp_y',exp_y,'sim_x',sim_x);
%%----------------------------------------------------create 'Space' STRUCT
lb = [-20, 1, -1.5, 0];
% range mode: 하한, nomalize mode: 평균
ub = [0, 2.5, 0, 70000];
% range mode: 상한, nomalize mode: 표준편차
numpar = 200;

space = struct('lb',lb,'ub',ub,'numpar',numpar);
%%-----------------------------------------------------create 'path' STRUCT
ansysPath = ['"C:\Program Files\ANSYS Inc\v231\Framework\bin\Win64' ...
    '\RunWB2.exe"'];
casefile = "case\GC_9\sealant_ringonringv2_files";


path = struct('ansyspath',ansysPath, 'casefile',casefile);
%%------------------------------------------------------create 'opt' STRUCT
mode  = 'custom';
maxEpoch = 20;
batch = 25;
log10comp = [1];

opt = struct('mode',mode,'maxEpoch',maxEpoch,'batch',batch, ...
    'log10comp',log10comp);
