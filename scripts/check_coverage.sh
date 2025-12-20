#!/bin/bash

# 测试覆盖率监控脚本
# 运行测试并检查覆盖率是否达到指定阈值

# 设置覆盖率阈值
COVERAGE_THRESHOLD=80

# 运行测试并生成覆盖率报告
echo "Running tests with coverage..."
flutter test --coverage

# 检查是否生成了覆盖率文件
if [ ! -f coverage/lcov.info ]; then
  echo "Error: Coverage file not found!"
  exit 1
fi

echo "Generating coverage report..."

# 使用lcov解析覆盖率文件并计算总体覆盖率
# 注意：如果lcov命令不可用，可以使用其他方式解析
if command -v lcov &> /dev/null; then
  # 使用lcov计算总体覆盖率
  TOTAL_COVERAGE=$(lcov --list coverage/lcov.info | grep -A 1 "Total" | tail -1 | awk '{print $2}' | sed 's/%//')
  echo "Total coverage: ${TOTAL_COVERAGE}%"
  
  # 检查覆盖率是否达到阈值
  if (( $(echo "$TOTAL_COVERAGE < $COVERAGE_THRESHOLD" | bc -l) )); then
    echo "Error: Coverage ($TOTAL_COVERAGE%) is below threshold ($COVERAGE_THRESHOLD%)!"
    exit 1
  else
    echo "Success: Coverage ($TOTAL_COVERAGE%) meets or exceeds threshold ($COVERAGE_THRESHOLD%)!"
    exit 0
  fi
else
  echo "Warning: lcov command not found, skipping coverage threshold check."
  echo "Coverage file generated at: coverage/lcov.info"
  echo "You can view the coverage report using: genhtml coverage/lcov.info -o coverage/html"
  exit 0
fi
