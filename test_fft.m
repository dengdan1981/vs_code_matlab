% TEST_FFT - 测试自定义 FFT 实现 (my_fft in fft.m)
%
% 测试内容:
%   1. 简单正弦波 (N=8)
%   2. 多频率分量 (N=16)
%   3. 直流信号 (N=32)
%   4. 单位脉冲 (N=64)
%   5. 非 2 的幂补零 (N=10→16)
%   6. 较大数据量 (N=1024)
%   7. Parseval 定理
%   8. 线性性质
%   9. 共轭对称性
%  10. 边界情况 (N=1, N=2, 全零)

clc;
fprintf('========================================\n');
fprintf('   自定义 FFT 实现测试 (my_fft)\n');
fprintf('========================================\n\n');

all_pass = true;

% 直接 DFT 计算函数 (用于交叉验证)
dft_direct = @(x) exp(-2i*pi*(0:length(x)-1)'*(0:length(x)-1)/length(x)) * x(:);

% --------------------------------------------------
% 测试 1: 简单正弦波 (N=8)
% --------------------------------------------------
fprintf('测试 1: 简单正弦波 (N=8)\n');
fprintf('  输入: sin(2*pi*(0:7)/8)\n');
N = 8;
t = (0:N-1)';
x1 = sin(2*pi*t/N);
X1_my = my_fft(x1);
X1_m  = fft(x1);      % MATLAB 内置
X1_d  = dft_direct(x1); % DFT 定义
err_my_vs_dft = max(abs(X1_my(:) - X1_d(:)));
err_m_vs_dft  = max(abs(X1_m(:) - X1_d(:)));
fprintf('  my_fft vs DFT 定义:  %.2e\n', err_my_vs_dft);
fprintf('  MATLAB fft vs DFT:   %.2e\n', err_m_vs_dft);
% 检查频率分量: sin → 在 k=1 和 k=7 处有峰值
fprintf('  频域峰值: k=%d (%.1f), k=%d (%.1f)\n', ...
    2, abs(X1_my(2)), N, abs(X1_my(N)));
if err_my_vs_dft < 1e-12
    fprintf('  结果: ✓ 通过\n\n');
else
    fprintf('  结果: ✗ 失败\n\n');
    all_pass = false;
end

% --------------------------------------------------
% 测试 2: 两个频率分量 (N=16)
% --------------------------------------------------
fprintf('测试 2: 两个频率分量 (N=16)\n');
fprintf('  输入: sin(2*pi*2*(0:15)/16) + 0.5*cos(2*pi*4*(0:15)/16)\n');
N = 16;
n = (0:N-1)';
x2 = sin(2*pi*2*n/N) + 0.5*cos(2*pi*4*n/N);
X2_my = my_fft(x2);
X2_m  = fft(x2);
err2 = max(abs(X2_my(:) - X2_m(:)));
fprintf('  my_fft vs MATLAB fft: %.2e\n', err2);
if err2 < 1e-12
    fprintf('  结果: ✓ 通过\n\n');
else
    fprintf('  结果: ✗ 失败\n\n');
    all_pass = false;
end

% --------------------------------------------------
% 测试 3: 直流信号 (N=32)
% --------------------------------------------------
fprintf('测试 3: 直流信号 (N=32)\n');
fprintf('  输入: ones(32,1)\n');
N = 32;
x3 = ones(N, 1);
X3_my = my_fft(x3);
X3_m  = fft(x3);
err3 = max(abs(X3_my(:) - X3_m(:)));
fprintf('  my_fft vs MATLAB fft: %.2e\n', err3);
fprintf('  DC 分量 (k=1): %.1f (期望: %d)\n', X3_my(1), N);
fprintf('  其他分量之和:    %.2e (期望: 0)\n', sum(abs(X3_my(2:end))));
if err3 < 1e-12 && abs(X3_my(1) - N) < 1e-10
    fprintf('  结果: ✓ 通过\n\n');
else
    fprintf('  结果: ✗ 失败\n\n');
    all_pass = false;
end

% --------------------------------------------------
% 测试 4: 单位脉冲信号 (N=64)
% --------------------------------------------------
fprintf('测试 4: 单位脉冲信号 (N=64)\n');
fprintf('  输入: [1; zeros(63,1)]\n');
N = 64;
x4 = zeros(N, 1);
x4(1) = 1;
X4_my = my_fft(x4);
X4_m  = fft(x4);
err4 = max(abs(X4_my(:) - X4_m(:)));
fprintf('  my_fft vs MATLAB fft: %.2e\n', err4);
fprintf('  所有分量幅值: %.6f (期望: 1.0)\n', abs(X4_my(1)));
if err4 < 1e-12
    fprintf('  结果: ✓ 通过\n\n');
else
    fprintf('  结果: ✗ 失败\n\n');
    all_pass = false;
end

% --------------------------------------------------
% 测试 5: 非 2 的幂长度 - 自动补零 (N=10 → 16)
% --------------------------------------------------
fprintf('测试 5: 非 2 的幂长度 (N=10 → 补零到 16)\n');
fprintf('  输入: 长度为 10 的随机信号\n');
rng(42);
x5 = randn(10, 1);
X5_my = my_fft(x5);
% 手动补零后用 MATLAB fft 验证
x5_padded = [x5; zeros(6, 1)];
X5_m_padded = fft(x5_padded);
err5 = max(abs(X5_my(:) - X5_m_padded(:)));
fprintf('  my_fft 输出长度: %d (期望: 16)\n', length(X5_my));
fprintf('  my_fft vs MATLAB fft(补零后): %.2e\n', err5);
if err5 < 1e-12 && length(X5_my) == 16
    fprintf('  结果: ✓ 通过\n\n');
else
    fprintf('  结果: ✗ 失败\n\n');
    all_pass = false;
end

% --------------------------------------------------
% 测试 6: 较大数据量 + 性能对比 (N=1024)
% --------------------------------------------------
fprintf('测试 6: 较大数据量 + 性能对比 (N=1024)\n');
fprintf('  输入: 含多频率分量 + 噪声的混合信号\n');
N = 1024;
n = (0:N-1)';
x6 = sin(2*pi*50*n/N) + 0.3*sin(2*pi*120*n/N) + 0.1*randn(N,1);

tic; X6_my = my_fft(x6); t_my = toc;
tic; X6_m  = fft(x6);    t_m  = toc;
err6 = max(abs(X6_my(:) - X6_m(:)));

fprintf('  my_fft vs MATLAB fft: %.2e\n', err6);
fprintf('  my_fft 耗时:     %.4f 秒\n', t_my);
fprintf('  MATLAB fft 耗时: %.4f 秒 (高度优化的 FFTW 库)\n', t_m);
if err6 < 1e-12
    fprintf('  结果: ✓ 通过\n\n');
else
    fprintf('  结果: ✗ 失败\n\n');
    all_pass = false;
end

% --------------------------------------------------
% 测试 7: Parseval 定理验证 (能量守恒)
% --------------------------------------------------
fprintf('测试 7: Parseval 定理验证 (能量守恒)\n');
fprintf('  验证: sum(|x|^2) = (1/N) * sum(|X|^2)\n');
N = 256;
x7 = randn(N, 1) + 1i*randn(N, 1);
X7 = my_fft(x7);
energy_time = sum(abs(x7).^2);
energy_freq = sum(abs(X7).^2) / N;
rel_err = abs(energy_time - energy_freq) / energy_time;
fprintf('  时域能量:    %.8f\n', energy_time);
fprintf('  频域能量/N:  %.8f\n', energy_freq);
fprintf('  相对误差:    %.2e\n', rel_err);
if rel_err < 1e-12
    fprintf('  结果: ✓ 通过\n\n');
else
    fprintf('  结果: ✗ 失败\n\n');
    all_pass = false;
end

% --------------------------------------------------
% 测试 8: 线性性质验证
% --------------------------------------------------
fprintf('测试 8: 线性性质验证\n');
fprintf('  验证: my_fft(a*x + b*y) = a*my_fft(x) + b*my_fft(y)\n');
N = 128;
a = 2.5; b = -1.3;
x8a = randn(N, 1);
x8b = randn(N, 1);
lhs = my_fft(a*x8a + b*x8b);
rhs = a*my_fft(x8a) + b*my_fft(x8b);
err8 = max(abs(lhs(:) - rhs(:)));
fprintf('  最大绝对误差: %.2e\n', err8);
if err8 < 1e-12
    fprintf('  结果: ✓ 通过\n\n');
else
    fprintf('  结果: ✗ 失败\n\n');
    all_pass = false;
end

% --------------------------------------------------
% 测试 9: 共轭对称性 (实信号)
% --------------------------------------------------
fprintf('测试 9: 共轭对称性验证 (实信号)\n');
fprintf('  验证: X(k) = conj(X(N-k+2)) 对实信号成立\n');
N = 64;
x9 = randn(N, 1);
X9 = my_fft(x9);
sym_err = max(abs(X9(2:end) - conj(X9(end:-1:2))));
fprintf('  共轭对称性误差: %.2e\n', sym_err);
if sym_err < 1e-12
    fprintf('  结果: ✓ 通过\n\n');
else
    fprintf('  结果: ✗ 失败\n\n');
    all_pass = false;
end

% --------------------------------------------------
% 测试 10: 边界情况
% --------------------------------------------------
fprintf('测试 10: 边界情况\n');

% 10a: N=1
fprintf('  10a: N=1\n');
x10a = 5;
X10a = my_fft(x10a);
err10a = abs(X10a - 5);
fprintf('      输入: 5, 输出: %.1f, 误差: %.2e\n', real(X10a), err10a);
pass10a = err10a < 1e-12;

% 10b: N=2
fprintf('  10b: N=2\n');
x10b = [1; -1];
X10b = my_fft(x10b);
X10b_m = fft(x10b);
err10b = max(abs(X10b(:) - X10b_m(:)));
fprintf('      my_fft vs MATLAB: %.2e\n', err10b);
pass10b = err10b < 1e-12;

% 10c: 全零信号
fprintf('  10c: 全零信号 (N=16)\n');
x10c = zeros(16, 1);
X10c = my_fft(x10c);
err10c = max(abs(X10c));
fprintf('      输出最大绝对值: %.2e\n', err10c);
pass10c = err10c < 1e-12;

% 10d: 非 2 的幂 (N=7 → 补零到 8)
fprintf('  10d: N=7 (补零到 8)\n');
x10d = (1:7)';
X10d = my_fft(x10d);
x10d_padded = [x10d; 0];
X10d_m = fft(x10d_padded);
err10d = max(abs(X10d(:) - X10d_m(:)));
fprintf('      长度: %d (期望: 8), 误差: %.2e\n', length(X10d), err10d);
pass10d = err10d < 1e-12 && length(X10d) == 8;

if pass10a && pass10b && pass10c && pass10d
    fprintf('  结果: ✓ 全部通过\n\n');
else
    fprintf('  结果: ✗ 存在失败\n\n');
    all_pass = false;
end

% --------------------------------------------------
% 总结
% --------------------------------------------------
fprintf('========================================\n');
if all_pass
    fprintf('  ✓ 全部测试通过!\n');
else
    fprintf('  ✗ 存在测试失败!\n');
end
fprintf('========================================\n');
