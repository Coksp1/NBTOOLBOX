function dout = nb_undiff(DX,initialValues,periods)   
% Syntax:
%
% dout = nb_undiff(DX,initialValues,periods) 
%
% Description:
%
% Inverse of the diff function
% 
% Input:
% 
% - DX            : A double with the differenced data
%
% - initialValues : A scalar or a double with the initial 
%                   values of the indicies. Must be of the same 
%                   size as the number of variables of the 
%                   DX input. And size(initialValues,1) == periods
%
% - periods       : The number of periods the initial series
%                   has been taken diff over.
% 
% Output:
% 
% - dout          : A double
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        periods = 1;
    end

    [dim1,dim2,dim3] = size(DX);
    if size(initialValues,3) == 1
        initialValues = initialValues(1:periods,:,ones(1,dim3));
    end
    
    dout                = nan(dim1,dim2,dim3);
    dout(1:periods,:,:) = initialValues;
    for ii = 1:periods

        d0       = initialValues(ii,:,:);
        douttemp = cumsum(DX(ii+periods:periods:end,:,:),1);
        T        = size(douttemp,1);
        dout(ii+periods:periods:end,:,:) = douttemp + d0(ones(1,T),:,:);

    end
    
end
