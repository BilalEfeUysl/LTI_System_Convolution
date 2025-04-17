clc; clear; close all;

%% === 1. SORU ===
myConv = @(x, nx, h, nh) ...
    deal(... 
        conv_custom(x, h), ...
        (nx(1) + nh(1)):(nx(end) + nh(end)) ...
    );

function y = conv_custom(x, h)
    N1 = length(x);
    N2 = length(h);
    Ny = N1 + N2 - 1;
    x = [x, zeros(1, N2)];
    h = [h, zeros(1, N1)];
    y = zeros(1, Ny);
    for n = 1:Ny
        for k = 1:n
            y(n) = y(n) + x(k) * h(n - k + 1);
        end
    end
end

%% === 2. SORU ===
disp('============================');
disp('--- Konvolüsyon Karşılaştırması ---');
disp('============================');

x = [3 5 8 2 11 6]; nx = -2:3;
h = [4 7 6 3 5]; nh = -1:3;

tic;
[my_y, ny] = myConv(x, nx, h, nh);
myconv_time = toc;

tic;
y_builtin = conv(x, h);
conv_time = toc;

figure('Name','Konvolüsyon Karşılaştırması','NumberTitle','off');
subplot(2,2,1); stem(nx, x, 'filled','MarkerSize',4, 'LineWidth', 1.5); 
title('Giriş Sinyali x[n]'); grid on; xlabel('n'); ylabel('x[n]');

subplot(2,2,2); stem(nh, h, 'filled','MarkerSize',4, 'LineWidth', 1.5); 
title('Giriş Sinyali y[n]'); grid on; xlabel('n'); ylabel('y[n]');

subplot(2,2,3); stem(ny, my_y, 'r','filled','LineWidth', 1.5); 
title(sprintf('myConv(x,y)')); 
grid on; xlabel('n'); ylabel('Sonuç');

subplot(2,2,4); stem(ny, y_builtin, 'g','filled','LineWidth', 1.5); 
title(sprintf('conv(x,y)')); 
grid on; xlabel('n'); ylabel('Sonuç');

sgtitle('📊 Fonksiyonlarla Konvolüsyon Sonuçları');

disp('x[n] ='); disp(x);
disp('y[n] ='); disp(h);
disp('myConv(x,y) ='); disp(my_y);
disp('conv(x,y) ='); disp(y_builtin);

input('\nGrafikleri incelediyseniz devam etmek için ENTER''a basın...\n');

%% === 3. SORU ===
disp('============================');
disp('--- Ses Kaydı ---');
disp('============================');

Fs = 8000; 

input('🎙️ 5 saniyelik kayıt başlatmak için ENTER''a basın...');
recObj1 = audiorecorder(Fs, 16, 1);
disp('🔴 Kayıt başladı (5 saniye)...');
tic;
recordblocking(recObj1, 5);
duration5 = toc;
X1 = getaudiodata(recObj1);
disp('✅ Kayıt tamamlandı (X1)');
input('Devam etmek için ENTER''a basın...\n');

input('🎙️ 10 saniyelik kayıt başlatmak için ENTER''a basın...');
recObj2 = audiorecorder(Fs, 16, 1);
disp('🔴 Kayıt başladı (10 saniye)...');
tic;
recordblocking(recObj2, 10);
duration10 = toc;
X2 = getaudiodata(recObj2);
disp('✅ Kayıt tamamlandı (X2)');
input('Devam etmek için ENTER''a basın...\n');

%% === 4. SORU ===
disp('============================');
disp('--- Sistem Uygulaması ve Dinletme ---');
disp('============================');

A = 0.5;

% Önce sadece orijinal sesler dinletiliyor
disp('🔊 Önce orijinal sesler dinletilecek (X1 ve X2):');
input('🎧 X1 (5 sn) sesini dinlemek için ENTER''a basın...');
sound(X1, Fs); pause(length(X1)/Fs + 1);

input('🎧 X2 (10 sn) sesini dinlemek için ENTER''a basın...');
sound(X2, Fs); pause(length(X2)/Fs + 1);

for M = 3:5
    disp('----------------------------------------');
    fprintf('⚙️  M = %d için sistem işlemine başlanıyor...\n', M);
    disp('----------------------------------------');

    h_length = 400 * M + 1;
    h = zeros(1, h_length);
    h(1) = 1;  % delta[n]
    for k = 1:M
        h(400 * k + 1) = A * k;
    end
    nh = 0:length(h)-1;

    %% X1 İşlemi
    x1 = X1'; nx1 = 0:length(x1)-1;

    fprintf('🔁 X1 için myConv uygulanıyor...\n');
    tic;
    [myY1, ny1] = myConv(x1, nx1, h, nh);
    t_myY1 = toc;

    fprintf('🔁 X1 için conv() uygulanıyor...\n');
    tic;
    Y1 = conv(x1, h);
    t_Y1 = toc;

    fprintf('✅ myConv süresi: %.2f s, conv() süresi: %.2f s\n', t_myY1, t_Y1);

    input(sprintf('🔊 X1 (myConv sonucu) dinlemek için ENTER''a basın [M=%d]...\n', M));
    sound(myY1, Fs); pause(length(myY1)/Fs + 1);

    input(sprintf('🔊 X1 (conv sonucu) dinlemek için ENTER''a basın [M=%d]...\n', M));
    sound(Y1, Fs); pause(length(Y1)/Fs + 1);

    %% X2 İşlemi
    x2 = X2'; nx2 = 0:length(x2)-1;

    fprintf('🔁 X2 için myConv uygulanıyor...\n');
    tic;
    [myY2, ny2] = myConv(x2, nx2, h, nh);
    t_myY2 = toc;

    fprintf('🔁 X2 için conv() uygulanıyor...\n');
    tic;
    Y2 = conv(x2, h);
    t_Y2 = toc;

    fprintf('✅ myConv süresi: %.2f s, conv() süresi: %.2f s\n', t_myY2, t_Y2);

    input(sprintf('🔊 X2 (myConv sonucu) dinlemek için ENTER''a basın [M=%d]...\n', M));
    sound(myY2, Fs); pause(length(myY2)/Fs + 1);

    input(sprintf('🔊 X2 (conv sonucu) dinlemek için ENTER''a basın [M=%d]...\n', M));
    sound(Y2, Fs); pause(length(Y2)/Fs + 1);
end

disp('============================');
disp('✅ Tüm işlemler başarıyla tamamlandı!');
