function obj = set(obj,varargin)
% Syntax:
%
% obj = set(obj,varargin)
%
% Description:
%
% Set properties of the object using 'propertyName', propertyValue
% pairs.
%
% Input:
% 
% - obj : An object of class nb_abcSolve.
%
% Optional inputs:
%
% - varargin: 'propertyName', propertyValue pairs
% 
% Output:
% 
% - obj : An object of class nb_fmin where the wanted properties has been 
%         set.
%
% Examples:
%
% set(obj,'initialXValue',2,'lowerBound',0)
%
% See also:
% nb_abcSolve.optimset
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        [s1,s2,s3] = size(obj);
        obj        = obj(:);
        for ii = 1:s1*s2*s3
           obj(ii) = set(obj(ii),varargin{:});
        end
        obj = reshape(obj,[s1,s2,s3]);
        return
    end

    if size(varargin,1) && iscell(varargin{1})
        varargin = varargin{1};
    end

    if rem(length(varargin),2) ~= 0
        error([mfilename ':: The ''propertyName'', propertyValue inputs must come in pairs.'])
    end

    for jj = 1:2:size(varargin,2)

        if ischar(varargin{jj})

            propertyName  = varargin{jj};
            propertyValue = varargin{jj + 1};
            switch lower(propertyName)
                case 'initialxvalue'
                    obj.initialXValue = propertyValue;
                case 'lowerbound'
                    obj.lowerBound = propertyValue;
                case 'objective'
                    obj.objective = propertyValue;
                case 'objectiveinputs'
                    obj.objectiveInputs = propertyValue;    
                case 'options'
                    obj.options = propertyValue;
                case 'upperbound'
                    obj.upperBound = propertyValue;
                otherwise
                    error([mfilename ':: Bad property name; ' propertyName])
            end

        end

    end

end
