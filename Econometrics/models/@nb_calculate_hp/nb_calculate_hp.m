classdef nb_calculate_hp < nb_calculate_only
% Description:
%
% A class for doing HP-filtering of series.
%
% Constructor:
%
%   obj = nb_calculate_hp(varargin)
% 
%   Optional input:
%
%   - See the set method for more on the inputs. 
%     (nb_model_estimate.set)
% 
%   Output:
% 
%   - obj : A nb_calculate_hp object.
% 
% See also:
% nb_calculate_vintages
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen
   
    properties
        
        % A struct with the fields name, tex_name and number. The name 
        % field holds a cellstr with the names of all the variable(s) 
        % that you want to seasonlly adjust, the tex_name holds the names  
        % in the tex format. The number field holds a double with the 
        % number of variables. To set it use the set function. E.g. 
        % obj = set(obj,'dependent',{'Var1','Var2'});
        % or use the <className>.template() method.
        dependent      = struct(); 
 
    end

    methods

        function obj = nb_calculate_hp(varargin)
        % Constructor

            % Setup the model variables structures
            temp            = struct();
            temp.name       = {};
            temp.tex_name   = {};
            temp.number     = [];
            obj.dependent = temp;
            
            % Set the properties and options of the model
            temp           = nb_calculate_hp.template();
            temp           = rmfield(temp,{'dependent'});
            obj.options    = temp;
            obj            = set(obj,varargin{:});
            
            % Create identifier for this object
            obj.identifier = nb_model_name.findIdentifier();

        end
        
    end
    
    methods (Hidden=true)
        
        function name = createName(obj)
            
            if ~isscalar(obj)
                error('This method only handle a scalar nb_model_name object.')
            end
            name = ['HP_FILTER_' int2str(obj.options.lambda)];
            
        end
        
        function tempObj = setNames(tempObj,inputValue,type)

            if isempty(inputValue)
               vars     = {};
               texVars  = {};
            else
                if ~iscellstr(inputValue) 
                    error([mfilename ':: The property ' type ' must be set to a cellstr. {''Var1'',''"Var1_tex"'',...}'])
                end
                
                % Parse the cellstr for var names and tex names
                ind     = regexp(inputValue,'"\w+"');
                indTex  = ~cellfun('isempty',ind);
                texLoc  = find(indTex);
                if isempty(texLoc)
                    vars    = inputValue;
                    texVars = inputValue;
                else

                    if texLoc(1) == 1
                        error([mfilename ':: The decleared ' type ' variables can not start with a tex name. I.e. the notation "Var1".'])
                    elseif any(diff(texLoc,1,2) == 1)
                        error([mfilename ':: The decleared ' type ' variables can be given two consecutive tex names. I.e. the notation "Var1".'])
                    end
                    varLoc  = find(~indTex);
                    vars    = inputValue(~indTex);
                    texVars = vars;

                    % Find out where to place the tex names
                    [foundPlace,placeTex] = ismember(texLoc,varLoc + 1);
                    if ~all(foundPlace)
                        error([mfilename ':: Could not find a matching variable to one of the tex names.'])
                    end
                    texVars(placeTex) = inputValue(indTex);

                end
            end

            if iscolumn(vars)
                vars = vars';
            end
            if iscolumn(texVars)
                texVars = texVars';
            end

            % Create structure
            temp          = struct();
            temp.name     = vars;
            temp.tex_name = texVars;
            temp.number   = length(vars);
            switch lower(type)
                case 'dependent'
                    tempObj.dependent = temp;
            end

        end
        
    end
    
    methods (Static=true)
        
        varargout = template(varargin)
        varargout = help(varargin)
             
    end
    
end

