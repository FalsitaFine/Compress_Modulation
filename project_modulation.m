disp("EE5505 Project");

%% Extracting useful data
clear all;
EbNo = 9;


load('T10.dat');
figure(1);
title("Original Data");
plot(T10(:,2));


ext_index = 1;
ext_ptr = [];
ext_flag = 0;
dat_p = T10(:,2);

decr_flag = 0;

%ext_flag = 1: in extract progress
%decr_flag = 0: 
for i = 2:size(T10,1)
    if dat_p(i) > 300
        if ext_flag == 0
            ext_flag = 1;
            ext_ptr(ext_index)=i;
            ext_index = ext_index+1;
        else
            
            if decr_flag == 1 && dat_p(i)>dat_p(i-1)
                ext_ptr(ext_index) = i;
                ext_index = ext_index+1;
                ext_flag = 0;
                decr_flag = 0;
            end

            if dat_p(i)<dat_p(i-1)
                decr_flag = 1;
            end
        end
    else
        if ext_flag == 1
        ext_ptr(ext_index) = i;
        ext_index = ext_index+1;
        ext_flag = 0;
        end
    end
end
Total_length = 0;
ext_data = [[]];
ext_data_index = 1;
figure(2);
title("Extracted Data");

hold on;
for i = 1:2:ext_index-2
    if ext_ptr(i+1) - ext_ptr(i) > 128 
    plot(dat_p(ext_ptr(i):ext_ptr(i+1)));
    %ext_data(:,ext_data_index) = [dat_p(ext_ptr(i):ext_ptr(i+1))];
    if ext_data_index == 2
        input_data = dat_p(ext_ptr(i):ext_ptr(i+1));
    end
    Total_length = Total_length + (ext_ptr(i+1) - ext_ptr(i));
    ext_data_index = ext_data_index + 1;
    end
end
hold off;

input_len = size(input_data,1);



%% Generating sample data

%load('T10.dat');
%y = abs(T10(1:100,2));
y = input_data;
input_len = size(y,1);

%% Modulate
ymax = max(y);
ymin = min(y);
y_range = ymax-ymin;
Mbit = ceil(log2(y_range));
y = y - ymin;

%16-QAM
M = 16
k = 4
numSamplesPerSymbol = 1;


% Translate into Binary
y_bi = de2bi(y,Mbit+2);

index = 1;
while(index < 5)
    y_split(:,index) = bi2de(y_bi(:,index*4-3:index*4));
    index = index + 1;
end

%Test_data = [6,8,10,11,12,5,4,3];
data_modl = qammod(y_split, M,'bin');


%snr = EbNo + 10*log10(k) - 10*log10(numSamplesPerSymbol);
snr = 15;
receivedSignal = awgn(data_modl,snr,'measured');
%receivedSignal = data_modl;
figure(4)
title("Curve#2, 16QAM, Raw");

hold on;
%plot(receivedSignal(1),'o')
total_size = 0;
for i = 1: input_len
    total_size = total_size + abs(y(i));
    for j = 1 : 3
%sPlotFig = scatterplot(receivedSignal(i),1,0,'g.');
plot(receivedSignal(i,j),'o')
    end
end
%hold on
%scatterplot(data_modl,1,0,'k*',sPlotFig)
hold off;


%Demod
figure(5);
title("Curve#2, 16QAM, Raw, Recieved");

demodSignal = qamdemod(receivedSignal, M,'bin');
%plot(dataSymbolsOut)
for i = 1: size(demodSignal(:,1))
    
index = 1;
while(index < 5)
    regeneratedSignal_b(i,index*4-3:index*4) = de2bi(demodSignal(i,index),4);
    index = index + 1;
end

    regeneratedSignal(i) = bi2de(regeneratedSignal_b(i,:));
end
hold on;

plot(regeneratedSignal)
plot(y)
%hold off;

%% Bad Points Fix

for i = 3 :(size(regeneratedSignal,2)-2)
    if (regeneratedSignal(i) < regeneratedSignal(i-1)*0.85) | (regeneratedSignal(i) > regeneratedSignal(i-1) * 1.15 )
    %disp("fix!");
    regeneratedSignal(i) = (regeneratedSignal(i-2) + regeneratedSignal(i-1) + regeneratedSignal(i+1) +regeneratedSignal(i+2))/4;
    end
end
%figure(5);
plot(regeneratedSignal)
legend("Recieved Wave","Original Wave","Fixed Wave")

hold off;
err_ori = 0;
for i = 1:size(y,2)
    err_ori = err_ori + abs(regeneratedSignal(i)-y(i));
end
disp("err of direct transmit:");
disp(err_ori);

%% With Sampling
sample_arg = 2;
y_sampled = input_data(1:sample_arg:end);

%{
for i = 1:size(input_data)
    y_sampled_avg(i) = input_data
end

%}

input_len = size(y_sampled,1);

%% Modulate
ymax = max(y_sampled);
ymin = min(y_sampled);
y_range = ymax-ymin;
Mbit = ceil(log2(y_range));
y_sampled = y_sampled - ymin;

%16-QAM
M = 16
k = 4
numSamplesPerSymbol = 1;


% Translate into Binary
y_bi = de2bi(y_sampled,Mbit+2);

index = 1;
while(index < 5)
    y_sampled_split(:,index) = bi2de(y_bi(:,index*4-3:index*4));
    index = index + 1;
end

%Test_data = [6,8,10,11,12,5,4,3];
data_modl = qammod(y_sampled_split, M,'bin');


snr = EbNo + 10*log10(k) - 10*log10(numSamplesPerSymbol);

receivedSignal = awgn(data_modl,snr,'measured');
%receivedSignal = data_modl;
figure(6)
title("Curve#2, 16QAM, Sampled");

hold on;
%plot(receivedSignal(1),'o')

for i = 1: input_len
    for j = 1 : 3
%sPlotFig = scatterplot(receivedSignal(i),1,0,'g.');
plot(receivedSignal(i,j),'o')
    end
end
%hold on
%scatterplot(data_modl,1,0,'k*',sPlotFig)
hold off;


%Demod
figure(7);
title("Curve#2, 16QAM, Sampled, Recieved");

demodSignal = qamdemod(receivedSignal, M,'bin');
%plot(dataSymbolsOut)
for i = 1: size(demodSignal(:,1))
    
index = 1;
while(index < 5)
    regeneratedSignal_sampled_b(i,index*4-3:index*4) = de2bi(demodSignal(i,index),4);
    index = index + 1;
end

    regeneratedSignal_sampled(i) = bi2de(regeneratedSignal_sampled_b(i,:));
end
hold on;

plot(regeneratedSignal_sampled)
plot(y)
plot(y_sampled)

%hold off;

%% Bad Points Fix

for i = 3 :(size(regeneratedSignal_sampled,2)-2)
    if (regeneratedSignal_sampled(i) < regeneratedSignal_sampled(i-1)*0.85) | (regeneratedSignal_sampled(i) > regeneratedSignal_sampled(i-1) * 1.15 )
    %disp("fix!");
    regeneratedSignal_sampled(i) = (regeneratedSignal_sampled(i-2) + regeneratedSignal_sampled(i-1) + regeneratedSignal_sampled(i+1) +regeneratedSignal_sampled(i+2))/4;
    end
end



%% Regenerate Missing Data
for i = 1 :(size(regeneratedSignal_sampled,2)-1)
    regeneratedSignal_sampled_rebuild(i*2-1) = regeneratedSignal_sampled(i);
    regeneratedSignal_sampled_rebuild(i*2) = (regeneratedSignal_sampled(i)+regeneratedSignal_sampled(i+1))/2;

end

%figure(5);
plot(regeneratedSignal_sampled_rebuild)
legend("Recieved Wave","Original Wave","Sampled Wave","Fixed Wave")
err_sampling = 0;
for i = 1:size(y,2)
    err_sampling = err_sampling + abs(regeneratedSignal_sampled_rebuild(i)-y(i));
end
disp("err of sampling approach:")
disp(err_sampling);

%% With Resolution Compressed
resolution_unit = 32;
y_compressed = input_data;
input_len = size(y_compressed,1);

%% Modulate
ymax = max(y_compressed);
ymin = min(y_compressed);
y_range = ceil((ymax-ymin)/resolution_unit);
Mbit = ceil(log2(y_range));
y_compressed = y_compressed - ymin;

y_compressed = ceil(y_compressed/resolution_unit);

%16-QAM
M_c = 16
k = 4
numSamplesPerSymbol = 1;


% Translate into Binary
y_bi = de2bi(y_compressed,Mbit+3);

index = 1;
while(index < 4)
    y_compressed_split(:,index) = bi2de(y_bi(:,index*4-3:index*4));
    index = index + 1;
end

%Test_data = [6,8,10,11,12,5,4,3];
data_modl_c = qammod(y_compressed_split, M_c,'bin');


snr = EbNo + 10*log10(k) - 10*log10(numSamplesPerSymbol);

receivedSignal = awgn(data_modl_c,snr,'measured');
%receivedSignal = data_modl;
figure(8)
title("Curve#2, 16QAM, Re-Coded");

hold on;
%plot(receivedSignal(1),'o')

for i = 1: input_len
    for j = 1 : 3
%sPlotFig = scatterplot(receivedSignal(i),1,0,'g.');
plot(receivedSignal(i,j),'o')
    end
end
%hold on
%scatterplot(data_modl,1,0,'k*',sPlotFig)
hold off;


%Demod
figure(9);
title("Curve#2, 16QAM, Re-Coded, Recieved");

demodSignal_c = qamdemod(receivedSignal, M_c,'bin');
%plot(dataSymbolsOut)
for i = 1: size(demodSignal_c(:,1))
    
index = 1;
while(index < 4)
    regeneratedSignal_compressed_b(i,index*4-3:index*4) = de2bi(demodSignal_c(i,index),4);
    index = index + 1;
end

    regeneratedSignal_compressed(i) = bi2de(regeneratedSignal_compressed_b(i,:));
end
hold on;

plot(regeneratedSignal_compressed*resolution_unit)
plot(y)
%hold off;

%% Bad Points Fix

for i = 3 :(size(regeneratedSignal_compressed,2)-2)
    if (regeneratedSignal_compressed(i) < regeneratedSignal_compressed(i-1)*0.85) | (regeneratedSignal_compressed(i) > regeneratedSignal_compressed(i-1) * 1.15 )
    %disp("fix!");
    regeneratedSignal_compressed(i) = (regeneratedSignal_compressed(i-2) + regeneratedSignal_compressed(i-1) + regeneratedSignal_compressed(i+1) +regeneratedSignal_compressed(i+2))/4;
    end
end
%figure(5);
plot(regeneratedSignal_compressed*resolution_unit)
legend("Recieved Wave","Original Wave","Fixed Wave")

hold off;



%% With Resolution Compressed, 8-QAM
resolution_unit = 32;
y_compressed = input_data;
input_len = size(y_compressed,1);

%% Modulate
ymax = max(y_compressed);
ymin = min(y_compressed);
y_range = ceil((ymax-ymin)/resolution_unit);
Mbit = ceil(log2(y_range));
y_compressed = y_compressed - ymin;

y_compressed = ceil(y_compressed/resolution_unit);

%16-QAM
M_c = 8
k = 4
numSamplesPerSymbol = 1;


% Translate into Binary
y_bi = de2bi(y_compressed,12);

index = 1;
while(index < 5)
    y_compressed_split(:,index) = bi2de(y_bi(:,index*3-2:index*3));
    index = index + 1;
end

%Test_data = [6,8,10,11,12,5,4,3];
data_modl_c = qammod(y_compressed_split, M_c,'bin');


snr = EbNo + 10*log10(k) - 10*log10(numSamplesPerSymbol);

receivedSignal = awgn(data_modl_c,snr,'measured');
%receivedSignal = data_modl;
figure(15)
title("Curve#2, 16QAM, Re-Coded");

hold on;
%plot(receivedSignal(1),'o')

for i = 1: input_len
    for j = 1 : 3
%sPlotFig = scatterplot(receivedSignal(i),1,0,'g.');
plot(receivedSignal(i,j),'o')
    end
end
%hold on
%scatterplot(data_modl,1,0,'k*',sPlotFig)
hold off;


%Demod
figure(16);
title("Curve#2, 8QAM, Re-Coded, Recieved");

demodSignal_c = qamdemod(receivedSignal, M_c,'bin');
%plot(dataSymbolsOut)
for i = 1: size(demodSignal_c(:,1))
    
index = 1;
while(index < 4)
    regeneratedSignal_compressed_b(i,index*3-2:index*3) = de2bi(demodSignal_c(i,index),3);
    index = index + 1;
end

    regeneratedSignal_compressed(i) = bi2de(regeneratedSignal_compressed_b(i,:));
end
hold on;

plot(regeneratedSignal_compressed*resolution_unit)
plot(y)
%hold off;

%% Bad Points Fix

for i = 3 :(size(regeneratedSignal_compressed,2)-2)
    if (regeneratedSignal_compressed(i) < regeneratedSignal_compressed(i-1)*0.85) | (regeneratedSignal_compressed(i) > regeneratedSignal_compressed(i-1) * 1.15 )
    %disp("fix!");
    regeneratedSignal_compressed(i) = (regeneratedSignal_compressed(i-2) + regeneratedSignal_compressed(i-1) + regeneratedSignal_compressed(i+1) +regeneratedSignal_compressed(i+2))/4;
    end
end
%figure(5);
plot(regeneratedSignal_compressed*resolution_unit)
legend("Recieved Wave","Original Wave","Fixed Wave")

hold off;

err_red = 0;
for i = 1:size(y,2)
    err_red = err_red + abs(regeneratedSignal_compressed(i)*resolution_unit-y(i));
end
disp("err of 8QAM resolution reduce")
disp(err_red);

%% Curve Fitting 
%input_data = T10(128:1024,2);
i = 1;
j = 1;
count = 0;
num = 0;
error = 10;
a = zeros(16,1);
c = zeros(16,1);
t = zeros(16,1);
e = zeros(16,1);
flag = 0;
length_y = input_len - 4;

M = zeros(length_y-1,1);
order = 4;
itr = 0;
percent_error = 0;
while(i<size(input_data,1))
    if input_data(i)>-200
        M(j) = input_data(i);
        j = j+1;
        if j >= length_y
            j = 1;
            itr = itr+1;
            count = count+1;
            %flag = flag + 1;
            [resu(1:3),least] = curvfit(M,error,order);
            a(count) = resu(1);
            c(count) = resu(2);
            t(count) = resu(3);
            e(count) = least;
            actual = max(M);
            m = 0;
            y = zeros(length_y,1);
            
            for x = i:i+length_y
                y(i+m) = resu(1) * (((m+resu(2))/resu(3))^order) * exp(-(m+resu(2))/resu(3));
                m = m+1;
            end
            pred = max(y);
            figure(3)
            title("Curve Fitting Result");

            hold on;
            plot(y(length_y:end));
            percent_error = percent_error + ((pred-actual)/actual);
            break;
        end
    else
        j = 1;
    end
    i = i+1;
end

percent_error = percent_error/itr;
plot(input_data,'r');
ylabel('ADC Value');
xlabel('Sample Number');
legend('Curve-Fitting Result','Data');
hold off;




%2-QAM
M_f = 2
k = 4
numSamplesPerSymbol = 1;

resu_int_1 = round(resu(1));
resu_int_2 = round(resu(2)*1000);
resu_int_3 = round(resu(3)*1000);


% Translate into Binary
resu_bi_1 = de2bi(resu_int_1,16);
resu_bi_2 = de2bi(resu_int_2,16);
resu_bi_3 = de2bi(resu_int_3,16);

%index = 1;
%while(index < )
%    y_compressed_split(:,index) = bi2de(y_bi(:,index*3-2:index*3));
%    index = index + 1;
%end

%Test_data = [6,8,10,11,12,5,4,3];
data_modl_f1 = qammod(resu_bi_1, M_f,'bin');
data_modl_f2 = qammod(resu_bi_2, M_f,'bin');
data_modl_f3 = qammod(resu_bi_3, M_f,'bin');


snr = 8;

receivedSignal_1 = awgn(data_modl_f1,snr,'measured');
receivedSignal_2 = awgn(data_modl_f2,snr,'measured');
receivedSignal_3 = awgn(data_modl_f3,snr,'measured');

figure(25)
title("Curve#2, 2QAM, Curve-Fitting paras");

hold on;
%plot(receivedSignal(1),'o')

for i = 1: size(receivedSignal_1,2)
%sPlotFig = scatterplot(receivedSignal(i),1,0,'g.');
    plot(receivedSignal_1(1,i),'o')
end
for i = 1: size(receivedSignal_2,2)
%sPlotFig = scatterplot(receivedSignal(i),1,0,'g.');
    plot(receivedSignal_2(1,i),'o')
end
for i = 1: size(receivedSignal_3,2)
%sPlotFig = scatterplot(receivedSignal(i),1,0,'g.');
    plot(receivedSignal_3(1,i),'o')
end
%hold on
%scatterplot(data_modl,1,0,'k*',sPlotFig)
hold off;


%Demod
%figure(16);
%title("Curve#2, Curve-Fitting, Recieved");

demodSignal_1 = qamdemod(receivedSignal_1, M_f,'bin');
demodSignal_2 = qamdemod(receivedSignal_2, M_f,'bin');
demodSignal_3 = qamdemod(receivedSignal_3, M_f,'bin');

regen_1 = bi2de(demodSignal_1(1:end));
regen_2 = bi2de(demodSignal_2(1:end))/1000;
regen_3 = bi2de(demodSignal_3(1:end))/1000;

% Regenerating Curve
reg_curve = zeros(length_y,1);

m = 1;
for x = 1:length_y
    reg_curve(m) = regen_1 * (((m+regen_2)/regen_3)^order) * exp(-(m+regen_2)/regen_3);
    m = m+1;
end
figure(26)
            title("Curve Fitting Transfer Result");

            hold on;
            plot(reg_curve(1:end));
            plot(input_data);
            legend("Regenerating Result","Original Data");
            hold off;
err_fit = 0;
for i = 1:size(reg_curve)
    err_fit = err_fit + abs(reg_curve(i)-input_data(i));
end
disp("err of curve-fitting")
disp(err_fit);