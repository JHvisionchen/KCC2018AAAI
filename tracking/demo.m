%   KCC: Kernel Cross-Correlator
%   Visual Tracking Using KCC
    clc;
    clear;
    addpath('./utility');
    %% Read params.txt
    params = readParams('params.txt');
    base_path = 'D:\tracking\OTB100';
    video = choose_video(base_path);
    [img_files, pos, target_sz, ground_truth, video_path] = load_video_info(base_path, video);
    for i=1:length(img_files),
        img_files{i} = [video_path img_files{i}];
    end
    params.img_files = img_files;
    params.img_path = '';

    im = imread(img_files{1});
    % grayscale sequence? --> use 1D instead of 3D histograms
    if(size(im,3)==1)
        params.grayscale_sequence = true;
    end
    region = [pos([2,1]) - target_sz([2,1])/2, target_sz([2,1])];% seq.init_rect;
    if(numel(region)==8)
        % polygon format (VOT14, VOT15)
        [cx, cy, w, h] = getAxisAlignedBB(region);
    else % rectangle format (WuCVPR13)
        x = region(1);
        y = region(2);
        w = region(3);
        h = region(4);
        cx = x+w/2;
        cy = y+h/2;
    end
    % init_pos is the centre of the initial bounding box
    params.init_pos = [cy cx];
    params.target_sz = round([h w]);
    [params, bg_area, fg_area, area_resize_factor] = initializeAllAreas(im, params);
	% in runTracker we do not output anything because it is just for debug
	params.fout = -1;
	% start the actual tracking
	results = trackerMain_otb_wangchen(params, im, bg_area, fg_area, area_resize_factor);
    fclose('all');