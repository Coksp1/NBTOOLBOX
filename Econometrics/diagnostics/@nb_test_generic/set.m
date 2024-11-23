function obj = set(obj,varargin)
% Syntax:
%
% obj = set(obj,varargin)
%
% Description:
%
% Sets the properties of the nb_test_generic objects. 
%
% Caution : It will set the fields of the properties of the object.
% 
% Input:
% 
% - obj : A vector of nb_test_generic objects.
%
% Optional input:
%
% If number of inputs equals 1:
% 
% - varargin{1} : A structure of fields to be set. See the 
%                 template method of each model class for more.
%
% Else:
%
% - varargin    : ...,'inputName',inputValue,... arguments.
%
%                 Where you can set all fields of some properties
%                 of the object. (options, endogenous, exogenous)
%
% Output:
%
% - obj : A vector of nb_test_generic objects.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin == 1
        return
    end

    if nargin == 2
        varargin = nb_struct2cellarray(varargin{1});
    end

    nobj = numel(obj);
    if nobj == 0;
        error('Cannot set properties of a empty vector of nb_test_generic objects.')
    else
       
        for ii = 1:nobj
            
            numberOfInputs = size(varargin,2);
            if rem(numberOfInputs,2) ~= 0
                error('The optional input must come in pairs.')
            end
            
            fields = fieldnames(obj(ii).options);
            for jj = 1:2:numberOfInputs
                
                inputName  = varargin{jj};
                inputValue = varargin{jj + 1};
                
                switch lower(inputName)
                    
                    case 'model'
                        
                        if isa(inputValue,'nb_model_generic') || isa(inputValue,'nb_estimator')
                            obj(ii).model = inputValue;
                        else
                            error([mfilename ':: The property ' inputName ' must be set to an nb_model_generic or an nb_estimator.'])
                        end
                        
                    otherwise
                        
                        ind = find(strcmpi(inputName,fields),1);
                        if isempty(ind)
                            error([mfilename ':: Bad field name of the options property found; ' inputName])
                        end
                        obj(ii).options.(fields{ind}) = inputValue;
                        
                end
                
            end
            
        end
        
    end

end
