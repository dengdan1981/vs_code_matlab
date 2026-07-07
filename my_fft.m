function X = my_fft(x)
% MY_FFT - 自定义快速傅里叶变换实现（Cooley-Tukey 基-2 算法）
%
% 用法:
%   X = my_fft(x)  返回向量 x 的离散傅里叶变换 (DFT)
%
% 输入:
%   x - 输入信号向量（长度必须是 2 的幂）
%
% 输出:
%   X - 频域复数结果，与 MATLAB 内置 fft() 结果一致
%
% 算法: Cooley-Tukey 基-2 DIT（时域抽取）FFT
%       递归地将 N 点 DFT 分解为两个 N/2 点 DFT
%
% 注意: 函数名为 my_fft 以避免与 MATLAB 内置 fft() 冲突
%       （MATLAB 对 fft 有特殊优化，自定义同名函数无法被调用）

    N = length(x);

    % 检查输入长度是否为 2 的幂
    if N <= 1
        X = x;
        return;
    end

    % 检查长度是否为 2 的幂，如果不是则补零
    if bitand(N, N-1) ~= 0
        % 找到下一个 2 的幂
        N2 = 2^nextpow2(N);
        x_padded = [x(:); zeros(N2 - N, 1)];
        X = fft_core(x_padded);
        return;
    end

    X = fft_core(x(:));
end

function X = fft_core(x)
% FFT_CORE - 核心递归 Cooley-Tukey FFT 算法

    N = length(x);

    % 递归终止条件
    if N <= 1
        X = x;
        return;
    end

    % 奇偶分拆（时域抽取）
    x_even = x(1:2:end);   % 偶数索引 (MATLAB 从 1 开始)
    x_odd  = x(2:2:end);   % 奇数索引

    % 递归计算 N/2 点 DFT
    X_even = fft_core(x_even);
    X_odd  = fft_core(x_odd);

    % 旋转因子 W_N^k = exp(-2*pi*i*k/N)
    k = (0:N/2-1)';
    W = exp(-2i * pi * k / N);

    % 蝶形运算
    X_top    = X_even + W .* X_odd;
    X_bottom = X_even - W .* X_odd;

    % 合并结果
    X = [X_top; X_bottom];
end
