pro barrel_spectroscopy,$
   specstruct,$                              ;output structure
   date,hours,payload, $                     ;define data interval
   starttimes=starttimes,endtimes=endtimes,$ ;In case not to select from screen
   startbkgs=startbkgs,endbkgs=endbkgs,$     ;In case not to select from screen
   lcband=lcband,uselog=uselog,$             ;lightcurve display options
   mticks=mticks,sticks=sticks,$             ;
   slow=slow,version=version,level=level,$   ;data file type
   numsrc=numsrc,$                           ;number of time intervals to sum
   altitude=altitude,$                       ;altitude; fetch from GPS by default
   bkgmethod=bkgmethod,numbkg=numbkg,$       ;background related parameters
   maglat=maglat,bkg_renorm=bkg_renorm,$     ;more background related parameters
   verbose=verbose, quiet=quiet,$                       ;verbose/quiet
   fitrange=fitrange,model=model,method=method,$        ;fitting
   maxcycles=maxcycles, residuals=residuals,$           ;more fitting
   modlfile=modlfile,secondmodlfile=secondmodlfile,$  ; fitting model file(s)
   angledist=angledist,$                     ;model angular distrib. for DRM
   systematic_error_frac = $                 ;fraction of bkg-subtracted spectrum
     systematic_error_frac,$                 ;to be added in quadrature with stat. error
   saveme=saveme                             ;filename to save spectrum object at end

;DEFAULTS:
if not keyword_set(lcband) then lcband=1
if not keyword_set(uselog) then uselog=0
if not keyword_set(slow) then slow=0
if not keyword_set(version) then version='.v02'
if not keyword_set(level) then level=2
if not keyword_set(numsrc) then numsrc=1
if not keyword_set(bkgmethod) then bkgmethod=1
if not keyword_set(numbkg) then numbkg=1
if not keyword_set(bkg_renorm) then bkg_renorm=0
if not keyword_set(verbose) then verbose=1
if not keyword_set(quiet) then quiet=0
if not keyword_set(fitrange) then $
   if slow then fitrange=[50.,2500.] else fitrange=[130.,2500.]
if not keyword_set(method) then method=1
if not keyword_set(model) then model=1
if not keyword_set(maxcycles) then maxcycles=30
if not keyword_set(residuals) then residuals=1
if not keyword_set(altitude) then begin
   ;Dig out altitude at center of time interval from GPS data, 
   ;for DRM and bkg modeling
   timespan,date,hours,/hour
   barrel_load_data,probe=payload,datatype=['GPS'],level=level,/no_clobber,version=version
   varname='brl'+payload+'_GPS_Alt'
   tplot_names,varname,NAMES=matches,/ASORT
   if (n_elements(matches) EQ 1) then get_data, matches[0], data=gpsalt $
        else message, 'Bad number of variable name matches (GPS_Alt): '+ $
        strtrim(n_elements(matches))
   altitude=gpsalt.y[n_elements(gpsalt.y)/2]
endif
if (not keyword_set(maglat)) and (bkgmethod eq 2) then begin
   ;Dig out lat/lon at center of time interval from GPS data for bkg modeling:

   timespan,date,hours,/hour
   barrel_load_data,probe=payload,datatype=['GPS'],level=level,/no_clobber,version=version

   varname='brl'+payload+'_GPS_Lat'
   tplot_names,varname,NAMES=matches,/ASORT
   if (n_elements(matches) EQ 1) then get_data, matches[0], data=gpslat $
        else message, 'Bad number of variable name matches (GPS_LAT): '+ $
        strtrim(n_elements(matches))
   geolat=gpslat.y[n_elements(gpslat.y)/2]

   varname='brl'+payload+'_GPS_Lon'
   tplot_names,varname,NAMES=matches,/ASORT
   if (n_elements(matches) EQ 1) then get_data, matches[0], data=gpslon $
        else message, 'Bad number of variable name matches (GPS_LON): '+ $
        strtrim(n_elements(matches))
   geolon=gpslon.y[n_elements(gpslon.y)/2]

   maglat = abs((geo2mag([geolat,geolon]))[0])
endif
if (keyword_set(starttimes) ne keyword_set(endtimes)) then message,$
   'starttimes and endtimes must be set together'
if (keyword_set(startbkgs) ne keyword_set(endbkgs)) then message,$
   'startbkgs and endbkgs must be set together'
 
;saveme has no default.
;starttimes, endtimes has no default

;Now the main steps:

;Make the structure:
specstruct=barrel_sp_make(numsrc=numsrc,numbkg=numbkg,slow=slow)

;Pick data times graphically:
barrel_sp_pick_datatime,specstruct,date,hours,payload,bkgmethod,version=version,$
   lcband=lcband,starttimes=starttimes,endtimes=endtimes,startbkgs=startbkgs,$
   endbkgs=endbkgs,mticks=mticks,sticks=sticks

;Collect spectra:
barrel_sp_collect_spectra,specstruct,level=level,version=version,$
   altitude=altitude,maglat=maglat

;Make response matrices:
if method GT 3 then begin
   barrel_sp_make_drm, specstruct,altitude=altitude,angledist=1
   barrel_sp_make_drm, specstruct,altitude=altitude,angledist=2,whichone=2
endif else $
   barrel_sp_make_drm, specstruct,altitude=altitude,angledist=angledist

;Spectral fitting:
barrel_sp_fold,specstruct,fitrange=fitrange,bkg_renorm=bkg_renorm,$
   method=method,model=model,verbose=verbose,maxcycles=maxcycles,$
   quiet=quiet,modlfile=modlfile,secondmodlfile=secondmodlfile,$
   residuals=residuals,systematic_error_frac=systematic_error_frac

;Save the results:
if keyword_set(saveme) then save,specstruct,filename=saveme

end
