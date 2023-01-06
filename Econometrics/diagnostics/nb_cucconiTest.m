function [CT,pValue] = nb_cucconiTest(x,y)
% Syntax:
%
% [CT,pValue] = nb_cucconiTest(x,y)
%
% Description:
%
% Implements the Cucconi test for equal location and scale of two random
% samples coming from two different distributions. The H0 is that the
% distributions are equal. So a p-value < alpha means that you can reject
% that the distributions are equal.
% 
% Input:
% 
% - x      : A n x 1 double. n > 6.
%
% - y      : A m x 1 double. m > 6.
% 
% Output:
% 
% - CT     : The Cucconi test statistics.
%
% - pValue : The p-value of the test.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x = x(:);
    y = y(:);
    if size(x,1) < 6
        error('x must have at least 6 elements.')
    end
    if size(y,1) < 6
        error('y must have at least 6 elements.')
    end

    % Calculate test statistics
    CT = testStat(x,y);
    
    % Get p-value
    pValue = exp(-CT);

end

function CT = testStat(x,y)

    m     = size(x,1);
    n     = size(y,1);
    N     = m + n;
    [~,S] = sort([x;y]);
    S     = S(m+1:N);
    denom = sqrt(m * n * (N + 1) * (2 * N + 1) * (8 * N + 11) / 5);
    U     = (6 * sum(S.^2) - n * (N + 1) * (2 * N + 1)) / denom;
    V     = (6 * sum((N + 1 - S).^2) - n * (N + 1) * (2 * N + 1)) / denom;
    rho   = (2 * (N^2 - 4)) / ((2 * N + 1) * (8 * N + 11)) - 1;
    CT    = (U^2 + V^2 - 2 * rho * U * V) / (2 * (1 - rho^2));

end

% function bootvals = cucconiDistBoot(x, y)
% 
%     xs       = (x - mean(x))/std(x);
%     ys       = (y - mean(y))/std(y);
%     reps     = 1000;
%     m        = length(x);
%     n        = length(y);
%     bootvals = nan(reps,1);
%     for ii = 1:reps
%         xboot        = xs(randi(m,m,1));
%         yboot        = ys(randi(n,n,1));
%         bootvals(ii) = testStat(xboot,yboot);
%     end
%     bootvals = sort(bootvals);
% 
% end




