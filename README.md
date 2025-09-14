# Portfolio Codes (MATLAB / Python / Fortran)

이 저장소는 석사 과정 중 작성한 다양한 시뮬레이션 및 해석 자동화 코드들을 모아둔 포트폴리오입니다.  
MATLAB, Python, Fortran을 활용하여 열·유동 해석, 구조 해석, 최적화 및 자동화 작업을 수행한 예시를 포함하고 있습니다.

---

## 📂 Repository Structure

- **matlab/**
  - `linefit_v2/`: 유량 분포(line fitting) 분석 코드  
    - 0D 등가 회로 기반 셀별 유량 예측  
    - 매니폴드 설계 변수(h, b 등) 스윕 및 결과 피팅  
    - 3D CFD 결과와의 MSE 기반 fitting 검증
  - `examples/`: 실행 예제 (샘플 입력/출력 포함)

- **python/**
  - `src/`: 대용량 해석 결과 파일(.mat, .csv 등) 자동 추출/재가공 스크립트  
  - `gui/`: 연구실 내 배포한 간단 GUI 툴  
  - `notebooks/`: Jupyter 데모 (실행 예시, 시각화)

- **fortran/**
  - Ansys Workbench Subroutine 수정 코드  
  - 사용자 정의 구조 해석 모델 및 FSI(Fluid-Structure Interaction) 연계

- **docs/**
  - `figs/`: 실행 결과 스크린샷 및 그래프 예시  
  - `usage.md`: 상세 사용 가이드 (추가 예정)

---

## 🚀 Features

- **MATLAB**
  - UDF 결과 기반 열·유동 해석
  - 해석 데이터를 구조 해석 툴로 전달하여 FSI 해석 수행
  - PSO(Particle Swarm Optimization)와 연계한 자동 최적화

- **Python**
  - 해석 결과 파일 대량 처리 자동화
  - GUI 형태로 변환하여 사용자 친화적 배포
  - 데이터 시각화 및 보고서용 그래프 생성

- **Fortran**
  - Ansys Subroutine 수정으로 사용자 정의 구조 해석 경험
  - 극한 조건에서 구조 안정성/수명 예측

---

## 🔧 Requirements

- **MATLAB**: R2023a 이상, Optimization Toolbox 권장  
- **Python**: 3.9+  
  ```bash
  pip install -r requirements.txt
