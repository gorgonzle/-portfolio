clc; close all; clear;

% 전체 파티클 데이터를 저장할 배열 초기화
particles = zeros(200, 4, 20);

% 파일에서 데이터 불러오기
for i = 1:20
    filename = sprintf('position%d.txt', i);  % 파일 이름 생성
    particles(:,:,i) = readmatrix(filename);  % 각 파일에서 데이터 읽기
end

% 가시화할 차원 선택 (예: x축과 z축 선택)
dim_select = [3, 4]; % 1차원과 3차원 데이터 사용

% 상한하한 설정
lb = [-40, 1, -1.5, 0];
ub = [0, 5.5, -0.1, 70000];

% 에니메이션 생성
figure;
hold on;
axis manual;  % 축 범위를 고정
axis([lb(dim_select(1)) ub(dim_select(1)) lb(dim_select(2)) ub(dim_select(2))]);  % 선택된 차원에 맞는 축 범위 설정

for t = 1:19  % 마지막 에포크는 다음 위치가 없으므로 t < 20
    % 현재 위치를 산점도로 표시
    s = scatter(particles(:,dim_select(1),t), particles(:,dim_select(2),t), 12, 'filled', 'blue');
    title(sprintf('Epoch %d', t));  % 현재 epoch 번호 표시
    pause(2);  % 현재 위치를 1초 동안 유지

    delete(s);  % 산점도 삭제
end
s = scatter(particles(:,dim_select(1),20), particles(:,dim_select(2),20), 12, 'filled', 'blue');
title(sprintf('Epoch %d', 20));  % 마지막 epoch 번호 표시
pause(2);  % 현재 위치를 1초 동안 유지

hold off;
