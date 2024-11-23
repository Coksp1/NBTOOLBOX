function [newValue,message,obj] = nb_interpretDateObsTypeInputDataGUI(DB,string)
% Syntax:
%
% [newValue,message,obj] = nb_interpretDateObsTypeInputDataGUI(DB,string)
%
% Description:
%
% Part of DAG.
% 
% Function to interpret input from user when it can eiter be a
% obs/date/local variable/type.
%
% Input:
% 
% - DB       : Either an object of class nb_ts, nb_cs or nb_data.
%
% - string   : The value given by the user in the GUI edit box.
%
% Output:
%
% - newValue : The interpreted value.
%
% - message  : If a non-empty string is return an error occured.
%
% - obj      : The nb_date representation of the input string. Only when
%              DB is of class nb_ts, otherwise the same as newValue.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    message  = '';
    obj      = [];
    newValue = [];
    
    if isa(DB,'nb_ts')
            
        freq = DB.frequency;
        if ~nb_contains(string,'%#')
            try
                obj = nb_date.toDate(string,freq);
            catch %#ok<CTCH>
                message = ['Unsupported date format ' string ' for the frequency ' nb_date.getFrequencyAsString(freq) '.'];
                return
            end  
        else
            dateT = nb_localVariables(DB.localVariables,string);
            try
                obj = nb_date.toDate(dateT,freq);
            catch %#ok<CTCH>
                if strcmpi(dateT,string)
                    message = ['Undefined local variable ' string '.'];
                else
                    message = ['Unsupported date format ''' dateT ''' for the frequency '''...
                                    nb_date.getFrequencyAsString(freq) ''' defined by the local variable ' string '.'];
                end
                return
            end
        end
        newValue = string;

    elseif isa(DB,'nb_data')
        
        if nb_contains(string,'%#')
            message = 'Local variables syntax is not supported for dimensionless datasets!';
            return
        end

        obj = str2double(string);
        if isnan(obj)
            message = ['The selected value must be a number, is ' string '.'];
            return
        end 
        newValue = obj;
        
    else
        
        if nb_contains(string,'%#')
            message = 'Local variables syntax is not supported for cross-sectional datasets!';
            return
        end
        
        ind = find(strcmp(string,DB.types),1);
        if isempty(ind)
            message =['Did not find the type ' string ' in the dataset. (case-sensitive)'];
            return
        else
            newValue = string;
            obj      = string;
        end
        
    end

end
