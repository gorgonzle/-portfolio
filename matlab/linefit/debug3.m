clc; clear; clear all

filename = "personalBestValue.txt";
fid =  fopen(filename,'r');
f = fread(fid,'*char')';
fclose(fid);
f = strrep(f,' ' , '');
fid =  fopen(filename,'w');
fprintf(fid,f);
fclose(fid);