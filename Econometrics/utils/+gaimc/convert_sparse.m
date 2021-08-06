function As = convert_sparse(A)
% Syntax:
%
% As = gaimc.convert_sparse(A)
% 
% Description:
%
% Convert a sparse matrix to the native gaimc representation
%
% As = convert_sparse(A) returns a struct with the three arrays defining
% the compressed sparse row structure of A.
%
% Examples:
%   load('graphs/all_shortest_paths_example')
%   As = bgl.convert_sparse(A)
%
% See also:
% gaimc.sparse_to_csr, sparse
%
% Written by David F. Gleich

% David F. Gleich
% Copyright, Stanford University, 2008-2009

% History
% 2009-04-29: Initial coding

    [rp, ci, ai] = gaimc.sparse_to_csr(A);
    As.rp = rp;
    As.ci = ci;
    As.ai = ai;

end
