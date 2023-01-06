function obj = createSeasonalDummy(obj,type)
% Syntax:
%
% obj = createSeasonalDummy(obj,type)
%
% Description:
%
% Creates and adds seasonal dummy variables to the nb_ts object. 
% 
% Input:
% 
% - obj            : An object of class nb_ts.
%
% - type           : Centered/ uncentered
% 
% Output:
% 
% - obj : An object of class nb_ts. (With the added dummy variable)
%
% Examples:
%
% See also:
% nb_ts
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2 
        type = 'uncentered';
    end
    
    if isempty(obj.data)
        error('The object is empty');
    end
    
    % Create dummy
    dummy = nb_seasonalDummy(obj.numberOfObservations,obj.frequency,type);
    
    % Add the variable to the object
    vars = obj.variables;
    if strcmpi(type,'uncentered')
        if obj.frequency == 12
            namesOfDummy = {'S01','S02','S03','S04','S05','S06','S07','S08','S09','S10','S11'};
        else
            namesOfDummy = {'S01','S02','S03'};
        end        
        temp = regexp(vars,'S[0-1]{1,1}[0-9]{1,1}','match');
        temp = nb_nestedCell2Cell(temp);    
    else
        if obj.frequency == 12
            namesOfDummy = {'SC01','SC02','SC03','SC04','SC05','SC06','SC07','SC08','SC09','SC10','SC11'};
        else
            namesOfDummy = {'SC01','SC02','SC03'};
        end
        temp = regexp(vars,'SC[0-1]{1,1}[0-9]{1,1}','match');
        temp = nb_nestedCell2Cell(temp);
    end
    
    if ~isempty(temp)
        error('The dataset already has seasonal dummies of this type');
    end
    
    vars = [vars,namesOfDummy];
    dat  = [obj.data,dummy];
    if obj.sorted
        [vars,ind] = sort(vars);
        dat        = dat(:,ind,:);
    end
    obj.data      = dat;
    obj.variables = vars;    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@createSeasonalDummy,type);
        
    end

end
