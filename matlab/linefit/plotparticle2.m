clc; close all; clear;

% 전체 파티클 데이터를 저장할 배열 초기화
particles = zeros(200, 4, 20);

% 파일에서 데이터 불러오기
for i = 1:20
    filename = sprintf('position%d.txt', i);  % 파일 이름 생성
    particles(:,:,i) = readmatrix(filename);  % 각 파일에서 데이터 읽기
end

% 가시화할 차원 선택 (예: x축과 z축 선택)
dim_select = [1, 2]; % 1차원과 3차원 데이터 사용

% 상한하한 설정
lb = [-40, 1, -1.5, 0];
ub = [0, 5.5, -0.1, 70000];

% 그래프 설정
figure;
hold on;
axis manual;
axis([lb(dim_select(1)) ub(dim_select(1)) lb(dim_select(2)) ub(dim_select(2))]);  % 선택된 차원에 맞는 축 범위 설정

colors = jet(20);  % 무지개색으로 20개의 색상 생성

for t = 1:20
    % 각 epoch에 대한 위치를 산점도로 표시하되 각각 다른 색으로 표시
    scatter(particles(:,dim_select(1),t), particles(:,dim_select(2),t), 12, 'filled', 'MarkerFaceColor', colors(t,:));
    title(sprintf('All Epochs Visualized'));  % 제목 설정
end

hold off;