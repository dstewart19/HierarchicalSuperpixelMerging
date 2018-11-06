function [merge_mask,Nsp] = HierMerge(simMat,old_mask,par)
%[merge_mask,Nsp] = HierMerge(simMat,old_mask,par)
%   merge superpixels that are most similar in the similarity matrix and
%   update the mask for the image

if strcmp(par.comp,'Div')||strcmp(par.comp,'Mean')||strcmp(par.comp,'Median')||strcmp(par.comp,'Nearest')
    %find minimum difference
    [mergeMeasure,idx] = min(simMat(:));
end
%find the pair of superpixels where this occurs
[sp1,sp2] = ind2sub(size(simMat),idx);

%merge the 2 superpixels
old_mask(old_mask==sp1)=sp2;

% get neighborhood region
%find segment boundaries
[cx,cy] = gradient(old_mask);
seg_bounds = (abs(cx)+abs(cy))~=0;
SE = strel('square',4);
mask_temp = old_mask == sp1;
merged_sp = mask_temp;

%find boundary of region
seg_temp = mask_temp.*seg_bounds;

%dilate boundaries
seg_dilate = imdilate(seg_temp,SE);

%list of superpixels surrounding region
seg_nbrs = seg_dilate.*old_mask;

%get complete mask of the update region for when the superpixel numbers are
%changed
nbrs = unique(seg_nbrs); nbrs = nbrs(nbrs>0);
tempmask = [];
for nnbrs = 1:length(nbrs)
    tempmask(:,:,nnbrs) = old_mask==nbrs(nnbrs);
end
update_region = sum(tempmask,3);

%delete that row of the map
simMat(sp1,:) = [];
simMat(:,sp1) = [];

%save merged map
merge_map = simMat;

%update old_mask numbers
merge_mask = renumberregions(old_mask);
Nsp = length(unique(merge_mask(:)));
end

