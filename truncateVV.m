function [VV2 vertices2] = truncateVV(VV, vertices, keep)
% [VV2 vertices2] = truncateVV(VV, vertices, keep)
%
% Truncate a vertex-vertex mesh by removing vertices and all faces adjacent
% to them.

numOriginalVertices = size(vertices,1);

allVerts = 1:numOriginalVertices;

keepThese = sort(allVerts(keep));

%deleteThese = allVerts;
%deleteThese(keep) = [];

%% Remove neighbor references TO vertices to delete.
% Also remove rows that I need to delete.
[ii jj ss] = find(VV);

keepFlags = ismember(ss, keepThese) & ismember(ii, keepThese);

iiKeep = ii(keepFlags);
jjKeep = jj(keepFlags);
ssKeep = ss(keepFlags);

lookupTable = zeros(1, numOriginalVertices);
lookupTable(keepThese) = 1:numel(keepThese);

VV2 = sparse(lookupTable(iiKeep), jjKeep, lookupTable(ssKeep), ...
    numel(keepThese), 100);

assert(size(VV2,1) == numel(keepThese));
%% Remove non-trailing zeros from rows of VV2.

for rr = 1:size(VV2,1)
    numNeighbors = nnz(VV2(rr,:));
    
    VV2(rr,1:numNeighbors) = VV2(rr, VV2(rr,:) > 0);
    VV2(rr, numNeighbors+1:end) = 0;
    
end

%% And produce the vertices!

vertices2 = vertices(keepThese,:);