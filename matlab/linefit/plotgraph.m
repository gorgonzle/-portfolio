function plotgraph(epoch,globalBestValue,exp_h,exp_deform,interp_data,position)
    % 그래프 생성 (표시되지 않음)
    f = figure('visible', 'off'); % 표시되지 않는 그래픽 창 생성
    hold on; % 여러 그래프를 하나의 창에 표시
    plot(exp_h, exp_deform, 'b-', 'DisplayName', 'CP test'); % 그래프 1
    plot(exp_h, interp_data, 'r--', 'DisplayName', 'Simulation'); % 그래프 2
    hold off;
    
    % 그래프 제목, 축 레이블, 범례 설정
    title(sprintf('[%1.3f,%1.3f,%1.3f,%1.3f]', ...
        position(1),position(2),position(3),position(4)));
    xlabel('Time (h)'); % x축 레이블
    ylabel('Deformation (mm)'); % y축 레이블
    legend('show'); % 범례 표시
    
    grid on;
    
    % 파일 이름 생성 (슬래시 사용)
    fileName = sprintf('result/epoch_%d__loss_%5.3f.fig', ...
        epoch, globalBestValue);
    % PNG 형식으로 저장
    saveas(f, fileName);
    close(f); % 그림 객체 닫기
    
    data_length = length(exp_h);
    [~, numCols] = size(position);
    position_long = zeros(1,data_length);

    position_long(:, 1:numCols) = position;

    position_long(:, numCols+1:data_length) = 0;

    data = [exp_h; exp_deform; interp_data; position_long];
    fileName = sprintf('data/epoch_%d.csv', epoch);
    writematrix(data, fileName);
end