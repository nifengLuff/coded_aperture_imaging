function [deducted_spectrum_y, background_y] = SNIP(spectrum_y, FWHM)
    v = log(log(sqrt(spectrum_y + 1) + 1) + 1);
    w = v;
    m = FWHM; % 根据需要设置
    for p = m:-1:1
        for i = (p + 1):(length(v) - p)
            t1 = v(i);
            t2 = (v(i-p) + v(i+p))/2;
            w(i) = min(t1,t2);
        end
        v = w;
    end
    background_y = (exp(exp(v) - 1) - 1) .^ 2 - 1;
    deducted_spectrum_y = spectrum_y - background_y;
end