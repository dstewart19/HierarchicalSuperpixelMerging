function [Labels] = HierMergeSp(inputData, par)
% Syntax: [Labels] = HierMergeSp(inputData, par)
%
% Inputs:
%   inputData  - struct - The struct contains the following fields:
%                   1. Labels - MxN matrix (double) of superpixel Labels
%   par - struct - The struct contains the following fields:            
%                   1. I - MxNxB image (double) can be RGB or Intensity
%                   2. method : String for how you want to merge
%                   superpixels ex ('Nearest','Mean','Median','Div')
%                   3. scaling : Logical for if needing to scale by
%                   superpixel size or not (1 for scaling by size and 0 for
%                   not)
%                   4. cbins: Integer for how many color bins for color
%                   histogram calculations
%                   5. k: Integer for how many final superpixels desired
%                   (default = 10)
%                   6. feat: MxNxD feature cube (double)
%                   7. RGB : Logical (1 RGB image 0 not)
%                   
% Outputs:
%   Labels - double Mat - MxN matrix of superpixel labels
%   P - double Mat - NxM matrix of abundances corresponding to M input
%       pixels and N endmembers
% Other m-files required: HierMap,HierMerge
%
% Author: Dylan Stewart
% University of Florida, Electrical and Computer Engineering
% Email Address: d.stewart@ufl.edu
% Created: October 2018
% Latest Revision: October 31, 2018
%%

%Check for final number of superpixels desired, if not set it as an
%arbitrary number 10
if isempty(par.k)
    par.k = 10;
end
K = par.k;

%Setup the mask to be merged
mask = inputData.Labels;

%Setup stopping criteria
numsp = inf;

%Compute Hierarchical Clustering Map and Merge most similar superpixels
while(numsp>K)
    
    %Generate Hierarchical Map
    [simMat,numsp] = HierMap(mask,par);
    
    %Tell user how many superpixels are left
    fprintf(['Merging Superpixels! Currently ',num2str(numsp),...
        ' superpixels...\n']);
    
    %Merge most similar pair of superpixels
    [mask,numsp] = HierMerge(simMat,mask,par);
end

%Final labels
Labels = mask;
end