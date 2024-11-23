function dout = nb_cumgrowth(din,stripNaN)
% Syntax:
%
% dout = nb_cumgrowth(din)
% dout = nb_cumgrowth(din,stripNaN)
%
% Description:
%
% Calculate cumulative approx growth, using the formula: 
% log(x(t))-log(x(0))
%
% See also:
% growth, nb_icumgrowth
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        stripNaN = 0;
    end
    
    isNaN = isnan(din);
    if stripNaN
        dout    = din;
        [r,c,p] = size(din); 
        for cc = 1:c
            for pp = 1:p
                dinT    = din(~isNaN(:,cc,pp),cc,pp);
                d0      = dinT(ones(1,size(dinT,1)-1));
                doutT   = cat(1,nan(1,1,1),log(dinT(2:end)) - log(d0));
                dout(~isNaN(:,cc,pp),cc,pp) = doutT;
            end
        end
        
        % Fill in for NaN values
        isNotNaN = ~isnan(dout);
        for pp = 1:p
            for cc = 1:c 
                loc = [find(isNotNaN(:,cc,pp));r+1];
                for ii = 2:length(loc)
                    dout(loc(ii-1)+1:loc(ii)-1,cc,pp) = dout(loc(ii-1),cc,pp);
                end
            end
        end
        
    else
        [r,c,p] = size(din); 
        d0      = din(1,:,:);
        d0      = d0(ones(1,r-1),:,:);
        dout    = cat(1,nan(1,c,p),log(din(2:end,:,:)) - log(d0));
        
        % Set all observations that has come across a nan on its way to
        % nan
        isNaNC         = cumsum(isNaN,1);
        dout(isNaNC>0) = nan;
    end
    
end
