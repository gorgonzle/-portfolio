# Portfolio Codes (MATLAB / Python / Fortran)

석사 과정 중 수행한 해석 자동화 및 다물리 연계 연구 과정에서 작성한 코드들을 모아둔 포트폴리오입니다.  
MATLAB, Python, Fortran을 활용하여 **열·유동 해석, 구조 해석, 크리프 물성 피팅, 확률론적 손상 모델링** 등을 구현했습니다.

---

##  Features

- **matlab/**
  - `linefit_v2/`: 크리프 물성치를 문헌 실험자료에 기반해 fitting하기 위한 코드  
    - Huang et al. (2023, *Energy Reports*) 논문에서 제안한 방식에 따라, 문헌과 동일한 조건의 Ansys Workbench case를 제작  
    - 자동화 스크립트를 통해 크리프 변수를 변화시키며 해석 수행  
    - 해석값을 문헌 그래프와 비교하여 error 계산  
    - **PSO(Particle Swarm Optimization)** 알고리즘을 적용하여 fitting 수행  
    - 방식: 상수 particle들을 모두 해석 → error 계산 → PSO로 새로운 위치 업데이트 → 반복  

- **fortran/**
  - Zhang et al. (2018) 논문에서 제안된 creep-damage Weibull 모델을 기반으로 구현한 코드  
  - Ansys/ABAQUS Subroutine 형식으로 작성되어, 사용자 정의 creep 거동을 반영  
  - Time-dependent failure probability 예측을 위한 확률론적 creep-damage 모델 구현
 
- **python/**
  - `src/`: 대용량 해석 결과 파일(.mat, .csv 등) 자동 추출 및 재가공  
  - `gui/`: 실제 연구실에 배포한 GUI 프로그램

