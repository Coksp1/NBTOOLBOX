classdef nb_model_convert < nb_model_forecast & nb_model_estimate
% Description:
%
% A class for converting the frequency of nb_model_forecasts. This makes it
% easier to compare or combine forecasts from objects with different
% frequency.
%
% Superclasses:
%
% nb_model_forecast, nb_model_estimate
%
% Constructor:
%
% obj = nb_model_convert(model,varargin) 
% 
% Input:
%
% - model : An object of clss nb_model_generic with stored forecasts.
%
% Optional input:
%
% - 'freq'            : The frequency you want to convert to. As integer. 
%                       Etiher 1, 2, 4, 12 or 365.
%
% - 'method'          : The method which you would like to use to convert 
%                       the forecasts with. For more, see the nb_ts.convert 
%                       method.
%
% - 'name'            : To set a name for the object.
%
% - 'interpolatedate' : Use this to determine if you would like to choose 
%                       the start of the new period or end of the new 
%                       period as date as your forecast date. E.g. if you 
%                       are going from quarterly to monthly and choose 
%                       'start', then 2010Q2 becomes 2010M4. Either 
%                       'start' or 'end', default is 'start'.
%
% Output:
%
% - obj: An object of class nb_model_convert
% 
% Examples:
%
% - nb_model_convert(obj,'freq',12,'method','linear','name','test',...
%                   'interpolatedate','start')
%
% See also:
% nb_model_generic
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties (SetAccess=protected)

        % The nb_model_generic object with the original forecast
        model               = [];

    end
    
    properties(Access=protected)
        
        % History
        historyOutput       = struct();
        
    end
    
    methods
        
        function obj = nb_model_convert(model,varargin)
            
            % Create identifier for this object
            obj.identifier = nb_model_name.findIdentifier();
            
            obj.options = nb_model_convert.template();
            if nargin < 1
                return
            end
            obj.model = model;
            obj       = set(obj,varargin{:});     
            
        end
        
        function obj = check(obj)
           
            methodsDown  = {'average','discrete','first','max','min','sum'};
            methodsUp    = {'linear','cubic','spline','none','fill','daverage'...
                'dsum'};
            methods      = [methodsDown,methodsUp];
            freqs        = [1,2,4,12];
            default = {...
                'data',            nb_ts(),    {@(x)isa(x,'nb_ts'),'||',@isempty};...
                'freq',            [],         {@nb_iswholenumber,'&&',{@ismember,freqs}};...
                'method',          '',         {{@nb_ismemberi,methods},'&&',@ischar};...
                'others',          {},         @iscell;...
                'interpolateDate', 'end',      {{@nb_ismemberi,{'start','end'}},'||',@nb_isScalarInteger}...
                };
            [obj.options,err] = nb_parseInputs(mfilename,default,obj.options);
            if ~isempty(err)
                error(err)
            end
            [~,freqInit] = nb_date.date2freq(obj.model.forecastOutput.start{1});
            if obj.options.freq < freqInit
                if ismember(obj.options.method,methodsUp)
                    error(['The chosen method is not suitable when you are going'...
                        ' from a high frequency to a low frequency!'])
                end
            elseif obj.options.freq == freqInit
                error(['I thought you wanted to change frequency? The frequency'...
                    ' of your data is equal to the frequency option you have '...
                    'chosen!'])
            elseif ismember(obj.options.method, methodsDown)
                error(['The chosen method is not suitable when you are going'...
                    ' from a low frequency to a high frequency!'])

            end
            
            if isempty(obj.options.freq)
                error([mfilename ':: The frequency option cannot be ',...
                    'empty. Please set the freq option to a valid frequency.']);
            end
            
        end
        
        varargout = convertModel(varargin)
        
    end
    
    methods(Hidden=true)
        
        function name = createName(obj)
            
            if ~isscalar(obj)
                error('This method only handle a scalar nb_model_name object.')
            end
            name = ['CONVERT_' int2str(obj.options.freq)];
            if ~isempty(obj.options.method)
                name = [name ,upper(obj.options.method)];
            end
            
        end
        
        function obj = setModel(obj,model)
            obj.model = model;
        end
        
        function obj = setModelAndConvert(obj,model)
            obj.model = model;
            obj       = convert(obj);
        end
        
        function obj = setProps(obj,s)
            
            fields = fieldnames(s);
            for ii = 1:length(fields)
                try
                    obj.(fields{ii}) = s.(fields{ii});
                catch Err
                    if ~strcmpi(Err.identifier,'MATLAB:class:noSetMethod')
                        rethrow(Err)
                    end
                end
            end
            
        end
        
        function obj = setNames(obj,~,~)
            
        end
        
    end
    
    methods(Access=protected) 
        varargout = wrapUpEstimation(varargin);
    end
    
    methods (Static=true)
       varargout = help(varargin)
       varargout = template(varargin)
    end
    
end
