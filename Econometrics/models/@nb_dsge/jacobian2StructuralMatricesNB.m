function [Alead,A0,Alag,B] = jacobian2StructuralMatricesNB(jacobian,parser)
% Syntax:
%
% [Alead,A0,Alag,B] = nb_dsge.jacobian2StructuralMatricesNB(jacobian,...
%                           parser)
%
% Description:
% 
% Derive the structural matrices given the jacobian.
%
% On the form: Alead*y(t+1) + A0*y + Alag*y(t-1) + B*epsilon = 0
% 
% Input:
% 
% - jacobian : A matrix with the jacobian of the DSGE model.
%
% - parser   : A struct with fields:
%   
%   > leadCurrentLag : A nEndo x 3 double with the lead, current and lag
%                      indicies of the endogenous variables of the model.
%   > block          : A struct. See nb_dsge.blockDecompose
% 
% Output:
%
% - Alead : The structural matrix of the endogenous 
%           variables in the period t+1.
% 
% - A0    : The structural matrix of the endogenous 
%           variables in the period t.
% 
% - Alag  : The structural matrix of the endogenous 
%           variables in the period t-1.
% 
% - B     : The structural matrix of the exogenous 
%           variables in period t.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    leadCurrentLag = parser.leadCurrentLag;
    nForward       = sum(leadCurrentLag(:,1));
    nBackward      = sum(leadCurrentLag(:,3));
    nEndo          = size(leadCurrentLag,1);
    nEq            = size(jacobian,1);
    startExo       = nForward + nEndo + nBackward + 1;
    Alead          = zeros(nEq,nEndo);
    Alag           = Alead;
    
    Alead(:,leadCurrentLag(:,1)) = jacobian(:,1:nForward);
    A0(:,:)                      = jacobian(:,nForward+1:nForward+nEndo);
    Alag(:,leadCurrentLag(:,3))  = jacobian(:,nForward+nEndo+1:nForward+nEndo+nBackward);
    if nargout > 3
        B = jacobian(:,startExo:end);
    end
    
    if isfield(parser,'block')
        if ~nb_isempty(parser.block)
            % Get the structural matrices without the epilogue
            [Alead,A0,Alag] = getNewStructuralMatrices(parser.block.epiEqs,parser.block.epiEndo,Alead,A0,Alag);
            if nargout > 3
                B = B(~parser.block.epiEqs,:);
            end
        end
    end
        
end

%==========================================================================
function varargout = getNewStructuralMatrices(epilogue,eVarsInd,varargin)

    varargout = varargin;
    for ii = 1:nargin-2
        varargout{ii} = varargin{ii}(~epilogue,~eVarsInd);
    end

end
