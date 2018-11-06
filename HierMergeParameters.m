function par = HierMergeParameters()
%par = HierMergeParameters() Parameters for Hierarchical Merging of Superpixels
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
par.method = 'Nearest';
par.scaling = 1;
par.k = 20;
par.RGB = 0;
par.I = imread('kobi.png');
end

