# 🔧 Build System Configuration Reference

# Este archivo documenta las configuraciones disponibles para el sistema unificado
# Para modificar configuraciones, edita directamente el archivo build-unified.yml

# Flutter Configuration
flutter_version: "3.27.1"
flutter_channel: "stable"

# Platform Support
android:
  enabled: true
  build_modes: ["release", "debug"]  
  split_per_abi: true
  architectures: ["arm64-v8a", "armeabi-v7a", "x86_64"]

windows:
  enabled: true
  build_mode: "release"
  architecture: "x64"
  include_dependencies: true

web:
  enabled: true
  build_mode: "release"
  renderer: "html"
  base_href: "/"

# Quality Checks
quality_checks:
  run_tests: true
  run_analyzer: true
  code_coverage: true
  dependency_check: true

# Release Settings
release_settings:
  auto_release_on_main: true
  auto_release_on_tag: true
  version_strategy: "automatic"
  version_prefix: "v"
  create_unified_package: true
  cleanup_old_artifacts: true

# Performance
performance:
  cache_enabled: true
  max_parallel_jobs: 3
  timeout_minutes: 60
  memory_limit_gb: 8

# Development
development:
  verbose_logging: false
  debug_artifacts: false
  run_unit_tests: true
  enforce_formatting: true
  min_test_coverage: 70
