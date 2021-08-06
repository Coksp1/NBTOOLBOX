function [d, dt, pred] = bfs(A,u,target)
% Syntax:
%
% [d, dt, pred] = gaimc.bfs(A,u,target)
% 
% Description:
%
% Compute breadth first search distances, times, and tree for a graph
%
% [d, dt, pred] = bgl.bfs(A,u) returns the distance (d) and the discover 
% time (dt) for each vertex in the graph in a breadth first search 
% starting from vertex u.
%   d = dt(i) = inf if vertex i is not reachable from u
% pred is the predecessor array.  pred(i) = 0 if vertex (i)  
% is in a component not reachable from u and i != u.
%
% [...] = bgl.bfs(A,u,v) stops the bfs when it hits the vertex v
%
% Examples:
%
% W  = ones(1,11);
% DG = sparse([6 1 2 2 3 4 4 5 5 6 1],[2 6 3 5 4 1 6 3 4 3 5],W);
%
% [dist,dt,pred] = gaimc.bfs(DG,1)
%
% See also:
% gaimc.dijkstra, nb_shortestpath
%
% Written by David F. Gleich
% 
% Edited by Kenneth S. Paulsen
% - Return inf instead of -1 if vertex is not reachable from u.

% David F. Gleich
% Copyright, Stanford University, 2008-2009

% History
% 2008-04-13: Initial coding

    if nargin < 3
        target = 0; 
    end

    if isstruct(A)
        rp = A.rp; 
        ci = A.ci; 
    else
        [rp,ci] = gaimc.sparse_to_csr(A);
    end

    n    = length(rp)-1; 
    d    = -1*ones(1,n); 
    dt   = -1*ones(1,n); 
    pred = zeros(1,n);
    sq   = zeros(n,1); 
    sqt  = 0; 
    sqh  = 0; % search queue and search queue tail/head

    % start bfs at u
    sqt     = sqt + 1; 
    sq(sqt) = u;   
    d(u)    = 0; 
    dt(u)   = 0; 
    t       = 1; 
    pred(u) = u;
    while sqt - sqh > 0
        sqh = sqh+1;
        v   = sq(sqh); % pop v off the head of the queue
        for ri = rp(v):rp(v+1)-1
            w = ci(ri);
            if d(w) < 0
                sqt     = sqt+1; sq(sqt)=w; 
                d(w)    = d(v) + 1; 
                dt(w)   = t;
                t       = t+1; 
                pred(w) = v; 
                if w == target 
                    return
                end
            end
        end
    end
    
    d(d == -1)   = inf;
    dt(dt == -1) = inf;
    
end
