function where_limits,a,min,max,cnt
ind=where(a ge min and a le max,cnt)
return,ind
end