module.exports = {
  apps: [
    {
      name: 'chexcar_app',
      script: 'dist/main.js',
      instances: 'max', // 최대 CPU 코어 수만큼 인스턴스를 실행
      exec_mode: 'cluster', // 클러스터 모드
      watch: false,
    },
  ],
};
