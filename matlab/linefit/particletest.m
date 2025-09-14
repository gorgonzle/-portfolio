clc; clear; close all;

%%------------------------------------------------------------Domain select
[data,space,path,opt,condition] = Ni_YSZ1();
%[data,space,path,opt] = GC_9();

test_position = [-8.539, 2.652, -0.773, 46012.712];

%바꿔야함
f1 = call_iter('iterjournal1_Ni.wbjn');
f2 = call_iter('iterjournal2_Ni.wbjn');


[n,p]=size(test_position);

outputparticles = denormalize(test_position,opt);

journal = f1;

f = f2;
for j= 1:p
    constant = sprintf('C_%i',j);
    f = strrep(f,constant , num2str(outputparticles(1,j)));
end
journal = strcat(journal,f);

fid  = fopen('finaljournal.wbjn','w','n','UTF-8');
fprintf(fid,'%s',journal);
fclose(fid);

% 'out' 폴더 내의 모든 파일 삭제 (수정 필요)
delete(fullfile('out', '*'));
delete(fullfile('case','Ni_YSZ','Ni_YSZ_files','session_files','*'))

%lock파일 삭제
fileName = fullfile(path.casefile,'.lock');

if exist(fileName, 'file') == 2
    delete(fileName);
end

fclose('all');

%Workbench 기동
system([path.ansyspath, ' -B -R ', 'finaljournal.wbjn']);

% 'out' 폴더 내의 모든 파일과 폴더 목록을 가져옴
files = dir(fullfile('out', '*.csv'));

csvname = sprintf('out1.csv');
% 데이터 로드
last_data = readmatrix(csvname, 'Range', 'N8:GW8');
last_data = -last_data;
x = {data.sim_x};
y = {data.exp_x};
z = {data.exp_y};

part_length = floor(length(last_data) / 3);
out = cell(1, numel({data.exp_x}));  % 분할 데이터 저장
interp_data = cell(1, numel({data.exp_x}));  % 보간 결과 저장
personal_loss = inf(3);  % 전체 손실 초기화
IMI = zeros(3);

% 데이터 분할 및 보간
for j = 1:numel({data.exp_x})
    if j == numel({data.exp_x})
        out{j} = last_data((part_length * (j - 1) + 1):end);
    else
        out{j} = last_data((part_length * (j - 1) + 1):(part_length * j));
    end
    interp_data{j} = interp1(x{j}, out{j}, y{j}, 'linear', 'extrap');
    interp_data{j} = interp_data{j} * 10^3;  % 단위 변환

    % 손실 함수 계산
    a = z{j};
    b = interp_data{j};
    c = a-b;
    d = c.^2;
    loss = sum(d./(a.^2))/length(x{j});
    personal_loss(j) = loss;

    %면적 차이 계산
    exparea = calarea(y{j},z{j});
    simarea = calarea(y{j},interp_data{j});
    %IMI(Integral Match Index)
    IMI(j) = 1 - abs(simarea - exparea) / exparea;
end

fprintf('loss1: %0.3f, loss2: %0.3f, loss3: %0.3f\n',personal_loss(1),personal_loss(2),personal_loss(3))
fprintf('IMI1 : %1.2f, IMI2 : %1.2f, IMI3 : %1.2f',IMI(1),IMI(2),IMI(3))

figure(1)
hold on
title('850C, 39')
plot(y{1},z{1},'b',y{1},interp_data{1},'r--')
legend('Experimental', 'Interpolated')
hold off

figure(2)
hold on
title('800C, 58')
plot(y{2},z{2},'b',y{2},interp_data{2},'r--')
legend('Experimental', 'Interpolated')
hold off

figure(3)
hold on
title('800C, 45')
plot(y{3},z{3},'b',y{3},interp_data{3},'r--')
legend('Experimental', 'Interpolated')
hold off


interp_store = interp_data;  % 보간 데이터 저장




%------------------------------------------------------call iter journal
function f = call_iter(filename)
fid = fopen(filename,'r','n','UTF-8');
f = fread(fid,'*char')';
fclose(fid);
f = f(2:end);
end
%------------------------------------------------------------denormalize
function inputpart = denormalize(inputpart, opt)
    a = opt.log10comp;
    for idx = 1:length(a) % a의 모든 요소에 대하여 반복
        for i = 1:size(inputpart, 1) % inputpart의 모든 행에 대하여 반복
            inputpart(i, a(idx)) = 10^inputpart(i, a(idx));
        end
    end
end
%---------------------------------------------------------calculate area
function [area] = calarea(data_x, data_y)
dx = data_x(2:end) - data_x(1:end-1);        % x-좌표의 차이 계산
meany = (data_y(1:end-1) + data_y(2:end)) / 2;  % y-좌표의 평균 계산
area = sum(dx .* meany);                       % 트라페조이드 면적 계산
end