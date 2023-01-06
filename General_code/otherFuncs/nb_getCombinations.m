function varargout = nb_getCombinations(nMin,nMax,varargin)
% Syntax:
%
% varargout = nb_getCombinations(varargin)
%
% Description:
%
% Get all possible combinations of the optional inputs. Must be either a
% cell (1,N) or double (1xN).
% 
% Input:
% 
% - nMin            : Min number of elements combined from the first  
%                     input. If empty 1 is used.
%
% - nMax            : Max number of elements combined from the first input. If 
%                     empty length(varargin{1}) is used
% 
% - varargin{1}     : The main input to max combination of. I.e. the nMin 
%                     and nMax is only applicable to this input.
%
% - varargin{2:end} : The varargin{1:ii-1} are replicated with the size of
%                     these inputs to create all combinations.
%
% Output:
% 
% - varargout{1}     = Number of elements of the combinations.
%
% - varargout(2:end) = The inputs in all its combinations
%
% Examples:
%
% [s,vars,lags] = nb_getCombinations(1,4,{'Var1','Var2','Var3','Var4'},1:10);
% [s,vars,lags] = nb_getCombinations(1,3,{'Var1','Var2','Var3','Var4'},1:10);
% [s,vars,lags] = nb_getCombinations(1,3,{'Var1','Var2','Var3'},{1,2,3});
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get all possible combinations of variables
    vec  = varargin{1};
    nVec = length(vec);
    if isempty(nMax)
        nMax = nVec;
    end
    if isempty(nMin)
        nMin = 1;
    end
    if nMin > nMax
       nMin = nMax;
    end
    
    combi        = nb_combine(vec,nMin,nMax);
    num          = length(combi);
    sInputs      = size(varargin,2);
    varargout    = cell(1,sInputs+2);
    varargout{2} = combi;
    for ii = 2:sInputs

        vecT = varargin{ii};
    
        % Replicate the compi accordingly to the rest of the inputs
        maxNum = size(vecT,2);
        for jj = 2:ii
            varargout{jj}  = repmat(varargout{jj},[1,maxNum]);
        end

        % Then replicate the rest of the input to match the size of combi
        if isnumeric(vecT) || islogical(vecT)
            combiT          = vecT(ones(num,1),:);
            varargout{ii+1} = num2cell(combiT(:)');
        elseif iscell(vecT)
            combiT          = vecT(ones(num,1),:);
            varargout{ii+1} = combiT(:)';
        else
            error([mfilename ':: The optional input to this function must either be cell or double. Is ' class(vecT)])
        end
        num = num*maxNum;

    end

    varargout{1} = num;
    
end
