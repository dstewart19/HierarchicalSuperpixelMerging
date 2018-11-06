function [simMat,sp_num] = HierMap(input_mask,par)
% 
%[simMat,Nsp] = HierMap(input_mask,feat,par)
%   Compute hierarchical clustering map given the image and an input mask
%   and features. Image (M x N) Input_mask (M x N) Feat (M x N x D)

if par.RGB
    feat = par.I;
else
    feat = par.feat;
end

sp_num = unique(input_mask);      %find unique segment IDs

%find segment boundaries
[cx,cy] = gradient(input_mask);
seg_bounds = (abs(cx)+abs(cy))~=0;

[mrows,ncols,nfeat] = size(feat);
feat = reshape(feat,[mrows*ncols,nfeat]);
feat(isnan(feat))=0;
orig_image = par.I;
tmap = par.tmap;


%grow boundaries by two pixels
%so each side touches
%two different classes
SE = strel('square',4);
simMat = [];


for k  = 1:length(sp_num)
    
    %find particular region
    mask_temp = input_mask==sp_num(k);
    
    if sum(mask_temp(:))>0
        %find boundary of region
        seg_temp = mask_temp.*seg_bounds;
        
        %dilate boundaries
        seg_dilate = imdilate(seg_temp,SE);
        
        %list of superpixels surrounding region
        seg_nbrhd = unique(seg_dilate.*input_mask);
        
        %remove 0 and current seg number
        seg_nbrhd(seg_nbrhd==0) = [];
        seg_nbrhd(seg_nbrhd==sp_num(k)) = [];
        
        %get samples of current seg
        seg_temp = seg_temp(:);
        seg_samps = feat(logical(seg_temp),:);
        samps_size = size(seg_samps,1);
        
        for kk = 1:length(seg_nbrhd)
            %get neighbor samps
            nbr_mask = input_mask==seg_nbrhd(kk);
            nbr_mask = nbr_mask(:);
            nbr_samps = feat(logical(nbr_mask),:);
            nbr_size = size(nbr_samps,1);
            
            %get scaling for matrix
            if par.scalingFactor
                scalingFactor = (mrows*ncols)/(nbr_size+samps_size);
            else
                scalingFactor = 1;
            end
            
            %make each superpixel same size
            if samps_size>nbr_size
                samplesize = nbr_size;
                seg_samps_temp = datasample(seg_samps,samplesize);
                nbr_samps_temp = nbr_samps;
            elseif samps_size<nbr_size
                samplesize = samps_size;
                nbr_samps_temp = datasample(nbr_samps,samplesize);
                seg_samps_temp = seg_samps;
            end
            
           if strcmp(par.method,'Mean')
                M1 = median(seg_samps_temp,1);
                M2 = median(nbr_samps_temp,1);
                distM = sqrt((M1-M2)*(M1-M2)');
                simMat(k,seg_nbrhd(kk)) = abs(distM+eps)/scalingFactor;
            elseif strcmp(par.method,'Median')
                %sim matrix based on energy distance
                M1 = median(seg_samps_temp,1);
                M2 = median(nbr_samps_temp,1);
                
                distM = sqrt((M1-M2)*(M1-M2)');
                simMat(k,seg_nbrhd(kk)) = abs(distM+eps)/scalingFactor;
            elseif strcmp(par.method,'Nearest')
                %sim matrix based on energy distance
                D2 = pdist2(seg_samps_temp,nbr_samps_temp);
                simMat(k,seg_nbrhd(kk)) = abs(min(D2(:))+eps)/scalingFactor;
            end
        end
    end
    if strcmp(par.comp,'Div')||strcmp(par.comp,'Mean')||strcmp(par.comp,'Median')||strcmp(par.comp,'Nearest')
        simMat(simMat==0)=inf;
    end
end
end
