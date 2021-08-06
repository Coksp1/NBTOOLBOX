function [Y,Z] = addZContribution(Y,model,options,restrictions,inputs,draws,iter)
% Syntax:
%
% [Y,Z] = nb_forecast.addZContribution(Y,model,options,restrictions,...
%                                   inputs,draws,iter)
%
% Description:
%
% Add contributions of exogenous variables to idiosyncratic component of 
% the observation equation.
%
% X = G*Z + Y 
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(model.factors)
        % No exogenous variables so we have nothing to do here.
        Z = zeros(0,size(Y,2),size(Y,3));
        return
    end
        
    if isfield(inputs,'exoProj')
        exoProj = inputs.exoProj;
    else
        exoProj = '';
    end
    index = restrictions.index;
    Z     = restrictions.Z(:,:,index)';
    Z     = Z(:,:,ones(1,draws));
    if ~isempty(exoProj)
        ZAR = nb_forecast.estimateAndBootstrapX(options,restrictions,draws,restrictions.start,inputs,'Z'); 
        if ~isempty(ZAR)
            Z       = [Z;ZAR];
            order   = [restrictions.exoObs(~restrictions.indExoObs),restrictions.exoObs(restrictions.indExoObs)];
            [~,loc] = ismember(order,restrictions.exoObs);
            Z       = Z(loc,:);
        end
    end
    for ii = 1:draws
        Y(:,:,ii) = model.G(:,:,iter)*Z(:,:,ii) + Y(:,:,ii);
    end

end
