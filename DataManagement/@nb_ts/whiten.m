function F = whiten(obj,r)
% Syntax:
%
% F = whiten(obj)
% F = whiten(obj,r)
%
% Description:
%
% Calculate of factors from X that have variance one and covariances 0.
% 
% Input:
%
% - obj     : An object of class nb_ts with size nObs x nVar x nPage.
%
% - r       : The number of principal component. If empty nVar factors are
%             returned.
%
% Output:
% 
% - F       : The principal component, as a nb_ts object.
%
% Example:
%
% load hald;
% ingredients = nb_ts(ingredients,'',1,{'tricalcium_aluminate',...
%                                       'tricalcium_silicate',...
%                                       'tetracalcium_aluminoferrite',...
%                                       'beta_dicalcium_silicate'});
% F = whiten(ingredients)
%
% See also:
% nb_whiten, nb_ts.pca
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
  
    if nargin < 2
        r = [];
    end

    F      = nb_whiten(obj.data,r);
    s      = size(F,2);
    varsPC = cell(1,s);
    for ii = 1:s
        varsPC{ii} = ['Factor' int2str(ii)];
    end
    
    % The principal components
    F = nb_ts(F,'',obj.startDate,varsPC,false);
    if obj.isUpdateable()
        F.links      = obj.links;
        F.updateable = 1;
        F            = F.addOperation(@whiten,{r});
    end
             
end
