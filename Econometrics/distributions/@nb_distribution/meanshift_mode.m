function x = meanshift_mode(dist,param,lb,ub,ms)
% Syntax:
%
% x = nb_distribution.meanshift_mode(dist,param,lb,ub,ms)
%
% Description:
%
% Mode of the mean shifted and possibly truncated distribution. 
%
% Input:
% 
% - dist  : The name of the underlying distribution as a string. Must be 
%           supported by the nb_distribution class.
%
% - param : A cell with the parameters of the selected distribution.
% 
% - lb    : Lower bound of the truncated distribution.
%
% - ub    : Upper bound of the truncated distribution.
%
% - ms    : Mean shift parameter.
%
% Output:
% 
% - x : The mode of the mean shifted and possibly truncated distribution. 
%
% See also:
% nb_distribution.meanshift_median, nb_distribution.meanshift_mean, 
% nb_distribution.meanshift_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    lb = lb - ms;
    ub = ub - ms;
    if strcmpi(dist,'beta') % Could be bimodal

        x       = nb_distribution.beta_mode(param{:});
        funcPDF = str2func(['nb_distribution.' dist '_pdf']);
        if ~isempty(lb) && ~isempty(ub)  
            plb = funcPDF(lb,param{:});
            pub = funcPDF(ub,param{:});
            if lb >= x
                if plb > pub
                    x = lb;
                else
                    x = ub;
                end
            elseif ub < x
                if plb > pub
                    x = lb;
                else
                    x = ub;
                end   
            end
        elseif ~isempty(ub)
            plb = funcPDF(0,param{:});
            pub = funcPDF(ub,param{:});
            if ub < x
                if plb > pub
                    x = lb;
                else
                    x = ub;
                end
            end
        else
            plb = funcPDF(lb,param{:});
            pub = funcPDF(1,param{:});
            if lb > x
                if plb > pub
                    x = lb;
                else
                    x = ub;
                end
            end
        end
        x = x + ms;

    else % Unimodal distributions

        func = str2func(['nb_distribution.' dist '_mode']);
        xT   = func(param{:});
        if ~isempty(lb)
            if lb > xT
                xT = lb;
            end
        end

        if ~isempty(ub)
            if ub < xT
                xT = ub;
            end
        end
        x = xT + ms;

    end

end
