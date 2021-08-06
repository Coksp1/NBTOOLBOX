function s = struct(obj)
% Syntax:
%
% s = struct(obj)
%
% Description:
%
% Convert object to struct.
% 
% Input:
% 
% - obj : An object of class nb_model_estimate.
% 
% Output:
% 
% - s   : A struct representing the nb_model_generic object.
%
% See also:
% nb_model_estimate.unstruct
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    s     = struct('class',class(obj));
    props = properties(obj);
    props = setdiff(props,{'name'}); % Name is a dependent property!
    for ii = 1:length(props)
        s.(props{ii}) = obj.(props{ii});
    end
    
    % This is the user defined name, which we want to store
    s.nameLocal  = getNameLocal(obj);
    
    % Get identifier, as that is set upon construction of the object and
    % should not change
    s.identifier   = getIdentifier(obj);
    s.addIDIfLocal = getAddIDIfLocal(obj);

    % Convert data to structure as well
    opt           = s.options;
    opt.data      = [];
    s.options     = opt;
    s.dataOrig    = struct(obj.dataOrig);
    s.fcstHorizon = obj.fcstHorizon;
    
    % Store data property in a efficient way
    real_time_estim     = false;
    missing             = false;
    estOpt              = s.estOptions;
    try real_time_estim = estOpt(1).real_time_estim; catch; end %#ok<CTCH>
    try missing         = ~isempty(estOpt(1).missingMethod); catch; end %#ok<CTCH>
    if missing
        
        if isfield(estOpt(1),'missingVariables')
            missingVariables = estOpt(1).missingVariables;
        else
            missingVariables = {};
        end
        
        alreadySaved    = obj.options.data.variables;
        remove          = ismember(estOpt(1).dataVariables,alreadySaved);
        keep            = ismember(estOpt(1).dataVariables,missingVariables);
        keep            = keep | ~remove;
        nPer            = length(estOpt);
        saved(1,nPer)   = struct('data',[],'startInd',[],'endInd',[]);
        if isfield(estOpt(end),'missingData')
        
            missingDataFull = estOpt(end).missingData;
            for ii = 1:nPer
                missingData        = estOpt(ii).missingData;
                missingPeriod      = all(missingData,2);
                startInd           = find(~missingPeriod,1);
                endInd             = estOpt(ii).estim_end_ind;
                saved(ii).data     = estOpt(ii).data(startInd:endInd,keep);
                saved(ii).startInd = startInd;
                saved(ii).endInd   = endInd;
            end
            
        else
            
            missingDataFull = [];
            for ii = 1:nPer
                startInd           = estOpt(ii).estim_start_ind;
                endInd             = estOpt(ii).estim_end_ind;
                saved(ii).data     = estOpt(ii).data(startInd:endInd,keep);
                saved(ii).startInd = startInd;
                saved(ii).endInd   = endInd;
            end
            
        end
        
        estOpt                   = nb_rmfield(estOpt,{'missingData','data','estim_end_ind'});
        estOpt                   = nb_collapsStruct(estOpt);
        estOpt.missingStored     = saved;
        estOpt.missingStoredVars = keep;
        estOpt.missingData       = missingDataFull;

    elseif real_time_estim
        
        alreadySaved  = obj.options.data.variables;
        keep          = ~ismember(estOpt(1).dataVariables,alreadySaved);
        nPer          = length(estOpt);
        saved(1,nPer) = struct('data',[],'startInd',[],'endInd',[]);
        for ii = 1:nPer
            startInd           = estOpt(ii).estim_start_ind;
            endInd             = estOpt(ii).estim_end_ind;
            saved(ii).data     = estOpt(ii).data(startInd:endInd,keep);
            saved(ii).startInd = startInd;
            saved(ii).endInd   = endInd;
        end
        estOpt            = rmfield(estOpt,{'data','estim_end_ind'});
        estOpt            = nb_collapsStruct(estOpt);
        estOpt.stored     = saved;
        estOpt.storedVars = keep;
        
    end
    s.estOptions = estOpt;
    
    if isa(obj,'nb_dsge')
       
        % Store some hidden properties as well
        s.balancedGrowthSolved    = obj.balancedGrowthSolved;
        s.isStationarized         = obj.isStationarized;
        s.needToBeSolved          = obj.needToBeSolved;
        s.observablesHidden       = obj.observablesHidden;
        s.steadyStateContent      = obj.steadyStateContent;
        s.steadyStateSolved       = obj.steadyStateSolved;
        s.takenDerivatives        = obj.takenDerivatives;
        
    end
    
end
