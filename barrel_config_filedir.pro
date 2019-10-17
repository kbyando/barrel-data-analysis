;+
;NAME: barrel_config_filedir
;DESCRIPTION: Get the applications user directory for BARREL/TDAS
;  data analysis software.
;
;REQUIRED INPUTS:
; none
;
;KEYWORD ARGUMENTS (OPTIONAL):
; none
;
;STATUS:
;
;TO BE ADDED: n/a
;
;EXAMPLE:
;
;REVISION HISTORY:
;Version 0.90 KBY 04/19/2013 no changes
;Version 0.84 KBY 12/04/2012 added header 
;Version 0.83 KBY 12/04/2012 initial beta release
;Version 0.80 KBY 10/29/2012 from 'goesmag/goes_config_filedir.pro' by JWL(?)
;-

function barrel_config_filedir, app_query = app_query, _extra=_extra

    readme_txt = ['Directory for configure files for use by ',$
                    'the THEMIS Data Analysis Software (TDAS)']

    if (keyword_set(app_query)) then begin
        tdir = app_user_dir_query('themis', 'barrel_config', /restrict_os)
        if (n_elements(tdir) EQ 1) then tdir = tdir[0]
        RETURN, tdir
    endif else begin
        RETURN, app_user_dir('themis', 'THEMIS Configuration Process',$
                                'barrel_config', $
                                'THEMIS configureation directory',$
                                readme_txt, 1, /restrict_os)
    endelse

END

