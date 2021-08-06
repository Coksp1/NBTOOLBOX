function model = updateParams(model,results)
% Syntax:
%
% model = nb_dsge.updateParams(model,results)
%
% Description:
%
% Update parameter values of a RS-DSGE model.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    param = model.parameters.name';
    calib = [param,num2cell(results.beta)];
    isS   = model.parameters.is_switching;

    % Locate the switching parameters
    mc     = model.markov_chains.regimes;
    mc     = mc(:,3:end)';
    calibT = calib(isS,:);
    calibS = cell(size(calibT,1)*(size(calibT,2)-1),2);
    kk     = 1;
    for ii = 1:size(calibT,1)
        par = calibT{ii,1};
        for jj = 2:size(calibT,2)
            calibS{kk,1} = [par '(' mc{ii,1} ',' int2str(mc{ii,jj}) ')'];
            calibS{kk,2} = calibT{ii,jj};
            kk = kk + 1;
        end
    end
    [~,IA] = unique(calibS(:,1));

    % Update all parameters
    calibA = [calib(~isS,1:2);calibS(IA,:)];
    model  = set(model,'parameters',calibA);

end
