clear all;

video = mmreader('d.mpg');
tic 
nFrames =video.NumberOfFrames;
hiz=1;
limit=nFrames/hiz;



for k = 1:hiz:nFrames
    ex = read(video,k);
    ch = int16(k/hiz)+1;
    rm(:,:,:,ch) = ex(:,:,:);
end;



tic
arkaplan = rm(:,:,:,5);
disk1 = strel('disk',2); 
disk2 = strel('square',9);
disk3 = strel('disk',6); 
disari_cikan=0;
iceri_giren=0;
binen=0;
a1=60;
a2=255;
a3=40;
List=[];

for u =1:2:nFrames
    
    curBW=0; 
    for j=1:2 
        k=u+j-1;
        bw3=0;
        subs3=0;
        curRGB = rm(:,:,:, k);
        
        for i=1:3
            C=curRGB(:,:,i);
            subs=imabsdiff(arkaplan(:,:,i),C);
            subs3=subs3+subs;
            bw=subs>100; 
            bw=imclose(bw,disk1);
            bw3=bw3+bw; 
        end
        bw3=(bw3~=0);
        bw3=imclose(bw3,disk3);
        bw3=imopen(bw3,disk2);
        curBW=curBW+bw3; 
        curBW=(curBW~=0);
    end
    
    curBW(:,(100:75))=0; 
    %figure(2),imshow(curBW);
    
   
    
    [r,c] = size(List);
    [L,n] = bwlabel(curBW);    
    
    for i=1:n
        [row,col]=find(L==i);
        if size(row)<1000
            curBW=curBW-(L==i);
        end
    end
    [L,n] = bwlabel(curBW);
    
    i=1;
    while i<=c
        o=List(i);
        x=o.posX+o.hizX;
        y=o.posY+o.hizY;
        [buldumu,yeniX,yeniY] = search(curBW,floor(x),floor(y));
        if buldumu==1
            [rows,cols] = find (L==L(yeniX,yeniY));
            merX=ceil(mean(rows));
            merY=ceil(mean(cols));
            
            if o.giris==1 && merY>a1
                iceri_giren=iceri_giren+1;
                o.giris=2;
            elseif o.giris==2 && merY<a1
                    disari_cikan=disari_cikan+1;
                    o.giris=1;
            elseif o.giris==2 && merY>a2
                    disari_cikan=disari_cikan+1;
                    o.giris=3;
            elseif o.giris==3 && merY<a2
                    iceri_giren=iceri_giren+1;
                    o.giris=2;
           elseif o.giris==4 && merX>a3
                    iceri_giren=iceri_giren+1;
                    o.giris=2;
           elseif o.giris==2 && merX<a3
               binen = binen+1;
               disari_cikan=disari_cikan+1;
                    o.giris=4;
            end
            
            object = struct('posX',merX,'posY',merY,'hizX',merX-o.posX,'hizY',merY-o.posY,'giris',o.giris,'matris',(L==L(yeniX,yeniY)));
            List(i)=object;
            o=object;
            curBW=curBW-object.matris;
            
            
        else
           if o.giris==1 && o.posY>a1
                iceri_giren=iceri_giren+1;
                o.giris=2;
            elseif o.giris==2 && o.posY<a1
                    disari_cikan=disari_cikan+1;
                    o.giris=1;
            elseif o.giris==2 && o.posY>a2
                    disari_cikan=disari_cikan+1;
                    o.giris=3;
            elseif o.giris==3 && o.posY<a2
                    iceri_giren=iceri_giren+1;
                    o.giris=2;
           elseif o.giris==4 && o.posX>a3
               iceri_giren=iceri_giren+1;
                    o.giris=2;
           elseif o.giris==2 && o.posX<a3
               binen = binen+1;
               disari_cikan=disari_cikan+1;
                    o.giris=4;
            end
            
            List(i)=[];
            c=c-1;
        end
        i=i+1;
    end
    
       
    [L,n] = bwlabel(curBW); 
    
    for i=1:n
        [r,c]=find(L==i);
      if length(r) > 1500
        x=ceil(mean(r));
        y=ceil(mean(c));
        objmatrix=(L==i);
        
            if y<a1  
                giris=1;   
            elseif y>a1 && y<a2 && x>a3   
                giris=2;
            elseif y>a2
                giris=3;
            elseif x<a3
                giris=4;
            end
            object = struct('posX',x,'posY',y,'hizX',0,'hizY',0,'giris',giris,'matris',objmatrix);
            List = [List object]; 
      end
    end
    
    [row,col] = size(List);
    
       

 
    for i=1:col
       o=List(i);
        curBW(o.posX,o.posY)=1;
       curRGB((o.posX-3:o.posX+3),(o.posY-3:o.posY+3),1)=0;
       curRGB((o.posX-3:o.posX+3),(o.posY-3:o.posY+3),2)=255;
        curRGB((o.posX-3:o.posX+3),(o.posY-3:o.posY+3),3)=0;
    end
    
    curRGB(:,a1,3)=255;
    curRGB(:,a1,2)=0;
    curRGB(:,a1,1)=0;
    
    curRGB(:,a2,3)=255;
    curRGB(:,a2,2)=0;
    curRGB(:,a2,1)=0;
    
    curRGB(a3,:,3)=255;
    curRGB(a3,:,2)=0;
    curRGB(a3,:,1)=0;
    
    durak=iceri_giren-disari_cikan;
    if durak<0
        durak=0;
    end
    
    figure(1),text(65,220,strcat('Otobuse Binen:',int2str(binen)),'color','black','fontsize',11,'fontweight','bold');
    %figure(1),text(5,134,strcat('Dışarı Çıkan:',int2str(disari_cikan)),'color','black','fontsize',11,'fontweight','bold');
    %figure(1),text(5,155,strcat('içeri Giren:',int2str(iceri_giren)),'color','black','fontsize',11,'fontweight','bold');
    figure(1),text(200,220,strcat('Durak:',int2str(durak)),'color','black','fontsize',11,'fontweight','bold');
    figure(1),imshow(curRGB);

    
end


toc
















clear all;

video = mmreader('d.mpg');
tic 
nFrames =video.NumberOfFrames;
hiz=1;
limit=nFrames/hiz;



for k = 1:hiz:nFrames
    ex = read(video,k);
    ch = int16(k/hiz)+1;
    rm(:,:,:,ch) = ex(:,:,:);
end;



tic
arkaplan = rm(:,:,:,5);
disk1 = strel('disk',2); 
disk2 = strel('square',9);
disk3 = strel('disk',6); 
disari_cikan=0;
iceri_giren=0;
binen=0;
a1=60;
a2=255;
a3=40;
List=[];

for u =1:2:nFrames
    
    curBW=0; 
    for j=1:2 
        k=u+j-1;
        bw3=0;
        subs3=0;
        curRGB = rm(:,:,:, k);
        
        for i=1:3
            C=curRGB(:,:,i);
            subs=imabsdiff(arkaplan(:,:,i),C);
            subs3=subs3+subs;
            bw=subs>100; 
            bw=imclose(bw,disk1);
            bw3=bw3+bw; 
        end
        bw3=(bw3~=0);
        bw3=imclose(bw3,disk3);
        bw3=imopen(bw3,disk2);
        curBW=curBW+bw3; 
        curBW=(curBW~=0);
    end
    
    curBW(:,(100:75))=0; 
    %figure(2),imshow(curBW);
    
   
    
    [r,c] = size(List);
    [L,n] = bwlabel(curBW);    
    
    for i=1:n
        [row,col]=find(L==i);
        if size(row)<1000
            curBW=curBW-(L==i);
        end
    end
    [L,n] = bwlabel(curBW);
    
    i=1;
    while i<=c
        o=List(i);
        x=o.posX+o.hizX;
        y=o.posY+o.hizY;
        [buldumu,yeniX,yeniY] = search(curBW,floor(x),floor(y));
        if buldumu==1
            [rows,cols] = find (L==L(yeniX,yeniY));
            merX=ceil(mean(rows));
            merY=ceil(mean(cols));
            
            if o.giris==1 && merY>a1
                iceri_giren=iceri_giren+1;
                o.giris=2;
            elseif o.giris==2 && merY<a1
                    disari_cikan=disari_cikan+1;
                    o.giris=1;
            elseif o.giris==2 && merY>a2
                    disari_cikan=disari_cikan+1;
                    o.giris=3;
            elseif o.giris==3 && merY<a2
                    iceri_giren=iceri_giren+1;
                    o.giris=2;
           elseif o.giris==4 && merX>a3
                    iceri_giren=iceri_giren+1;
                    o.giris=2;
           elseif o.giris==2 && merX<a3
               binen = binen+1;
               disari_cikan=disari_cikan+1;
                    o.giris=4;
            end
            
            object = struct('posX',merX,'posY',merY,'hizX',merX-o.posX,'hizY',merY-o.posY,'giris',o.giris,'matris',(L==L(yeniX,yeniY)));
            List(i)=object;
            o=object;
            curBW=curBW-object.matris;
            
            
        else
           if o.giris==1 && o.posY>a1
                iceri_giren=iceri_giren+1;
                o.giris=2;
            elseif o.giris==2 && o.posY<a1
                    disari_cikan=disari_cikan+1;
                    o.giris=1;
            elseif o.giris==2 && o.posY>a2
                    disari_cikan=disari_cikan+1;
                    o.giris=3;
            elseif o.giris==3 && o.posY<a2
                    iceri_giren=iceri_giren+1;
                    o.giris=2;
           elseif o.giris==4 && o.posX>a3
               iceri_giren=iceri_giren+1;
                    o.giris=2;
           elseif o.giris==2 && o.posX<a3
               binen = binen+1;
               disari_cikan=disari_cikan+1;
                    o.giris=4;
            end
            
            List(i)=[];
            c=c-1;
        end
        i=i+1;
    end
    
       
    [L,n] = bwlabel(curBW); 
    
    for i=1:n
        [r,c]=find(L==i);
      if length(r) > 1500
        x=ceil(mean(r));
        y=ceil(mean(c));
        objmatrix=(L==i);
        
            if y<a1  
                giris=1;   
            elseif y>a1 && y<a2 && x>a3   
                giris=2;
            elseif y>a2
                giris=3;
            elseif x<a3
                giris=4;
            end
            object = struct('posX',x,'posY',y,'hizX',0,'hizY',0,'giris',giris,'matris',objmatrix);
            List = [List object]; 
      end
    end
    
    [row,col] = size(List);
    
       

 
    for i=1:col
       o=List(i);
        curBW(o.posX,o.posY)=1;
       curRGB((o.posX-3:o.posX+3),(o.posY-3:o.posY+3),1)=0;
       curRGB((o.posX-3:o.posX+3),(o.posY-3:o.posY+3),2)=255;
        curRGB((o.posX-3:o.posX+3),(o.posY-3:o.posY+3),3)=0;
    end
    
    curRGB(:,a1,3)=255;
    curRGB(:,a1,2)=0;
    curRGB(:,a1,1)=0;
    
    curRGB(:,a2,3)=255;
    curRGB(:,a2,2)=0;
    curRGB(:,a2,1)=0;
    
    curRGB(a3,:,3)=255;
    curRGB(a3,:,2)=0;
    curRGB(a3,:,1)=0;
    
    durak=iceri_giren-disari_cikan;
    if durak<0
        durak=0;
    end
    
    figure(1),text(65,220,strcat('Otobuse Binen:',int2str(binen)),'color','black','fontsize',11,'fontweight','bold');
    %figure(1),text(5,134,strcat('Dışarı Çıkan:',int2str(disari_cikan)),'color','black','fontsize',11,'fontweight','bold');
    %figure(1),text(5,155,strcat('içeri Giren:',int2str(iceri_giren)),'color','black','fontsize',11,'fontweight','bold');
    figure(1),text(200,220,strcat('Durak:',int2str(durak)),'color','black','fontsize',11,'fontweight','bold');
    figure(1),imshow(curRGB);

    
end


toc















