;
; 6 April 09
;
; ji_hv_read_config
;
; Read in an XML configuration file
;

PRO xml_to_struct__define 
 
void = {PLANET, NAME: "", Orbit: 0ull, period:0.0, Moons:0} 
void = {xml_to_struct, $ 
   INHERITS IDLffXMLSAX, $ 
   CharBuffer:"", $ 
   planetNum:0, $ 
   currentPlanet:{PLANET}, $ 
   Planets : MAKE_ARRAY(9, VALUE = {PLANET})} 
 
END 



FUNCTION ji_hv_read_config,location,observatory,instrument,detector

  if observer eq


  return
end
