function [newValue,message,obj] = nb_interpretDateObsTypeInputGUI(plotterT,string,freq)
% Syntax:
%
% [newValue,message,obj] = ...
%       nb_interpretDateObsTypeInputGUI(plotterT,string,freq)
%
% Description:
%
% Function to interpret input from user when it can eiter be a
% obs/date/local variable/type.
% 
% Input:
% 
% - plotterT : Either an object of class nb_graph or nb_table_data_source.
%
% - string   : The value given by the user in the GUI edit box.
%
% - freq     : The frequency accepted.
% 
% Output:
% 
% - newValue : The interpreted value.
%
% - message  : Error message if the input does not match the requirements.
%
% - obj      : The interpreted value as an object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        freq = [];
    end

    message  = '';
    obj      = [];
    newValue = [];
    
    if isa(plotterT,'nb_graph_ts') || isa(plotterT,'nb_table_ts')
            
        if isempty(freq)
            freq = plotterT.DB.frequency;
        else
            if ischar(freq)
                freq = nb_date.getFrequencyAsInteger(freq);
            end
        end
            
        if ~nb_contains(string,'%#')
            try
                obj = nb_date.toDate(string,freq);
            catch %#ok<CTCH>
                message = ['Unsupported date format ' string ' for the frequency ' nb_date.getFrequencyAsString(freq) '.'];
                return
            end  
        else
            dateT = nb_localVariables(plotterT.localVariables,string);
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

    elseif isa(plotterT,'nb_graph_data') || isa(plotterT,'nb_table_data')

        if ~nb_contains(string,'%#')
            obj = str2double(string);
            if isnan(obj)
                message = ['The selected value must be a number, is ' string '.'];
                return
            end 
            newValue = obj;
        else
            obsT = nb_localVariables(plotterT.localVariables,string);
            obj  = str2double(obsT);
            if isnan(obj)
                message =['The selected value must be a number, is ' obsT ' (Local variable; ' string ').'];
                return
            end
            newValue = string;
        end
        

    else
        
        if nb_contains(string,'%#')
            message = 'Local variables syntax is not supported for cross-sectional data!';
            return
        end
        
        ind = find(strcmp(string,plotterT.typesToPlot),1);
        if isempty(ind)
            message =['Did not find the type ' string ' in the plotted types. (case-sensitive)'];
            return
        else
            newValue = string;
            obj      = string;
        end
    end

end
