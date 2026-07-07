function X = fft(x)
% FFT - 自定义 FFT 的便捷包装函数
%
% 注意: 由于 MATLAB 对内置 fft() 有特殊的 JIT/内联优化，
%       同名自定义函数无法在脚本中被调用（MATLAB 始终会调用内置版本）。
%       因此核心实现位于 my_fft.m，此文件仅作为包装。
%
% 用法:
%   X = fft(x)  → 内部调用 my_fft(x)
%
% 如果要直接测试，建议使用:  X = my_fft(x)

    X = my_fft(x);
end
