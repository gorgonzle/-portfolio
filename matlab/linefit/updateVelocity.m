function v = updateVelocity(v, x, pBest, gBest, iter,opt)
maxEpoch = opt.maxEpoch;
range_w=[0.4 1.2];
range_c_1=[1.5 2.5];
range_C_2=[1.5 2.5];

w = range_w(1)+(range_w(2)-range_w(1))/maxEpoch*(iter-1); % 관성 가중치
c1 = range_c_1(1)+(range_c_1(2)-range_c_1(1))/maxEpoch*(iter-1); % 개인 학습 계수
c2 = range_C_2(1)+(range_C_2(2)-range_C_2(1))/maxEpoch*(iter-1); % 사회적 학습 계수

r1 = rand();
r2 = rand();

v = w * v + c1 * r1 * (pBest - x) + c2 * r2 * (gBest - x);
end
