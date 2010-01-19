;
; Get a list of the current contents of the incoming directory
;
FUNCTION HV_GET_INCOMING,incoming


  return,find_file(incoming)
end
