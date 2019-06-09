clear;
clc
close all

imagesize = [512,512];  % imagesize, Hiehgt x Width
threshold = 0.05; % define >50kPa as singular points and delete
%thresholdPFE = 1;
limits_modu = [0,threshold]; % colorbar limits of modulus
%limits_PFE= [0,thresholdPFE]; % colorbar limits of modulus

file_out = 'result.out'; % result file name 
datafile = 'data.out';
flist = dir('*.txt');
fname = {flist.name}; % get *.txt file names
N = length(fname);
[X,Y] = meshgrid(0:imagesize(1)-1,0:imagesize(2)-1);

fid = fopen(file_out,'a');

mkdir('./redraw2');
subfolder = './redraw2/';
for i = 1 : N % for testing , set N to 1
    % import data one by one
    data = importdata(fname{i});
    data = data.data;
    % store height and modulus
    height = reshape(data(:,1),imagesize);
    height = height';
    height = height(end:-1:1,:);% filp up and down
    modu = reshape(data(:,3),imagesize);
    modu = modu';
    modu = modu(end:-1:1,:);
    pfErr = reshape(data(:,2),imagesize);% peak force error
    pfErr = pfErr';
    pfErr = pfErr(end:-1:1,:);

    % show image
    subplot(1,3,1); imagesc(height);colorbar;axis square;hold on
    subplot(1,3,2); imagesc(modu);colorbar;caxis(limits_modu);axis square;hold on
    subplot(1,3,3); imagesc(pfErr);colorbar;axis square;hold on
    %subplot(1,3,3); imagesc(pfErr);colorbar;caxis(limits_PFE);axis square;hold on
    % left click to get first point and show
    set(gcf,'Position',[6.7143 594.7143 1.5034e+03 560.5714]);
    x=[];y=[];
    button = 1; 
    n = 0;
    pn = 0; % cell point numbers [n1 n2 n3...]
    isfirst = 1; % if it is this the first point
    while button ~= 0 
        [x,y,button,n,pn,isfirst]=getpoints(x,y,n,pn,isfirst);
    end
    cxyId = fopen([fname{i}(1:end-4),'.cxy'],'a'); % cell x y 
    
for k = 1 : length(pn)-1
    xn = x( sum(pn(1:k))+1 : sum(pn(1:k+1)) );
    yn = y( sum(pn(1:k))+1 : sum(pn(1:k+1)) );
    % mark cell
    text(mean(xn),mean(yn),['cell ',num2str(k)])
    % create roi
    roi = inpolygon(X,Y,xn,yn);
    roi(modu>threshold) = 0; % delete singular points 
    % calculate mean values in roi
    mean_h = mean(height(roi));
    mean_modu = mean(modu(roi));
    % add results to file
    modu_out = modu(roi);
    modu_data{1,k} = modu_out(:)*1000;
    Len(k) = length(modu_data{1,k});
    fprintf(fid,'%s %s %-6.2e %-6.2e\n',fname{i}(1:end-4),['cell_',num2str(k)],mean_h,mean_modu);
    fprintf(cxyId,['%s ',repmat('%-8.3f ',1,pn(k+1)),'\n'],['cell_',num2str(k),'_x'],xn);
    fprintf(cxyId,['%s ',repmat('%-8.3f ',1,pn(k+1)),'\n'],['cell_',num2str(k),'_y'],yn);
end
modu_out = nan(max(Len),k);
for t = 1:k 
    modu_out(1:Len(t),t) =  modu_data{1,t};
end
   dlmwrite(datafile,modu_out);
    fclose(cxyId);
    saveas(gcf,[fname{i}(1:end-4),'.png']);
    close;
    
    imagesc(height);axis square;axis off;f=getframe;imwrite(f.cdata,[subfolder,fname{i}(1:end-4),'_h.png']);
    imagesc(modu);axis square;axis off;caxis(limits_modu);f=getframe;imwrite(f.cdata,[subfolder,fname{i}(1:end-4),'_m.png']);
    imagesc(pfErr);axis square;axis off;f=getframe;imwrite(f.cdata,[subfolder,fname{i}(1:end-4),'_t.png']);
    %imagesc(pfErr);axis square;axis off;caxis(limits_PFE);f=getframe;imwrite(f.cdata,[subfolder,fname{i}(1:end-4),'_t.png']);

    
    disp(fname{i})
    pause(0.01); % pause 0.01 seconds
end
fclose all;
close all
disp('finished')
disp(['totally ',num2str(i),' files'])