# vs_code_matlab

自定义 MATLAB 快速傅里叶变换 (FFT) 实现。

## 文件说明

| 文件 | 描述 |
|------|------|
| `my_fft.m` | 核心 Cooley-Tukey 基-2 DIT FFT 实现 |
| `test_fft.m` | 完整测试脚本（10 项测试） |
| `version.txt` | 版本号文件（每次提交自动递增） |

## 算法

- **算法**: Cooley-Tukey 基-2 DIT（时域抽取）FFT
- **特性**: 递归分治，蝶形运算，旋转因子优化
- **支持**: 自动补零至 2 的幂长度

## 运行测试

```bash
matlab -sd . -batch "test_fft" -nodesktop -nosplash
```

## 测试覆盖

1. 正弦波信号 (N=8)
2. 多频率分量 (N=16)
3. 直流信号 (N=32)
4. 单位脉冲 (N=64)
5. 非 2 的幂补零 (N=10→16)
6. 大信号性能对比 (N=1024)
7. Parseval 能量守恒
8. 线性性质
9. 共轭对称性
10. 边界情况 (N=1, N=2, 全零)

## 注意事项

函数名为 `my_fft` 而非 `fft`，因为 MATLAB 对内置 `fft()` 有特殊优化——即使当前目录有同名 `fft.m`，MATLAB 仍会调用内置版本。
