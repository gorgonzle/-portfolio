%---------------------------- PSO fitting --------------------------------%
% Writer: Minsang Kim                                                     %
%Date 2024-06-17                                                          %
%-------------------------------------------------------------------------%
function [x] = Ni_YSZ(Demand)
    switch(Demand)
        case('modeset') x = modeselect();
        case('data');   x = expdata();
        case('space');  x = solutionspace();
        case('Path');   x = filepath();
    end
function modeselect
    numDimension = 200;
    Pmode = 'custom'
    x = ;
%--------------------------------------------------------------get exp data
function [x] = expdata()
    % eteration setup(Ni-YSZ)
    time_s = [1 2 3.5 5 7204.9 14405 21605 28805 36005 43204 50404 57604 ...
        64804 72004 79204 86404 93604 1.008e+005 1.08e+005 1.152e+005 ...
        1.224e+005 1.296e+005 1.368e+005 1.44e+005 1.512e+005 1.584e+005 ...
        1.656e+005 1.728e+005 1.8e+005 1.872e+005 1.944e+005 2.016e+005 ...
        2.088e+005 2.16e+005 2.232e+005 2.304e+005 2.376e+005 2.448e+005 ...
        2.52e+005 2.592e+005 2.664e+005 2.736e+005 2.808e+005 2.88e+005 ...
        2.952e+005 3.024e+005 3.096e+005 3.168e+005 3.24e+005 3.312e+005 ...
        3.384e+005 3.456e+005 3.528e+005 3.6e+005];
    
    exp_h = readmatrix("creeepexp.csv", 'Range', 'A2:A39').';
    
    exp_deform = readmatrix("creeepexp.csv", 'Range', 'B2:B39').';
    
    time_h = time_s/3600;

    x = {exp_h, exp_deform, time_h}
%------------------------------------------------------------Solution space
function [x] = solutionspace()
    %Ni-YSZ
    lb = [1.0e-22, 1.2, -1.2, 14801];
    % range mode: 하한, nomalize mode: 평균
    ub = [1.0e-13, 2.2, -0.2, 14801];
    % range mode: 상한, nomalize mode: 표준편차
    x = {lb,ub,numparticle};
%-----------------------------------------------------------------file path
function [x] = filepath()
    ansysPath = ['"C:\Program Files\ANSYS Inc\v231\Framework\bin\Win64' ...
    '\RunWB2.exe"'];
    workspace = "C:\linefiiting_nonpallel";
    iterjournal = 
    resultfile = 
    x = {ansysPath, workspace, iterjournal, resultfile};
%
function 
