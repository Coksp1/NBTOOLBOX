function [out,type] = nb_getTypes(out,variables,data,macro,nInp)
% Syntax:
%
% [out,type] = nb_getTypes(out,variables,data,macro,nInp)
%
% Description:
%
% Fill in data to variables in the output from nb_shuntingYardAlgorithm
% function. 
% 
% Input:
% 
% - out       : A cell with the out output from nb_shuntingYardAlgorithm
%               function.
% 
% - variables : Same as the variables input to the nb_shuntingYardAlgorithm
%               function.
%
% - data      : The values of the variables. Either as a double or
%               another object that can be indexed by (:,ii,:), where
%               ii is the variables{ii} value.
%
% - macro     : Set to true to also handle the NB Toolbox macro processing
%               language as well. Default is false.
%
% - nInp      : Number of inputs to each function in out.
%
% Output:
% 
% - out       : A cell with same length as the out input, where the
%               the names of the variables has been changed with the data
%               of those variables.
%
% - type      : A vector needed to evaluate the expression using
%               nb_evalExpression.
%
% See also:
% nb_shuntingYardAlgorithm, nb_getTypesC, nb_evalExpression
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        macro = false;
    end

    % First detect uminus and uplus
    ind      = strcmp(out,'-') & nInp == 1;
    out(ind) = {'uminus'};
    ind      = strcmp(out,'+') & nInp == 1;
    out(ind) = {'uplus'};
    
    % Replace math operators with matching function 
    mOper = {'./','/','.*','*','.^','^','-','+','||','|','&&','&','>=','<=','==','~=','!=','>','<','~','!'};
    mFunc = {'rdivide','rdivide','times','times','power','power','minus','plus',...
             'or','or','and','and','ge','le','eq','ne','ne','gt','lt','not','not'};
    N     = length(mOper);
    for ii = 1:N
        out = strrep(out,mOper{ii},mFunc{ii});
    end

    % Check the type of each element of the interpreted expression
    N    = length(out);
    type = zeros(1,N);
    for ii = 1:N
        element = out{ii}; 
        ind     = strcmp(element,variables);
        if any(ind)
            type(ii) = 1;
            out{ii}  = data(:,ind,:); % Get the data of the given variable
        elseif strncmp(element,'@',1)
            try
                out{ii}  = str2func(element);
                type(ii) = 2;
            catch Err
                error([mfilename ':: Cannot interpret the part; ' out{ii} ' of the expression. Wrong use of function handle syntax. Error::' Err.message])
            end
        else
            indS = regexp(element,'[\(\[][\w\d\:,]+[\)\]]','start');
            if indS == 1
                indS = [];
            end
            if ~isempty(indS)
            
                indexType  = element(indS);
                index      = element(indS:end);
                [s1,s2,s3] = size(data);
                index      = interpretIndex(index,s1,s2,s3);
                element    = element(1:indS-1);
                ind        = strcmp(element,variables);
                if any(ind)
                    type(ii) = 1;
                    if strcmp(indexType,'[')
                        if ~isa(data,'nb_macro')
                            error([mfilename ':: Cannot interpret the part; ' out{ii} ' of the expression. Wrong indexing [].'])
                        end
                        dataVar = data(1,ind);
                        if size(index,1) == 1
                            try
                                out{ii}  = indexing(dataVar,index(1,1):index(1,2)); % Index the nb_macro object
                            catch Err
                                error([mfilename ':: Cannot interpret the part; ' out{ii} ' of the expression. Wrong indexing:: ' Err.message])
                            end
                        else
                            error([mfilename ':: Cannot interpret the part; ' out{ii} ' of the expression. Wrong indexing.'])
                        end
                    else
                        try
                            if size(index,1) < 3 
                                out{ii}  = data(index(1,1):index(1,2),ind); % Get the data of the given variable
                            else
                                out{ii}  = data(index(1,1):index(1,2),ind,index(3,1):index(3,2)); % Get the data of the given variable
                            end
                        catch
                            error([mfilename ':: Cannot interpret the part; ' out{ii} ' of the expression. Wrong indexing:: ' Err.message])
                        end
                    end
                else
                    error([mfilename ':: Cannot interpret the part; ' out{ii} ' of the expression. Wrong indexing.'])
                end
                
            else
                num = str2double(element);
                if ~isnan(num)
                    out{ii}  = num;
                    type(ii) = 3;
                else
                    ind = strcmp(element,{'true','false'});
                    if any(ind)
                        func     = str2func(element);
                        type(ii) = 1;
                        out{ii}  = func(); % Get the data of the given variable
                    else
                        if strcmp(element,',')
                            type(ii) = 4;
                        else
                            if macro 
                                if strcmp(element(1),'{') || strcmp(element(1),'[') || strcmp(element(1),'"') || strcmp(element(1),'''')
                                    type(ii) = 2;
                                end
                            else
                                indI = strfind(element,'"');
                                if ~isempty(indI)
                                    type(ii) = 2;
                                    if size(indI,2) == 2
                                        out{ii}  = element(2:end-1);
                                    else
                                        out{ii}  = element(2:end);
                                    end
                                else
                                    indI = strfind(element,'''');
                                    if ~isempty(indI)
                                        type(ii) = 2;
                                        if size(indI,2) == 2
                                            out{ii}  = element(2:end-1);
                                        else
                                            out{ii}  = element(2:end);
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
    end

end

%=========================================================================
function out = interpretIndex(index,s1,s2,s3)

    s     = [s1,s2,s3];
    indIn = index;
    index = strrep(index,'(','');
    index = strrep(index,'[','');
    index = strrep(index,')','');
    index = strrep(index,']','');
    index = regexp(index,',','split');
    out   = nan(min(size(index,2),3),2);
    for ii = 1:min(size(index,2),3)
        indexT = regexp(index{ii},':','split');
        indexT = strrep(indexT,'end',int2str(s(ii)));
        if length(indexT) ~= 2
            indexT = char(indexT);
            indexT = str2double(indexT); 
            if isnan(indexT)
                error([mfilename ':: Unsupported indexing ' indIn])
            else
                indexT = indexT(ones(1,2),:);
            end
        else
            indexT = char(indexT(1:2)');
            indexT = str2num(indexT); %#ok<ST2NM>
            if size(indexT,1) ~= 2
                indexT = [1;s(ii)];
            end
        end
        out(ii,:) = indexT';
    end

end
