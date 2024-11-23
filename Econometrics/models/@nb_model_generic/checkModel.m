function obj = checkModel(obj)
% Syntax:
%
% obj = checkModel(obj)
%
% Description:
%
% Secure that the object is up to date when it comes to the options,
% estOptions and results struct properties.
% 
% Input:
% 
% - obj : An object of class nb_model_generic.
% 
% Output:
% 
% - obj : An object of class nb_model_generic.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    estOptions = obj.estOptions;
    options    = obj.options;
    results    = obj.results;
    switch class(obj)
        
        case 'nb_arima'
            
            % More properties where added in june 2017
            estOptions = nb_defaultField(estOptions,'SAR',0);
            estOptions = nb_defaultField(estOptions,'SMA',0);
            estOptions = nb_defaultField(estOptions,'covrepair',false);
            estOptions = nb_defaultField(estOptions,'optimizer','fminunc');
            estOptions = nb_defaultField(estOptions,'exogenous',{});
            options    = nb_defaultField(options,'SAR',0);
            options    = nb_defaultField(options,'SMA',0);
            options    = nb_defaultField(options,'covrepair',false);
            options    = nb_defaultField(options,'optimizer','fminunc');
            options    = nb_defaultField(options,'exogenous',{}); 
            
    end
    options        = nb_defaultField(options,'page',[]);
    options        = nb_defaultField(options,'real_time_estim',0); 
    obj.estOptions = estOptions;
    obj.options    = options;
    obj.results    = results;

    if isa(obj,'nb_arima')
        if ~isfield(obj.solution,'factors')
            if isestimated(obj)
                obj = solve(obj);
            end
        end
    end
    
end

