function default = defaultInputs(convert)
% Syntax:
%
% default = nb_model_generic.defaultInputs(convert)
%
% Description:
%
% Get default values of the inputs to the forecast method of the
% nb_model_generic class. It will be returned as a struct.
% 
% Input:
%
% - convert : Convert to struct if set to true, otherwise not. Default is
%             true.
%
% Output:
%
% - default : A N x 3 cell matrix or a struct with N fields.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    default  = nb_forecast.defaultInputs(false);
    default2 = {'cores',             [],         {@nb_iswholenumber,'&&',@isscalar,'&&',{@gt,0},'||',@isempty};...
                'startDate',         '',         {{@isa,'nb_date'},'||',@ischar};...
                'endDate',           '',         {{@isa,'nb_date'},'||',@ischar};...
                'condDB',            nb_ts,      {{@isa,'nb_ts'},'||',{@isa,'nb_data'},'||',{@isa,'nb_distribution'},'||',@isempty};...
                'condDBVars',        {},         {@iscellstr,'||',@isempty}};
    default  = [default;default2];
    
    if convert       
        default = nb_parseInputs(mfilename,default);
    end
    
end
