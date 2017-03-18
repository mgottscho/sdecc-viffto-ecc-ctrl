num_policies=7;
num_codes=3;
mean_success = NaN(num_policies,num_codes);
%mean_miscorrect = NaN(num_policies,num_codes);
%mean_panic = NaN(num_policies,num_codes);

%% Entropy4 Hsiao (72,64)
policy=1;
code=1;
load('/Users/mark/Dropbox/SoftwareDefinedECC/data/rv64g/data-recovery/offline-dynamic/hsiao1970/72,64/hash-none/min-entropy4-pick-longest-run/crash-threshold-3/2017-03-16/postprocessed/postprocessed.mat','avg_benchmark_successes');%,'avg_benchmark_miscorrect','avg_benchmark_could_have_crashed');
mean_success(policy,code) = geomean(avg_benchmark_successes);
%mean_miscorrect(policy,code) = geomean(avg_benchmark_miscorrect);
%mean_panic(policy,code) = geomean(avg_benchmark_could_have_crashed);

%% Entropy4 Bose (79,64) -- TODO RUN ME
policy=1;
code=2;
load('/Users/mark/Dropbox/SoftwareDefinedECC/data/rv64g/data-recovery/offline-dynamic/bose1960/79,64/hash-none/min-entropy4-pick-longest-run/crash-threshold-3/2017-03-13/postprocessed/postprocessed.mat','avg_benchmark_successes');%,'avg_benchmark_miscorrect','avg_benchmark_could_have_crashed');
mean_success(policy,code) = geomean(avg_benchmark_successes);
%mean_miscorrect(policy,code) = geomean(avg_benchmark_miscorrect);
%mean_panic(policy,code) = geomean(avg_benchmark_could_have_crashed);

%% Entropy4 Kaneda (144,128) -- TODO RUN ME
policy=1;
code=3;
load('/Users/mark/Dropbox/SoftwareDefinedECC/data/rv64g/data-recovery/offline-dynamic/kaneda1982/144,128/hash-none/min-entropy4-pick-longest-run/crash-threshold-3/2017-03-16/postprocessed/postprocessed.mat','avg_benchmark_successes');%,'avg_benchmark_miscorrect','avg_benchmark_could_have_crashed');
mean_success(policy,code) = geomean(avg_benchmark_successes);
mean_miscorrect(policy,code) = geomean(avg_benchmark_miscorrect);
%mean_panic(policy,code) = geomean(avg_benchmark_could_have_crashed);

%% Entropy8 Hsiao (72,64)
policy=2;
code=1;
load('/Users/mark/Dropbox/SoftwareDefinedECC/data/rv64g/data-recovery/offline-dynamic/hsiao1970/72,64/hash-none/min-entropy8-pick-longest-run/crash-threshold-4.5/2017-03-15/postprocessed/postprocessed.mat','avg_benchmark_successes');%,'avg_benchmark_miscorrect','avg_benchmark_could_have_crashed');
mean_success(policy,code) = geomean(avg_benchmark_successes);
%mean_miscorrect(policy,code) = geomean(avg_benchmark_miscorrect);
%mean_panic(policy,code) = geomean(avg_benchmark_could_have_crashed);

%% Entropy8 Bose (79,64)
policy=2;
code=2;
load('/Users/mark/Dropbox/SoftwareDefinedECC/data/rv64g/data-recovery/offline-dynamic/bose1960/79,64/hash-none/min-entropy8-pick-longest-run/crash-threshold-4.5/2017-03-13/postprocessed/postprocessed.mat','avg_benchmark_successes');%,'avg_benchmark_miscorrect','avg_benchmark_could_have_crashed');
mean_success(policy,code) = geomean(avg_benchmark_successes);
%mean_miscorrect(policy,code) = geomean(avg_benchmark_miscorrect);
%mean_panic(policy,code) = geomean(avg_benchmark_could_have_crashed);

%% Entropy8 Kaneda (144,128)
policy=2;
code=3;
load('/Users/mark/Dropbox/SoftwareDefinedECC/data/rv64g/data-recovery/offline-dynamic/kaneda1982/144,128/hash-none/min-entropy8-pick-longest-run/crash-threshold-4.5/2017-03-16/postprocessed/postprocessed.mat','avg_benchmark_successes');%,'avg_benchmark_miscorrect','avg_benchmark_could_have_crashed');
mean_success(policy,code) = geomean(avg_benchmark_successes);
%mean_miscorrect(policy,code) = geomean(avg_benchmark_miscorrect);
%mean_panic(policy,code) = geomean(avg_benchmark_could_have_crashed);

%% Entropy16 Hsiao (72,64)
policy=3;
code=1;
load('/Users/mark/Dropbox/SoftwareDefinedECC/data/rv64g/data-recovery/offline-dynamic/hsiao1970/72,64/hash-none/min-entropy16-pick-longest-run/crash-threshold-3.75/2017-03-16/postprocessed/postprocessed.mat','avg_benchmark_successes');%,'avg_benchmark_miscorrect','avg_benchmark_could_have_crashed');
mean_success(policy,code) = geomean(avg_benchmark_successes);
%mean_miscorrect(policy,code) = geomean(avg_benchmark_miscorrect);
%mean_panic(policy,code) = geomean(avg_benchmark_could_have_crashed);

%% Entropy16 Bose (79,64) -- TODO RUN ME
policy=3;
code=2;
load('/Users/mark/Dropbox/SoftwareDefinedECC/data/rv64g/data-recovery/offline-dynamic/bose1960/79,64/hash-none/min-entropy16-pick-longest-run/crash-threshold-3.75/2017-03-13/postprocessed/postprocessed.mat','avg_benchmark_successes');%,'avg_benchmark_miscorrect','avg_benchmark_could_have_crashed');
mean_success(policy,code) = geomean(avg_benchmark_successes);
%mean_miscorrect(policy,code) = geomean(avg_benchmark_miscorrect);
%mean_panic(policy,code) = geomean(avg_benchmark_could_have_crashed);

%% Entropy16 Kaneda (144,128)
policy=3;
code=3;
load('/Users/mark/Dropbox/SoftwareDefinedECC/data/rv64g/data-recovery/offline-dynamic/kaneda1982/144,128/hash-none/min-entropy16-pick-longest-run/crash-threshold-3.75/2017-03-14/postprocessed/postprocessed.mat','avg_benchmark_successes');%,'avg_benchmark_miscorrect','avg_benchmark_could_have_crashed');
mean_success(policy,code) = geomean(avg_benchmark_successes);
%mean_miscorrect(policy,code) = geomean(avg_benchmark_miscorrect);
%mean_panic(policy,code) = geomean(avg_benchmark_could_have_crashed);

%% Hamming-Pick-Longest-Run Hsiao (72,64) -- TODO RUN ME (currently on
% nanocad-server-testbed)
policy=4;
code=1;
load('/Users/mark/Dropbox/SoftwareDefinedECC/data/rv64g/data-recovery/offline-dynamic/hsiao1970/72,64/hash-none/hamming-pick-longest-run/crash-threshold-0.5/2016-11-12/postprocessed/postprocessed.mat','avg_benchmark_successes');%,'avg_benchmark_miscorrect','avg_benchmark_could_have_crashed');
mean_success(policy,code) = geomean(avg_benchmark_successes);
%mean_miscorrect(policy,code) = geomean(avg_benchmark_miscorrect);
%mean_panic(policy,code) = geomean(avg_benchmark_could_have_crashed);

%% Hamming-Pick-Longest-Run Bose (79,64) -- TODO RUN ME (currently on
% DFM)
policy=4;
code=2;
load('/Users/mark/Dropbox/SoftwareDefinedECC/data/rv64g/data-recovery/offline-dynamic/bose1960/79,64/hash-none/hamming-pick-longest-run/crash-threshold-0.5/2017-03-13/postprocessed/postprocessed.mat','avg_benchmark_successes');%,'avg_benchmark_miscorrect','avg_benchmark_could_have_crashed');
mean_success(policy,code) = geomean(avg_benchmark_successes);
%mean_miscorrect(policy,code) = geomean(avg_benchmark_miscorrect);
%mean_panic(policy,code) = geomean(avg_benchmark_could_have_crashed);

%% Hamming-Pick-Longest-Run Kaneda (144,128)
policy=4;
code=3;
load('/Users/mark/Dropbox/SoftwareDefinedECC/data/rv64g/data-recovery/offline-dynamic/kaneda1982/144,128/hash-none/hamming-pick-longest-run/crash-threshold-0.5/2016-11-14/postprocessed/postprocessed.mat','avg_benchmark_successes');%,'avg_benchmark_miscorrect','avg_benchmark_could_have_crashed');
mean_success(policy,code) = geomean(avg_benchmark_successes);
%mean_miscorrect(policy,code) = geomean(avg_benchmark_miscorrect);
%mean_panic(policy,code) = geomean(avg_benchmark_could_have_crashed);

%% DBX-Longest-Run-Pick-Lowest-Weight Hsiao (72,64)
policy=5;
code=1;
load('/Users/mark/Dropbox/SoftwareDefinedECC/data/rv64g/data-recovery/offline-dynamic/hsiao1970/72,64/hash-none/dbx-longest-run-pick-lowest-weight/crash-threshold-0.5/2016-11-17/postprocessed/postprocessed.mat','avg_benchmark_successes');%,'avg_benchmark_miscorrect','avg_benchmark_could_have_crashed');
mean_success(policy,code) = geomean(avg_benchmark_successes);

%% DBX-Longest-Run-Pick-Lowest-Weight Bose (79,64)
policy=5;
code=2;
load('/Users/mark/Dropbox/SoftwareDefinedECC/data/rv64g/data-recovery/offline-dynamic/bose1960/79,64/hash-none/dbx-longest-run-pick-lowest-weight/crash-threshold-0.5/2016-11-17/postprocessed/postprocessed.mat','avg_benchmark_successes');%,'avg_benchmark_miscorrect','avg_benchmark_could_have_crashed');
mean_success(policy,code) = geomean(avg_benchmark_successes);

%% DBX-Longest-Run-Pick-Lowest-Weight Kaneda (144,128)
policy=5;
code=3;
load('/Users/mark/Dropbox/SoftwareDefinedECC/data/rv64g/data-recovery/offline-dynamic/kaneda1982/144,128/hash-none/dbx-longest-run-pick-lowest-weight/crash-threshold-1/2016-11-15/postprocessed/postprocessed.mat','avg_benchmark_successes');%,'avg_benchmark_miscorrect','avg_benchmark_could_have_crashed');
mean_success(policy,code) = geomean(avg_benchmark_successes);

%% Longest-Run-Pick-Random Hsiao (72,64)
policy=6;
code=1;
load('/Users/mark/Dropbox/SoftwareDefinedECC/data/rv64g/data-recovery/offline-dynamic/hsiao1970/72,64/hash-none/longest-run-pick-random/crash-threshold-0.5/2016-11-16/postprocessed/postprocessed.mat','avg_benchmark_successes');%,'avg_benchmark_miscorrect','avg_benchmark_could_have_crashed');
mean_success(policy,code) = geomean(avg_benchmark_successes);

%% Longest-Run-Pick-Random Bose (79,64)
policy=6;
code=2;
load('/Users/mark/Dropbox/SoftwareDefinedECC/data/rv64g/data-recovery/offline-dynamic/bose1960/79,64/hash-none/longest-run-pick-random/crash-threshold-0.5/2016-11-16/postprocessed/postprocessed.mat','avg_benchmark_successes');%,'avg_benchmark_miscorrect','avg_benchmark_could_have_crashed');
mean_success(policy,code) = geomean(avg_benchmark_successes);

%% Longest-Run-Pick-Random Kaneda (144,128)
policy=6;
code=3;
load('/Users/mark/Dropbox/SoftwareDefinedECC/data/rv64g/data-recovery/offline-dynamic/kaneda1982/144,128/hash-none/longest-run-pick-random/crash-threshold-1/2016-11-15/postprocessed/postprocessed.mat','avg_benchmark_successes');%,'avg_benchmark_miscorrect','avg_benchmark_could_have_crashed');
mean_success(policy,code) = geomean(avg_benchmark_successes);


%% Delta-Pick-Random Hsiao (72,64)
policy=7;
code=1;
load('/Users/mark/Dropbox/SoftwareDefinedECC/data/rv64g/data-recovery/offline-dynamic/hsiao1970/72,64/hash-none/delta-pick-random/crash-threshold-0.5/2016-11-16/postprocessed/postprocessed.mat','avg_benchmark_successes');%,'avg_benchmark_miscorrect','avg_benchmark_could_have_crashed');
mean_success(policy,code) = geomean(avg_benchmark_successes);

%% Delta-Pick-Random Bose (79,64)
policy=7;
code=2;
load('/Users/mark/Dropbox/SoftwareDefinedECC/data/rv64g/data-recovery/offline-dynamic/bose1960/79,64/hash-none/delta-pick-random/crash-threshold-0.5/2016-11-16/postprocessed/postprocessed.mat','avg_benchmark_successes');%,'avg_benchmark_miscorrect','avg_benchmark_could_have_crashed');
mean_success(policy,code) = geomean(avg_benchmark_successes);

%% Delta-Pick-Random Kaneda (144,128)
policy=7;
code=3;
load('/Users/mark/Dropbox/SoftwareDefinedECC/data/rv64g/data-recovery/offline-dynamic/kaneda1982/144,128/hash-none/delta-pick-random/crash-threshold-1/2016-11-15/postprocessed/postprocessed.mat','avg_benchmark_successes');%,'avg_benchmark_miscorrect','avg_benchmark_could_have_crashed');
mean_success(policy,code) = geomean(avg_benchmark_successes);