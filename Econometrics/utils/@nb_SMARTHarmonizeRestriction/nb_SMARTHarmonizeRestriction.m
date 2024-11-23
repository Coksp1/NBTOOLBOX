classdef nb_SMARTHarmonizeRestriction
% Description:
%
% An object of this class represent one restiction to be used by a
% harmonizer.
%
% Constructor:
%
%   obj = nb_SMARTHarmonizeRestriction(name,description,...
%       restricted,parameters,variables,frequency,mapping,R_scale)
%
%   Input:
%
%   See the help on the properties of this class with the same names.
%
%   Output:
%
%   - obj : An object of class nb_SMARTHarmonizeRestriction.
%
% See also:
% nb_SMARTJudgmenter
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    properties (SetAccess=protected)
        
        % The name of the applied restriction
        name = '';
        
        % The description of the applied restriction
        description = '';
        
        % The variable being restricted
        restricted = '';
        
        % The parameters of the restrictions. Either a 1 x nVars double
        % or a 1 x nVars cellstr.
        parameters = [];
        
        % The variables of the VAR being restricted. As a 1 x nVars 
        % cellstr.
        variables = {};
        
        % The frequency of the restricted variable. Set to [], if the
        % frequency is the same as that of the variables of the VAR.
        frequency = [];
        
        % Set the mapping of the restricted variable. Default is
        % 'diffAverage'. Only used if the frequency property is not empty.
        % For the supported mappings see help on the method
        % nb_mfvar.setMapping.
        % See also:
        % nb_mfvar.setMapping
        mapping   = 'diffAverage';
        
        % Set the inverse measurement error parameter used during 
        % historical filtering. Inf means no  measurement error allowed, 
        % i.e. the restriction need to hold exactly.
        R_scale   = 100;
        
    end
    
    methods
        
        function obj = nb_SMARTHarmonizeRestriction(name,description,...
                restricted,parameters,variables,frequency,mapping,R_scale)
            
            if ~nb_isOneLineChar(name)
                error('The name input must be a one line char.')
            end
            if ~nb_isOneLineChar(description)
                error('The description input must be a one line char.')
            end
            if ~nb_isOneLineChar(restricted)
                error('The restricted input must be a one line char.')
            end
            if ~(iscellstr(parameters) || (isvector(parameters) && isnumeric(parameters)))
                error('The parameters input must be a cellstr or a double vector.')
            end
            if ~iscellstr(variables)
                error('The variables input must be a cellstr.')
            end
            if ~nb_isOneLineChar(mapping)
                error('The mapping input must be a one line char.')
            end
            if length(parameters) ~= length(variables)
                error('The parameters and variables inputs must have same length')
            end
            if ~(nb_isScalarInteger(frequency) || isempty(frequency))
                error('The frequency input must be a scalar integer')
            end
            if ~nb_isScalarNumber(R_scale,0)
                error('The R_scale input must be a scalar number greater then 0')
            end
            obj.name        = name;
            obj.description = description;
            obj.restricted  = restricted;
            obj.parameters  = parameters;
            obj.variables   = variables;
            obj.frequency   = frequency;
            obj.mapping     = mapping;
            obj.R_scale     = R_scale;
            
        end
        
        function disp(obj)
            
            obj = obj(:);
            if size(obj,1) > 1
               for ii = 1:size(obj,1)
                   disp(obj(ii))
               end
               return
            end
            
            disp(' ')
            restr = [obj.restricted ' = '];
            for ii = 1:length(obj.parameters)
                if iscellstr(obj.parameters)
                    paramStr = obj.parameters{ii};
                else
                    paramStr = num2str(obj.parameters(ii));
                end
                restr = [restr, paramStr '*' obj.variables{ii} ' + ']; %#ok<AGROW>
            end
            restr = restr(1:end-3);
            
            table = {
                'Name: ',obj.name
                'Description: ',obj.description
                'Restriction: ',restr
                'Frequency: ', int2str(obj.frequency)
                'Mapping: ',obj.mapping
                'Meas. error: ' num2str(obj.R_scale)
            };
            
            disp([char(table(:,1)),char(table(:,2))]);
            
        end
        
        function namesOfRest = names(obj)
            obj         = obj(:);
            namesOfRest = {obj.name};
        end
        
        function s = get(obj)
            
            obj = obj(:);
            s = struct(...
                'restricted','',...
                'parameters',cell(1,size(obj,1)),...
                'variables',[],...
                'frequency',[],...
                'mapping','',...
                'R_scale',[] ... 
            );
            for ii = 1:size(obj,1)
                s(ii).restricted = obj(ii).restricted;
                s(ii).parameters = obj(ii).parameters;
                s(ii).variables  = obj(ii).variables;
                s(ii).frequency  = obj(ii).frequency;
                s(ii).mapping    = obj(ii).mapping;
                s(ii).R_scale    = obj(ii).R_scale;
            end
            
        end
        
    end
    
end
