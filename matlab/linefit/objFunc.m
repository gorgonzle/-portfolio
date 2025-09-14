function [loss_out,interp_out] = objFunc(inputparticles,data,path,opt)

f1 = call_iter('iterjournal1.wbjn');
f2 = call_iter('iterjournal2.wbjn');
f3 = call_iter('iterjournal3.wbjn');


[n,p]=size(inputparticles);

outputparticles = denormalize(inputparticles,opt);

journal = f1;

f = f2;
for j= 1:p
    constant = sprintf('C_%i',j);
    f = strrep(f,constant , num2str(outputparticles(1,j)));
end
journal = strcat(journal,f);

a=f3;
f='';
for i= 2:n
    t= a;
    for j= 1:p
        constant = sprintf('C_%i',j);
        t = strrep(t,constant , num2str(outputparticles(i,j)));
    end
    owt = sprintf('out%i',i);
    t = strrep(t, 'owt' ,owt);
    f = strcat(f,t);
end
journal = strcat(journal,f);

fid  = fopen('finaljournal.wbjn','w','n','UTF-8');
fprintf(fid,'%s',journal);
fclose(fid);

% 'out' 폴더 내의 모든 파일 삭제
delete(fullfile('out', '*'));

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

%파일 목록에서 파일만 세기 (폴더 제외)
nf = sum(~[files.isdir]);


% 파일 존재 여부 확인
if nf >= 1
    loss_out = zeros(nf, 1);  % 각 파일의 손실을 저장
    interp_store = cell(nf, 1);  % 각 파일의 보간 데이터를 저장

    for i = 1:nf
        csvname = sprintf('out%d.csv', i);
        % 데이터 로드
        last_data = readmatrix(csvname, 'Range', 'N8:GW8');
        last_data = -last_data;
        x = {data.sim_x};
        y = {data.exp_x};
        z = {data.exp_y};
        % 데이터 길이 확인
        if length(last_data) ~= length(x{1}) + length(x{2}) + length(x{3})
            loss_out(i) = inf;  % 데이터 길이가 일치하지 않으면 해당 인덱스에 무한대 저장
            continue;
        end

        part_length = floor(length(last_data) / 3);
        out = cell(1, numel({data.exp_x}));  % 분할 데이터 저장
        interp_data = cell(1, numel({data.exp_x}));  % 보간 결과 저장
        total_loss = 0;  % 전체 손실 초기화

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
            total_loss = total_loss + loss;
        end

        loss_out(i) = total_loss;
        interp_store{i} = interp_data;  % 보간 데이터 저장
    end

    % 최소 손실에 해당하는 보간 데이터 선택
    [~, index] = min(loss_out);
    interp_out = interp_store{index};
else
    loss_out = [];
    interp_out = [];
end
%---------------------------------------------------------call iter journal
function f = call_iter(filename)
fid = fopen(filename,'r','n','UTF-8');
f = fread(fid,'*char')';
fclose(fid);
f = f(2:end);
%---------------------------------------------------------------denormalize
function inputpart = denormalize(inputpart, opt)
    a = opt.log10comp;
    for idx = 1:length(a) % a의 모든 요소에 대하여 반복
        for i = 1:size(inputpart, 1) % inputpart의 모든 행에 대하여 반복
            inputpart(i, a(idx)) = 10^inputpart(i, a(idx));
        end
    end
