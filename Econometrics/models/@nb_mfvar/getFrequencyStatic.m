function [freq,date] = getFrequencyStatic(estOptions,dateInd)
% Syntax:
%
% [freq,date] = nb_mfvar.getFrequencyStatic(estOptions,dateInd)
%
% Description:
%
% Get the frequency of the variables of the model. 
%
% See also:
% nb_mfvar.getFrequency
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    % Default frequency
    [start,dFreq] = nb_date.date2freq(estOptions.dataStartDate);
    date          = start + (dateInd - 1);
    
    % Get frequency of dependent variables
    numDep = length(estOptions.dependent);
    numB   = length(estOptions.block_exogenous);
    freq   = ones(1,numDep + numB)*dFreq;
    for ii = 1:numDep
        if iscell(estOptions.frequency{ii})
            
            varDate = estOptions.frequency{ii}{2};
            try
                varDate = nb_date.toDate(varDate,dFreq);
            catch 
                error([mfilename ':: Wrong date format (' toString(varDate) ') given to the change date of the frequency option ',...
                                 'for variable ' estOptions.dependent{ii} '.'])
            end
            if date <= varDate
                freq(ii) = estOptions.frequency{ii}{1};
            else
                freq(ii) = estOptions.frequency{ii}{3};
            end
            
        elseif ~isempty(estOptions.frequency{ii})
            freq(ii) = estOptions.frequency{ii};
        end
    end
    
    % Get frequency of dependent variables
    for ii = numDep + 1:numDep + numB
        if iscell(estOptions.frequency{ii})
            
            varDate = estOptions.frequency{ii}{2};
            try
                varDate = nb_date.toDate(varDate,dFreq);
            catch 
                error([mfilename ':: Wrong date format (' toString(varDate) ') given to the change date of the frequency option ',...
                                 'for variable ' estOptions.block_exogenous{ii - numDep} '.'])
            end
            if date <= varDate
                freq(ii) = estOptions.frequency{ii}{1};
            else
                freq(ii) = estOptions.frequency{ii}{3};
            end
            
        elseif ~isempty(estOptions.frequency{ii})
            freq(ii) = estOptions.frequency{ii};
        end
    end

end
