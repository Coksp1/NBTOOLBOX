function parser = getLeadLagObsModel(parser,inStationarize)
% Syntax:
% 
% parser = nb_dsge.getLeadLagObsModel(parser)
% parser = nb_dsge.getLeadLagObsModel(parser,inStationarize)
%
% Description:
%
% Get lead, current and lag incidence of obs model. 
%
% Static private method.
% 
% See also:
% nb_dsge.parse, nb_dsge.addEquation
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        inStationarize = false;
    end

    endo                      = [parser.endogenous, parser.obs_endogenous];
    exo                       = [parser.exogenous, parser.obs_exogenous, 'Constant'];
    [eqs,test,leadCLag,endoS] = nb_dsge.getLeadLagCore(parser,parser.obs_equations,endo,exo);
    
    % Create auxiliary variables if needed
    checkForMoreLeads = cellfun(@(x)any(x > 0),test);
    if any(checkForMoreLeads)
        error([mfilename ':: The obs_model block cannot contain equations with forward looking variables.'])
    end
    
    numEndo          = size(endoS,2);
    checkForMoreLags = cellfun(@(x)any(x < -1),test);
    index            = 1:length(parser.endogenous);
    isAuxiliary      = false(numEndo,1);
    if any(checkForMoreLags)
        [eqs,leadCLag,auxLag] = nb_dsge.addAuxiliaryLagVariables(eqs,leadCLag,index(checkForMoreLags),endoS(checkForMoreLags),test(checkForMoreLags));
        endoS                 = [endoS,auxLag];
        isAuxiliary           = [isAuxiliary;true(length(auxLag),1)];
    end
    
    % Do we support the bgp function syntax?
    if inStationarize
        
        for ii = 1:length(eqs)
           matches = regexp(eqs{ii},'bgp\(\w{1,1}[\d_\w]*\)','match');
           for jj = 1:length(matches)
               sub     = ['steady_state(D_Z_', matches{jj}(5:end)];
               eqs{ii} = strrep(eqs{ii},matches{jj},sub);
           end
        end
        
    end
    
    % Store output
    parser.obs_equationsParsed = eqs;
    parser.obs_leadCurrentLag  = leadCLag;
    parser.all_endogenous      = endoS;
    parser.all_exogenous       = flip(sort(exo),2);
    parser.all_isAuxiliary     = isAuxiliary;
    
end
