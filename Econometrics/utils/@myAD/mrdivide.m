function x = mrdivide(x,y)
% Syntax:
%
% y = mldivide(x,y)
%
% Description:
%
% Matrix right division (/).
% 
% Written by SeHyoun Ahn, Jan 2016

    if max(size(y))==1
        x = rdivide(x,y);
    elseif size(x,2)==size(y,2)
        x = ctranspose(mldivide(ctranspose(y),ctranspose(x)));
    else
        error('Check that the dimensions match');
    end
    
end
