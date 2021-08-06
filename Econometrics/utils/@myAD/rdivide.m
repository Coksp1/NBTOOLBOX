function x = rdivide(x,y)
% Syntax:
%
% x = rdivide(x,y)
%
% Description:
%
% Right division (./).
% 
% Edited by SeHyoun Ahn, Jan 2016
%
% In Package myAD - Automatic Differentiation
% by Martin Fink, June 2006
% martinfink 'at' gmx.at

    if isa(x, 'myAD')
        if isa(y, 'myAD')
            if numel(y.values)==1
                x.derivatives = x.derivatives/y.values - valXder(x.values(:)/y.values^2,y.derivatives);
            elseif numel(x.values)==1
                x.derivatives = valXder(1./y.values(:),x.derivatives) - valXder(x.values./y.values(:).^2,y.derivatives);
            else
                x.derivatives = valXder(1./y.values(:), x.derivatives) - valXder(x.values(:)./y.values(:).^2, y.derivatives);
            end
            x.values = x.values./y.values;
        else
            if max(size(y))==1
                x.derivatives = x.derivatives/y;
            elseif max(size(x.values))==1
                x.derivatives = valXder(1./y(:),x.derivatives);
            else
                x.derivatives = valXder(1./y(:), x.derivatives);
            end
            x.values = x.values./y;
        end
    else
        if max(size(y.values))==1
            y.derivatives = valXder(-x(:)/y.values^2,y.derivatives);
        elseif max(size(x))==1
            y.derivatives = valXder(-x./y.values(:).^2,y.derivatives);
        else
            y.derivatives = valXder(- x(:)./y.values(:).^2, y.derivatives);
        end
        y.values = x./y.values;
        x = y;
    end
    
end
