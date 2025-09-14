function [bestPosition, bestValue] = customPSO(data,space,path,opt)


%입자 위치 초기화
position = initialize(opt,space);
numDimensions = length(space.lb);
numParticles = space.numpar;
lb = space.lb;
ub = space.ub;

% 입자 정보 초기화
iterValue = inf(numParticles,1);
velocity = zeros(numParticles, numDimensions); % 입자 속도 초기화
personalBestPosition = position; % 개인 최적 위치
personalBestValue = inf(numParticles, 1); % 개인 최적 값
[globalBestValue, idx] = min(personalBestValue);
globalBestPosition = personalBestPosition(idx, :); % 전역 최적 위치
bestparticle = 0;
a = {data.exp_x};
globalbestinterp = zeros(1,length(a{1}));

% 메인 루프
for epoch = 1:opt.maxEpoch
    startpoint = 1;
    while startpoint<=numParticles
        iterbest = inf;
        if startpoint<=(numParticles-(opt.batch-1))
            selectedParticles = position(startpoint:startpoint ...
                +(opt.batch-1), :);
        else
            selectedParticles = position(startpoint:numParticles,:);
        end
        inputparticles = selectedParticles;
        [Value,bestinterp_group] = objFunc(inputparticles,data,path,opt);
        n = length(Value);
        iterValue(startpoint:startpoint+n-1) = Value;
        if startpoint+n-1~=numParticles
            iterValue(startpoint+n) = inf;
        end

        for j = startpoint:startpoint+n
            if j ==numParticles+1
                break
            end
            Update_Iteration(epoch,j,iterValue,position(j,:),numDimensions)
        end


        if Value<iterbest
            iterbestinterp = bestinterp_group;
            iterbest = Value;
        end

        startpoint = startpoint+n+1;
    end


    for i = 1:numParticles
        currentValue = iterValue(i);

        % 개인 최적 값 업데이트
        if currentValue < personalBestValue(i)
            personalBestValue(i) = currentValue;
            personalBestPosition(i, :) = position(i, :);
        end

        % 전역 최적 값 업데이트
        if currentValue < globalBestValue
            globalBestValue = currentValue;
            globalBestPosition = position(i, :);
            bestparticle = i;
        end

    end

    if abs(iterbest-globalBestValue)<1e-3
        globalbestinterp = iterbestinterp;
    end

    % 속도 및 위치 업데이트
    for i = 1:numParticles
        velocity(i, :) = updateVelocity(velocity(i, :), ...
            position(i, :), personalBestPosition(i, :), ...
            globalBestPosition, epoch, opt);
        position(i, :) = position(i, :) + velocity(i, :);
        % 위치가 제한 범위를 넘어가지 않도록 조정
        position(i, :) = max(min(position(i, :), ub), lb);
    end


    % 유효한 입자 인덱스 미리 찾기
    validIndices = find(iterValue ~= inf);


    Update_epoch(epoch,globalBestValue,bestparticle,numParticles, ...
        numDimensions, globalBestPosition,validIndices)

    %custom function
%     plotgraph(epoch, globalBestValue, {data.exp_x}, {data.exp_y}, ...
%         globalbestinterp, globalBestPosition)

    save("save\position.txt","position",'-ascii')
    save("save\personalBestValue.txt","personalBestValue",'-ascii')
    save("save\personalBestPosition.txt","personalBestPosition",'-ascii')
    save("save\globalBestValue.txt","globalBestValue",'-ascii')
    save("save\globalbestPosition.txt","globalBestPosition",'-ascii')
    save("save\velocity.txt","velocity",)

end



bestPosition = globalBestPosition;
bestValue = globalBestValue;
%%---------------------------------------------------------Update Iteration
function Update_Iteration(epoch,j,iterValue,position,numDimensions)
fprintf("epoch: %d, particle: %d, loss: %5.3f [",epoch, j, iterValue(j))

for i=1:numDimensions-1
    fprintf('%1.3f,',position(i))
end

fprintf('%1.3f]\n',position(numDimensions))
%%-------------------------------------------------------------Update epoch
function Update_epoch(epoch,globalBestValue,bestparticle, ...
    numParticles,numDimensions,globalBestPosition,validIndices)
fprintf('epoch: %d Best loss: %5.3f Best Position: %dth particle [', ...
    epoch, globalBestValue,bestparticle)
for i=1:numDimensions-1
    fprintf('%1.3f,',globalBestPosition(i))
end
fprintf('%1.3f]\nconverged: %i/%i\n',globalBestPosition(end),validIndices, ...
    numParticles)
%%-------------------------------------------------------------remove blank
function B= rem_blank(A)
filename = A;
fid =  fopen(filename,'r');
f = fread(fid)