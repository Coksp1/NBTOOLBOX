function freq = getFrequency(obj,date)
% Syntax:
%
% freq = getFrequency(obj,date)
%
% Description:
%
% Get the frequency of the variables of the model.
% 
% Input:
% 
% - obj  : A scalar object of class nb_mfvar.
%
% - date : As the frequency may change for some variable, you can give a
%          date to get the frequency at a given time. Default is to return
%          the end frequency.
% 
% Output:
% 
% - freq : A 1 x nDep + nBlockExo double with the frequency of each 
%          dependent (nDep) and block exogenous variables (nBlockExo).
%          - 1  : Yearly
%          - 2  : Semi-annually
%          - 4  : Quarterly
%          - 12 : Monthly
%          - 52 : Weekly 
%
% See also:
% nb_mfvar.setFrequency
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: The obj input must be a scalar nb_mfvar object.'])
    end
    
    % Get date input
    if nargin < 2
        date = '';
    end
    if isempty(date)
        if isempty(obj.options.estim_end_date)
            date = obj.options.data.endDate;
        else
            date = obj.options.estim_end_date;
        end
    end
    
    % Default frequency
    dFreq = obj.options.data.frequency;
    
    % Get frequency of dependent variables
    freq = ones(1,obj.dependent.number)*dFreq;
    for ii = 1:obj.dependent.number
        if iscell(obj.dependent.frequency{ii})
            
            varDate = obj.dependent.frequency{ii}{2};
            try
                varDate = nb_date.toDate(varDate,dFreq);
            catch 
                error([mfilename ':: Wrong date format (' toString(varDate) ') given to the change date of the frequency option ',...
                                 'for variable ' obj.dependent.name{ii} '.'])
            end
            if date <= varDate
                freq(ii) = obj.dependent.frequency{ii}{1};
            else
                freq(ii) = obj.dependent.frequency{ii}{3};
            end
            
        elseif ~isempty(obj.dependent.frequency{ii})
            freq(ii) = obj.dependent.frequency{ii};
        end
    end
    
    % Get frequency of dependent variables
    freqB = ones(1,obj.block_exogenous.number)*dFreq;
    for ii = 1:obj.block_exogenous.number
        if iscell(obj.block_exogenous.frequency{ii})
            
            varDate = obj.block_exogenous.frequency{ii}{2};
            try
                varDate = nb_date.toDate(varDate,dFreq);
            catch 
                error([mfilename ':: Wrong date format (' toString(varDate) ') given to the change date of the frequency option ',...
                                 'for variable ' obj.block_exogenous.name{ii} '.'])
            end
            if date <= varDate
                freqB(ii) = obj.block_exogenous.frequency{ii}{1};
            else
                freqB(ii) = obj.block_exogenous.frequency{ii}{3};
            end
            
        elseif ~isempty(obj.block_exogenous.frequency{ii})
            freqB(ii) = obj.block_exogenous.frequency{ii};
        end
    end
    
    freq = [freq,freqB];

end
