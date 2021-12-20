function [eqs,leadCLag,auxLag] = addAuxiliaryLagVariables(eqs,leadCLag,ind,lagedEndo,leadLagCheck)
% Syntax:
% 
% [eqs,leadCLag,auxLag] = nb_dsge.addAuxiliaryLagVariables(eqs,...
%                           leadCLag,ind,lagedEndo,leadLagCheck)
%
% Description:
%
% Add auxiliary variable to model given more lags than 1. 
%
% Static private method.
% 
% See also:
% nb_dsge.parse, nb_dsge.addEquation
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the number of added equations
    nLaged = length(lagedEndo);
    llcMin = nan(1,nLaged);
    for ii = 1:nLaged
        llc              = leadLagCheck{ii};
        llc              = llc(llc < -1);
        llcMin(ii)       = abs(min(llc));
        leadLagCheck{ii} = llc;
    end
    
    % Add new equations and substitute out for lagged variables
    numNewEq    = sum(llcMin-1);  
    leadCLagNew = [false(numNewEq,1),true(numNewEq,2)];
    auxLag      = cell(1,numNewEq);
    newEqs      = cell(numNewEq,1);
    kk          = 1;
    for ii = 1:length(lagedEndo)
       
        endo       = lagedEndo{ii};
        llc        = leadLagCheck{ii};
        llc        = llc(llc < -1);
        llcMin     = abs(min(llc));
        new        = ['AUX_LAG_', endo];
        newT       = [new,'_1'];
        newEqs{kk} = [newT '-' endo '(-1)'];
        auxLag{kk} = newT;
        kk         = kk + 1;  
        if any(-2 == llc)
            old = [endo,'\(-2\)'];
            old = strcat('(?<![A-Za-z_])',old);
            eqs = regexprep(eqs,old,[newT,'(-1)']);
        end
        leadCLag(ind(ii),3) = true; % Indicate that the variable is lagged
        for jj = 3:llcMin
           
            newTOld = newT;
            newT    = [new,'_', int2str(jj-1)];
            if any(-jj == llc)
                old = [endo,'\(', int2str(-jj),'\)'];
                old = strcat('(?<![A-Za-z_])',old);
                eqs = regexprep(eqs,old,[newT,'(-1)']);
            end
            newEqs{kk} = [newT '-' newTOld '(-1)'];
            auxLag{kk} = newT;
            kk         = kk + 1;
            
        end
        
    end
    eqs      = [eqs;newEqs];
    leadCLag = [leadCLag;leadCLagNew];
    
end
