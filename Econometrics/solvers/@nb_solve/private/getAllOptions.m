function opt = getAllOptions(obj)
% Syntax:
%
% opt = getAllOptions(obj)
%
% Description:
%
% Check properties before solving.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    opt               = obj.options;
    opt.F             = obj.F;
    opt.JF            = obj.JF;
    opt.initialXValue = obj.initialXValue;
    opt.timer         = tic;
    switch lower(obj.display)
        case 'iter'
            opt.display = 3;
        case 'final'
            opt.display = 2;
        case 'notify'
            opt.display = 1;
        otherwise % 'off'
            opt.display = 0;
    end
    switch lower(obj.criteria)
        case 'function'
            opt.criteria = 1;
        case 'stepsize'
            opt.criteria = 2;
        otherwise % 'off'
            opt.display = 1;
    end
    if any(strcmpi(opt.method,{'sane','dfsane'}))
        switch lower(obj.alphaMethod)
            case 1
                opt.alphaMethod = @(s,y)nb_solve.alphaMethod1(s,y);
            case 3
                opt.alphaMethod = @(s,y)nb_solve.alphaMethod3(s,y);
            otherwise 
                opt.alphaMethod = @(s,y)nb_solve.alphaMethod2(s,y);
        end
    end
    
end
