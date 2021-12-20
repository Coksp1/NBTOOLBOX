function out = removeDuplicates(in,dim)
% Syntax: 
%
% out = nb_ts.removeDuplicates(in,dim)
%
% Description:
%
% A static method of the nb_ts class.
%
% Remove duplicates of a SORTED array of strings
% 
% Input:
% 
% - in    : A cell
% 
% - dim   : Give the dimension to remove duplicates. Only needed 
%           when dealing with a matrix.
% 
% Output:
% 
% - out   : A cell where the duplicates are removed.
% 
% Examples:
%
% c = {'Var1','Var2','Var2'};
% out = nb_ts.removeDuplicates(c);
%
% Will result in {'Var1','Var2'}
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if iscell(in)
        if ~isempty(in)
            for pp=1:size(in,1)
                for kk=1:size(in,2)
                    if ~ischar(in{pp,kk})
                        error('The input should be a cell with just strings')
                    end
                end
            end
            if size(in,1)==1 && size(in,2)==1
                out=cell(1);
                out{1}=in{1};
            elseif size(in,1)==1
                n=1;
                out=cell(1);
                out{n}=in{n};
                for ii=1:size(in,2)-1
                    if ~strcmp(in{ii+1},in{ii})
                        n=n+1;
                        out{n}=in{ii+1};
                    end
                end 
            elseif size(in,2)==1
                n=1;
                out=cell(1);
                out{n}=in{n};
                for ii=1:size(in,1)-1
                    if ~strcmp(in{ii+1},in{ii})
                        n=n+1;
                        out{n}=in{ii+1};
                    end
                end 
            elseif size(in,1)>1 && size(in,2)>1
                if nargin==1
                    error('Specify which dimension to remove duplicates (As second argument)')
                end
                if dim==1
                    n=1;
                    out=cell(1,size(in,2));
                    out(n,1:end)=in(n,1:end);
                    for ii=1:size(in,1)-1
                        if ~strcmp(in{ii+1,1},in{ii,1})
                            n=n+1;
                            out(n,1:end)=in(ii+1,1:end);
                        end
                    end 
                elseif dim==2
                    n=1;
                    out=cell(size(in,1),1);
                    out(1:end,n)=in(1:end,n);
                    for ii=1:size(in,1)-1
                        if ~strcmp(in{1,ii+1},in{1,ii})
                            n=n+1;
                            out(1:end,n)=in(1:end,ii+1);
                        end
                    end             
                else
                    error('To remove duplicates in any other dimentions than the first or the second is not possible')
                end      
            end
        else
            out = in;
        end
    else 
        error('Input should be a cell')
    end
end
