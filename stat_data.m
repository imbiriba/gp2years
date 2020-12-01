function stat_data()

  fnames={
'vale_data_sixes_inver_1.txt','00-06 - Rainy','00-06 - R';
'vale_data_sixes_inver_2.txt','06-12 - Rainy','06-12 - R';
'vale_data_sixes_inver_3.txt','12-18 - Rainy','12-18 - R';
'vale_data_sixes_inver_4.txt','18-24 - Rainy','18-24 - R';
'vale_data_sixes_verao_1.txt','00-06 - Dry'  ,'00-06 - D';
'vale_data_sixes_verao_2.txt','06-12 - Dry'  ,'06-12 - D';
'vale_data_sixes_verao_3.txt','12-18 - Dry'  ,'12-18 - D';
'vale_data_sixes_verao_4.txt','18-24 - Dry'  ,'18-24 - D'};

for ii=1:8
  stat_data_1(fnames{ii,1},fnames{ii,2},fnames{ii,3});
end

end


function stat_data_1(fname,tit,sfn)
% function stat_data(fname)
% 
% Do basic analysis on wind data file generated from make_paper_plume_vale.m
%
% B.I. 2020.10.08

dat=load(fname);
wdir = dat(:,1);
wspd = dat(:,2);
rad = dat(:,3);
prec = dat(:,4);
cloud = dat(:,5);
sset = dat(:,6);
wdirsd = dat(:,7);
yyyy = dat(:,8);
mm = dat(:,9);
dd = dat(:,10);
hh = dat(:,11);

radhist;


end

