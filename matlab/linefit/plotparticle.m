clc;close all;clear

% 전체 파티클 데이터를 저장할 배열 초기화
particles = zeros(200, 4, 4);

% 파일에서 데이터 불러오기
for i = 1:4
    filename = sprintf('position%d.txt', i);  % 파일 이름 생성
    particles(:,:,i) = readmatrix(filename);  % 각 파일에서 데이터 읽기
end

% 에니메이션 생성
figure;
hold on;
axis manual;  % 축 범위를 고정
axis([-1.5 -0.1 0 70000]);  % X축과 Y축의 범위 설정 (적절하게 조절 필요)

for t = 1:3  % 마지막 에포크는 다음 위치가 없으므로 t < 20
    % 현재 위치를 산점도로 표시
    s = scatter(particles(:,3,t), particles(:,4,t), 12, 'filled', 'blue');
    title(sprintf('Epoch %d', t));  % 현재 epoch 번호 표시
    pause(5);  % 현재 위치를 0.5초 동안 유지


    delete(s);  % 산점도 삭제
end
s = scatter(particles(:,3,t+1), particles(:,4,t+1), 12, 'filled', 'blue');
    title(sprintf('Epoch %d', t+1));  % 현재 epoch 번호 표시
    pause(2);  % 현재 위치를 0.5초 동안 유지

hold off;