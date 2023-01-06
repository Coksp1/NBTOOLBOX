function factors = pca_func(varargin)
% Syntax:
%
% factors = pca_func(varargin)
%
% Description:
%
% Principal Component of selected number of series represented by a
% set of nb_objectInExpr.
% 
% Optional input:
% 
% - varargin      : Optional number of nb_objectInExpr objects.
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
% - factors : An object of class nb_objectInExpr.
% 
% See also:
% nb_objectInExpr.pca
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    [~,varargin] = nb_parseOneOptional('numFactors',1,varargin{:});
    [~,varargin] = nb_parseOneOptional('unbalanced',true,varargin{:});
    [~,d]        = nb_parseOneOptional('whichFactor',[],varargin{:});
    factors      = horzcat(d{:});
    
end

