function factors = pca_func(varargin)
% Syntax:
%
% factors = pca_func(varargin)
%
% Description:
%
% Principal Component of selected number of series represented by a
% set of nb_math_ts.
% 
% Optional input:
% 
% - varargin      : Optional number of nb_math_ts objects.
%
% - 'numFactors'  : Determine number of Factors to report. Standard is 
%                   first factor only.
%
% - 'unbalanced'  : true or false.
%
% - 'whichFactor' : Select the factor to return.
%              
% Output:
% 
% - factors : The principal component(s) as a nb_math_ts object.
% 
% See also:
% nb_math_ts.pca
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen


    [numFactors,varargin] = nb_parseOneOptional('numFactors',1,varargin{:});
    [unbalanced,varargin] = nb_parseOneOptional('unbalanced',true,varargin{:});
    [whichFactor,d]       = nb_parseOneOptional('whichFactor',[],varargin{:});
    data                  = horzcat(d{:});
    factors               = pca(data,numFactors,'svd','unbalanced',unbalanced);
    if ~isempty(whichFactor)
        factors = factors(:,whichFactor);
    end
    
end

