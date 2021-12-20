function methods = getParameterDrawsMethods(obj,gui,forecast)
% Syntax:
%
% methods = parameterDraws(obj)
%
% Description:
%
% Get supported methods for drawing parameters for the given model. 
%
% Input:
% 
% - obj      : A scalar object of a subclass of the nb_model_generic class.
%
% - gui      : true or false. Default is false.
%
% - forecast : For forecast. true or false. Default is false.
%
% Output:
% 
% - methods : The supported methods for drawing parameters for the given 
%             model.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        forecast = false;
        if nargin < 2
            gui = false;
        end
    end

    if numel(obj)>1
        error([mfilename ':: This function only handles scalar nb_model_generic objects.'])
    end
    
    try
        estimT = obj.estOptions(end).estimType;
    catch %#ok<CTCH>
        estimT = 'classic';
    end
    
    if strcmpi(estimT,'bayesian')
        methods = {'Posterior'};
    else
        if gui
            methods = {'Bootstrap','Wild bootstrap','Block bootstrap','Wild block bootstrap','Overlapping block bootstrap','Random length block bootstrap'};%,'Copula bootstrap'
        else
            methods = {'bootstrap','wildBootstrap','blockBootstrap','wildBlockBootstrap','mblockBootstrap','rblockBootstrap'};%,'copulaBootstrap'
        end
    end
    
    if isa(obj,'nb_var')
        if ~forecast
            try
                C     = obj.solution.C;
                draws = size(C,4);
                if draws > 100
                    if gui
                        methods = [methods,'Identification Draws'];
                    else
                        methods = [methods,'identDraws'];
                    end
                end
            catch %#ok<CTCH>
            end
        end
    elseif isa(obj,'nb_arima')
        if strcmpi(obj.estOptions(end).algorithm,'ml')
            if gui
                methods = [methods,'Asymptotic distribution'];
            else
                methods = [methods,'asymptotic'];
            end
        end
    end

end
