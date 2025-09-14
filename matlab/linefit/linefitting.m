clc; clear; close all;
%%------------------------------------------------------------Domain select
[data,space,path,opt,condition] = Ni_YSZ1();
%[data,space,path,opt] = GC_9();

%%------------------------------------------------------------Start Fitting
[bestPosition,bestvalue] = customPSO(data,space,path,opt);

fprintf(['PSO complete\n' ...
    'bestposition: %1.3f, %1.3f, %1.3f, %1.3f, bestvalue: %i'], ...
    bestPosition(1),bestPosition(2),bestPosition(3),bestPosition(4), ...
    bestvalue)