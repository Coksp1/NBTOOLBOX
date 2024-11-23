function obj = set(obj,varargin)
% Syntax:
%
% obj = set(obj,varargin)
%
% Description:
%
% Sets the properties of the nb_model_group objects. 
% 
% Input:
% 
% - obj : A vector of nb_model_group objects.
%
% Optional input:
%
% If number of inputs equals 1:
% 
% - varargin{1} : A structure of fields to be set.
%
% Else:
%
% - varargin    : ...,'inputName',inputValue,... arguments.
%
%                 Where you can set all fields of some properties
%                 of the object.
%
% Output:
%
% - obj : A vector of nb_model_group objects.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin == 1
        return
    end

    if nargin == 2
        if isstruct(varargin{1})
            varargin = nb_struct2cellarray(varargin{1});
        else
           error([mfilename ':: Inputs must come in pairs.']) 
        end
    end

    obj  = obj(:);
    nobj = numel(obj);
    if nobj == 0
        error('Cannot set properties of a empty vector of nb_model_group objects.')
    else
       
        for ii = 1:nobj
            
            numberOfInputs = size(varargin,2);
            if rem(numberOfInputs,2) ~= 0
                error('The optional input must come in pairs.')
            end
            
            for jj = 1:2:numberOfInputs
                
                inputName  = varargin{jj};
                inputValue = varargin{jj + 1};
                switch lower(inputName)
                    
                    case 'name'
                             
                        if ischar(inputValue) 
                            if numel(obj) > 1 
                                nums       = strtrim(cellstr(int2str([1:nobj]'))); %#ok<NBRAK>
                                inputValue = strcat(inputValue(1,:),nums);
                            else
                                inputValue = cellstr(inputValue);
                            end
                        end

                        try
                            obj(ii).name = inputValue{ii};
                        catch %#ok<CTCH>
                            error([mfilename ':: The value given to the property ''name'' must be a cellstr with size 1x' int2str(nobj) ' '...
                                'when setting multiple nb_model_generic objects.'])
                        end
                        
                    otherwise
                        
                        error([mfilename ':: The nb_model_group object does not have a settable property ' inputName ])
                        
                end
                
            end
            
        end
        
    end

end
