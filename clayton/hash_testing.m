%% This section tests the byte_XOR function
tic
%lets test for 64-bit words
trials = 100000;
%hash_length = 8;

collisions = 0;
for k=1:trials
    word1 = randi([0 1],1,64);
    err_loc = randperm(64,4);
    err_vec = zeros(1,64);
    err_vec(err_loc)=1;
    word2 = mod(word1+err_vec,2);
    hash1 = byte_XOR(word1);
    hash2 = byte_XOR(word2);
    if isequal(hash1,hash2)
        collisions = collisions+1;
    end
end

collision_prob = collisions/trials
disp('The collision_prob should be 1/256 = 0.0039')
toc

%% Test the random hash
tic
%lets test for 64-bit words
trials = 100000;
%hash_length = 8;

collisions = 0;
for k=1:trials
    word1 = randi([0 1],1,64);
    err_loc = randperm(64,4);
    err_vec = zeros(1,64);
    err_vec(err_loc)=1;
    word2 = mod(word1+err_vec,2);
    hash1 = random_hash(word1);
    hash2 = random_hash(word2);
    if isequal(hash1,hash2)
        collisions = collisions+1;
    end
end

collision_prob = collisions/trials
disp('The collision_prob should be 1/256 = 0.0039')
toc

%% Test the random hash 3
tic
%lets test for 64-bit words
trials = 100000;
%hash_length = 8;

collisions = 0;
for k=1:trials
    word1 = randi([0 1],1,64);
    err_loc = randperm(64,4);
    err_vec = zeros(1,64);
    err_vec(err_loc)=1;
    word2 = mod(word1+err_vec,2);
    hash1 = random_hash_3(word1);
    hash2 = random_hash_3(word2);
    if isequal(hash1,hash2)
        collisions = collisions+1;
    end
end

collision_prob = collisions/trials
disp('The collision_prob should be 1/256 = 0.0039')
toc

%% Test the random hash 4
tic
%lets test for 64-bit words
trials = 100000;
%hash_length = 8;

collisions = 0;
for k=1:trials
    word1 = randi([0 1],1,64);
    err_loc = randperm(64,4);
    err_vec = zeros(1,64);
    err_vec(err_loc)=1;
    word2 = mod(word1+err_vec,2);
    hash1 = random_hash_4(word1);
    hash2 = random_hash_4(word2);
    if isequal(hash1,hash2)
        collisions = collisions+1;
    end
end

collision_prob = collisions/trials
disp('The collision_prob should be 1/256 = 0.0039')
toc