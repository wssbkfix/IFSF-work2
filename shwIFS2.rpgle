**free 
// ifs display program version 2                                                
// This version has the following improvements                                  
// it uses the ifs object statistics table function directly                    
// so there is no need to build an table.                                       
// Second:                                                                      
//  There is a screen that just shows the directories.                          
//  This screen will give a summary view (directeries only display              
// Third                                                                        
//  The file view screen will show the files from the directory chosen from     
//  the first screen.                                                           
//  The full path will not be shown on each line, instead more room is given to 
//  show the attributes of the file.                                            

ctl-opt option(*nodebugio:*srcstmt:*nounref) ; // dftactgrp(*no) ;   
//-----------------------------------------------------------------------*
 dcl-f shwIFS2  workstn indds(Dspf)  sfile(SFL01:Z1RRN) ;                       
                                                                                
 dcl-f shwIFS22 workstn indds(Dspf2) sfile(SFL02:Z2RRN) ;                       
                                                                                
 dcl-f shwifs23 workstn indds(dspf3) sfile(SFL03:Z3RRN) ;                       
                                                                                
// external procedures                                                         
dcl-pr getDirListClose ;                                                       
end-pr;                                                                        
                                                                                
dcl-pr GetDirListCsr ;                                                         
end-pr ;                                                                       
                                                                                                                                                      
dcl-pr getDirListOpen ;                                                        
end-pr;                                                                        
                                                                                
dcl-pr GetDirListFetch int(10) ;                                               
  *n likeds(dirAllRecs) ;                                                      
  *n int(10) ;                                                                 
end-pr ;                                                                                                                                          
                                                                                
dcl-pr getFileListCsr ;                                                        
end-pr ;                                                                       
                                                                                
dcl-pr GetFileListFetch int(10) ;                                              
  *n likeds(dirAllFiles) ;                                                     
  *n int(10) ;                                                                 
end-pr;                                                                        
                                                                                
dcl-pr GetFileListClose ;                                                      
end-pr ;                                                                       
                                                                                
dcl-pr GetFileListOpen ;                                                       
end-pr ;                                                                       
                                                                                
dcl-pr setSQLFilter ;                                                          
  *n char(30) ; // base folder & position to                                   
end-pr ;                                                                       
                                                                                
dcl-pr setSQLFilter2 ;                                                         
  *n char(30) ;                                                                
end-pr ;                                                                       
                                                                               
dcl-pr SetSQLBaseFolder ;                                                      
  *n char(50) ;                                                                
end-pr ;                                                                       
                                                                               
dcl-pr setSQLBaseFolder2 ;                                                     
 *n like(SCPATH) ;                                                             
end-pr ;                                                                       
                                                                               
dcl-pr setSQLBaseFolder3 ;                                                     
 *n like(SCPATH) ;                                                             
end-pr ;                                                                       
                                                                                
dcl-pr setSQLOmitList ;                                                        
    *n  char(200) ;                                                            
end-pr ;                                                                       
                                                                                
dcl-pr GetOneRecordSelect int(10) ;                                            
    *n            likeds(fileOneValuesRec) ;                                   
    *n             int(10) ;                                                   
end-pr ;                                                                       
                                                                                
                                                                                
dcl-ds PgmDs psds qualified ;                                                  
  PgmName *proc ;                                                                
end-ds ;                                                                       
                                                                                
                                                                                
dcl-ds dirAllRecs qualified ;                                                  
dcl-ds dirList dim(10) ;                                                       
  pathName      char(500) ;                                                    
  Desc          char(50) ;                                                     
  charSet       int(10) ;                                                      
end-ds ;                                                                       
end-ds ;                                                                       
                                                                                
dcl-ds dirAllFiles qualified ;                                                 
dcl-ds FileList dim(10) ;                                                      
  pathName      char(500) ;                                                    
  objectType    char(10) ;                                                     
  Desc          char(50) ;                                                     
  charSet       int(10) ;                                                      
  size          int(20) ;                                                      
  createTimeStamp   timestamp ;                                                
end-ds ;                                                                       
end-ds ;                                                                       
                                                                                
                                                                                
dcl-ds fileOneValues qualified  based(fileOneValuesPtr) ;                      
  fileOneValue          char(300) ;                                            
  fileText              char(50) overlay(FileOneValue) ;                       
  createTimeStamp       char(50) overlay(fileOneValue :51) ;                   
  objectChangeTimestamp char(50) overlay(fileOneValue : 101) ;                 
  daysUsed              char(50) overlay(fileOneValue : 151) ;                 
  allocatedSize         char(50) overlay(fileOneValue : 201) ;                 
  CCSSID                char(50) overlay(fileOneValue : 251) ;                 
end-ds ;                                                                       
                                                                                
dcl-s fileOneValuePtr    pointer ;                                             
                                                                                
dcl-ds FileOneDescs qualified ;                                                
  fileOneDesc     char(120) ;                                                  
  objectType      char(20) overlay(fileOneDesc )  inz('Object Type:') ;        
  textDdscription char(20) overlay(fileOneDesc : 21)  inz('Text Desc:') ;      
  createTimeStamp char(20) overlay(fileOneDesc : 41)  inz('Create Time Stamp:') ;
  changeTimeStamp char(20) overlay(fileOneDesc : 61)  inz('Change Time Stamp:') ;
  DaysUsed        char(20) overlay(fileOneDesc : 81) inz('Days Used:') ;       
  allocatedSize   char(20) overlay(fileOneDesc : 101) inz('Allocated Size:') ; 
end-ds ;                                                                       
                                                                                
                                                                                
dcl-s cfbaseFolder char(50) ;                                                  
dcl-s cfBaseFolder2 char(80) ;                                                 
dcl-s cfBaseFolder3 char(80) ;                                                 
dcl-s cfOmitList   char(500) ;                                                                                                                                                   
dcl-s stPosDir int(10) ;                                                          
dcl-s stPosFile int(10) ;                                                      
dcl-s recsRetDir    int(10) ;                                                  
dcl-s recsRetFile    int(10) ;                                                 
dcl-s prFilter char(30) ;                                                      
dcl-s prFilter2 char(60) ;                                                                                          
dcl-s PrvPosition like(Z1POSITION) ;                                           
dcl-s PrvPosition2 like(Z2POSITION) ;                                          
dcl-s wkSqlCode int(10) ;                                                      
                                                                                
                                                                                                                                      
                                                                                
dcl-ds Dspf qualified ;                                                        
    Exit ind pos(3) ;                                                          
    Refresh ind pos(5) ;                                                       
    SflDspCtl ind pos(30) ;                                                    
    SflDsp ind pos(31) ;                                                       
end-ds ;                                                                       
                                                                                
dcl-ds Dspf2 qualified ;                                                       
    Exit ind pos(3) ;                                                          
    Refresh ind pos(5) ;                                                       
    SflDspCtl ind pos(30) ;                                                    
    SflDsp ind pos(31) ;                                                       
end-ds ;                                                                       
                                                                                
dcl-ds Dspf3 qualified ;                                                       
    Exit ind pos(3) ;                                                          
    Refresh ind pos(5) ;                                                       
    SflDspCtl ind pos(30) ;                                                    
    SflDsp ind pos(31) ;                                                       
end-ds ;                                                                       
                                                                                
dcl-ds fileOneValuesRec qualified ;                                            
  fileText              char(50) ;                                             
  createTimeStamp       char(50) ;                                             
  objectChangeTimestamp char(50) ;                                             
  lastUsedTimeStamp     char(50) ;                                             
  allocatedSize         char(50)  ;                                            
  CCSSID                char(50) ;                                             
end-ds ;                                                                       
                                                                                
//------------                                                                 
// Main entry                                                                  
//------------                                                                                                                                     

setDefaultValues() ;

ProcessDirectories() ;

*inlr = *on ;

return ; 

// subprocedures 

// routines for screen 1 Directories -----------------------------       
// 1- Process Directories       
// 2- Init                                                                                                                         
// 3- LoadSubfileDir                                                           
// 4- ProcessFiles                                                             
// 4- ReadSubfile                                                              
// 6- ResetCursor                                                              
// 7- SetFilter                                                               

//----------------------------------------  
dcl-proc ProcessDirectories ; 
//----------------------------------------  
dcl-pi ProcessDirectories ; 
end-pi; 

init1() ;                                                                       
                                                                                
Z1SCREEN = %trimr(PgmDs.PgmName) + '-1' ;                                      
                                                                                
LoadSubfileDir() ;                                                             
                                                                                
                                                                                
dow (1 = 1) ;                                                                  
  write REC01 ;                                                              
  exfmt CTL01 ;                                                              
                                                                                
  if (Dspf.Exit) ;                                                           
    leave ;                                                                
  elseif (Dspf.Refresh) ;                                                    
    Z1POSITION = ' ' ;                                                     
    PrvPosition = ' ' ;                                                    
    prFilter = setFilter() ;                                     
    SetSQLFilter(prFilter) ;                                               
    resetCursor() ;                                                        
    Z1RRN = 0 ;                                                            
    LoadSubfileDir() ;                                                     
    iter ;                                                                 
  elseif (Z1POSITION <> PrvPosition) ;                                       
    PrvPosition = Z1POSITION ;                                                                                        
    prFilter = setFilter() ;                                     
    setSQlFilter(prFilter) ;                                               
    resetCursor() ;  // need reset of position                             
    Z1RRN = 0 ;                                                            
    LoadSubfileDir() ;                                                     
    iter ;                                                                 
  endif ;                                                                    
                                                                                
  if (Dspf.SflDsp) ;                                                         
    ReadSubfile() ;                                                        
  endif ;                                                                    
enddo ;                                                                        

return; 

end-proc; 
                                                                             
//----------------------------------------                                     
dcl-proc init1 ;                                                                
//----------------------------------------                                     
dcl-pi init1 ;                                                                  
end-pi;                                                                        
                                                                                
setDefaultValues() ;                                                           
prFilter = cfBaseFolder ;                                                      
setSQLBaseFolder (cfBaseFolder) ;                                              
setSQLFilter (prFilter) ;                                                      
setSQLOmitList(cfOmitList) ;                                                   
                                                                                
GetDirListCsr() ;                                                              
getDirListOpen() ;                                                             
                                                                                
fileOneValuesPtr = %addr(FileOneValuesRec) ;                                   
                                                                                
// base values later could be changed to config file or table lookup           
// JSON ??                                                                     
                                                                                
end-proc;                                                                      
                                                                                
//---------------------------------                                            
dcl-proc setDefaultValues ;                                                    
//---------------------------------                                            
dcl-pi setDefaultValues ;                                                      
end-pi ;                                                                       
                                                                                
cfbaseFolder = '/home/WSSBKFIX2/' ;                                          
cfOmitList =                                                                 
  '/home/WSSBKFIX2/web-node/  /home/WSSBKFIX2/web-node2/ +                     
  /home/WSSBKFIX2/.npm /home/WSSBKFIX2/node_modules' ;                        
prFilter = ' ' ;                                                             
                                                                                
return ;                                                                       
end-proc ;                                                                     
                                                                                
                                                                                
//------------------------------------------                                   
dcl-proc LoadSubfileDir ;                                                      
//------------------------------------------                                   
dcl-pi LoadSubfileDir ;                                                      
end-pi ;                                                                     
                                                                                
dcl-s x int(5) ;                                                             
dcl-s wsPos int(5) ;                                                         
                                                                                
Dspf.SflDspCtl = *off ;                                                      
Dspf.SflDsp = *off ;                                                         
write CTL01 ;                                                                
Dspf.SflDspCtl = *on ;                                                       
Z1OPT = ' ' ;                                                        
scfldr = cfBaseFolder ;                                                      
stPosDir = %len(%trimr(scfldr))+1 ;                                          
                                                                                
                                                                                
dow 1 = 1 ;                                                                  
  wkSqlCode = GetDirListFetch(dirAllRecs : recsRetDir) ;                     
                                                                                
  if recsRetDir = 0 ;                                                        
    leave ;                                                                  
  endif ;                                                                    
                                                                                
     // skip first if not positioning                                           
                                                                                
  if Z1POSITION > ' '  ;                                                     
    wsPos =1 ;                                                               
  else ;                                                                     
    wsPos  = 2 ;                                                             
  endif ;                                                                    
                                                                                
  for x = wsPos to recsRetDir  ;                                             
    scpath = %trim(%subst(dirAllRecs.dirList(x).pathname                     
              : stPosDir : 29)) + '/ ';   //close with slash because not in directory 
    scDesc = %subst(dirAllRecs.dirList(x).Desc                               
              : 1 : 20) ;                                                       

      Z1RRN += 1;                                                              
      if Z1RRN > 9999 ;                                                        
        leave ;                                                                
      endif;                                                                   
                                                                                
      write SFL01 ;                                                            
  endfor ;                                                                   
                                                                                
enddo ;                                                                      
                                                                                
if (Z1RRN > 0) ;                                                             
  Dspf.SflDsp = *on ;                                                        
endif ;                                                                      
                                                                                
end-proc ;                                                                     
                                                                                                                                                                                                                                      
 //----------------------------------------------                               
 dcl-proc ReadSubfile ;                                                         
 //----------------------------------------------    
 dcl-pi ReadSubfile ; 
 end-pi ; 

   dow (1 = 1) ;                                                                
                                                                                
     readc SFL01 ;                                                              
     if (%eof) ;                                                                
       leave ;                                                                  
     endif ;                                                                    
  //something depending on value in Z1OPT                                       
     if (Z1OPT = 'X' OR Z1OPT = 'x') ;                                                           
       processfiles(SCPATH) ;                                                   
     endif ;                                                                    
                                                                                
     Z1OPT = ' ' ;                                                              
     update SFL01 ;                                                             
   enddo ;                                                                      
 end-proc ;                                                                     
                                                                                
 //---------------------------------                                            
 dcl-proc resetCursor ;                                                         
 //---------------------------------                                            
 dcl-pi resetCursor ;                                                           
 end-pi ;                                                                       
                                                                                
   getDirListClose() ;                                                          
   GetDirListCsr() ;                                                            
   getDirListOpen() ;                                                           
                                                                                
 return  ;                                                                      
 end-proc ;                                                                     
                                                                                                                                                           
 //---------------------------------                                            
 dcl-proc setFilter  ;                                                          
 //---------------------------------                                            
 dcl-pi setFilter  char(100);                                                                                                          
 end-pi ;                                                                       
                                                                                
 return %trim(cfBaseFolder) + %trimr(Z1POSITION) ;                              
 end-proc ;                                                                     
                                                                                
                                                                                
 // routines for the Screen 2 File ------------------------------      
 // 1- ProcessFiles          
 // 2- Init2                                                                    
 // 3- LoadSubfileFiles                                                         
 // 4- ReadSubfile2                                                             
 // 5- ResetCursor2      
 // 6- SetFilter2                                                        

//------------------------------------------##new##                            
dcl-proc ProcessFiles ;                                                        
//------------------------------------------                                   
dcl-pi ProcessFiles ;                                                          
  PRSCPATH  like(SCPATH) ;                                                     
end-pi ;                                                                       
                                                                                
init2(PRSCPATH) ;                                                              
                                                                                
Z2SCREEN = %trimr(PgmDs.PgmName) + '-1' ;                                      
                                                                                
LoadSubfilefiles() ;                                                           
                                                                                
Dow (1 = 1) ;                                                                  
  write REC02 ;                                                              
  exfmt CTL02 ;                                                              
                                                                                
  if (Dspf2.Exit) ;                                                          
    leave ;                                                                
  elseif (Dspf.Refresh) ;                                                    
    Z2POSITION = ' ' ;                                                     
    PrvPosition2 = ' ' ;                                                   
    prFilter2 = setFilter2() ;
    SetSQLFilter2(prFilter2) ;                                 
    resetCursor2() ;                                                       
    Z2RRN = 0 ;                                                            
    LoadSubfileFiles() ;                                                   
    iter ;                                                                 
  elseif (Z2POSITION <> PrvPosition2) ;                                      
    PrvPosition2 = Z2POSITION ;                                                                                           
    prFilter2 = setFilter2() ;                                    
    setSQlFilter2(prFilter2) ;                                             
    resetCursor2() ;  // need reset of position                            
    Z2RRN = 0 ;                                                            
    LoadSubfileFiles() ;                                                   
    iter ;                                                                 
  endif ;                                                                    
                                                                                
  if (Dspf2.SflDsp) ;                                                        
    ReadSubfile2() ;                                                       
  endif ;                                                                    
enddo ;                                                                        
                                                                                
return ;                                                                       
                                                                                
end-proc ;                                                                     



//----------------------------------------                                     
dcl-proc init2 ;   // for screen 2                                             
//----------------------------------------                                     
 dcl-pi init2 ;                                                                 
   prFolder2 like(SCPATH) ;                                                     
 end-pi;                                                                        
                                                                                
 cfBaseFolder2  = prFolder2 ;                                                   
 setSQLBaseFolder2 (prFolder2) ;                                                                                            
                                                                                
 GetFileListClose() ;                                                           
 GetFileListCsr() ;                                                             
 getFileListOpen() ;                                                            
                                                                                
 return ;                                                                       
                                                                                
 end-proc;           

 //------------------------------------------                                   
 dcl-proc LoadSubfileFiles ;                                                    
 //------------------------------------------                                   
   dcl-pi LoadSubfileFiles ;                                                    
   end-pi ;                                                                     
                                                                                
   dcl-s x int(5) ;                                                             
                                                                                
   Dspf2.SflDspCtl = *off ;                                                     
   Dspf2.SflDsp = *off ;                                                        
   write CTL02 ;                                                                
   Dspf2.SflDspCtl = *on ;                                                      
   Z2OPT = ' ' ;                                                                
   Z2RRN = 0 ;                                                                  
   scattr02   = 'CCSID' ;                                                       
   SCFLDR02   = %trimr(cfBaseFolder) + %trimr(cfBaseFolder2) ;                  
   stPosFile = %len(%trimr(SCFLDR02))+1 ;                                       
                                                                                
                                                                                
   dow 1 = 1 ;                                                                  
     wkSqlCode = GetFileListFetch(dirAllFiles : recsRetFile) ;                  
                                                                                
     if recsRetFile = 0 ;                                                       
       leave ;                                                                  
     endif ;                                                                    
                                                                                
     for x = 1 to recsRetFile  ;                                                
       SCPATH02  = %subst(dirAllFiles.FileList(x).pathname                      
              : stPosFile  : 30 ) ;                                             
       SCDESC02 = dirAllFiles.FileList(x).Desc ;                                  
                                                                                
       SCATTR02  = %char(dirAllFiles.FileList(x).charSet) ;                       
       Z2RRN += 1;                                                              
       if Z2RRN > 9999 ;                                                        
         leave ;                                                                
       endif;                                                                   
                                                                                
       write SFL02 ;                                                            
     endfor ;                                                                   
                                                                                
   enddo ;                                                                      
                                                                                
   if (Z2RRN > 0) ;                                                             
     Dspf2.SflDsp = *on ;                                                       
   endif ;                                                                      
 end-proc ;                                                                     
                                                                                
 //----------------------------------------------                               
 dcl-proc ReadSubfile2 ;  // Process file list                                  
 //----------------------------------------------                               
   dow (1 = 1) ;                                                                
                                                                                
     readc SFL02 ;                                                              
     if (%eof) ;                                                                
       leave ;                                                                  
     endif ;                                                                    
  //something depending on value in Z2OPT                                       
     if Z2OPT = '8' ;                                                           
       processFile3(SCPATH02) ;                                                 
     endif ;                                                                    
                                                                                
     Z2OPT = ' ' ;                                                              
     update SFL02 ;                                                             
   enddo ;                                                                      
 end-proc ;                                                                     
                                                                                
                                                                                
 //---------------------------------                                            
 dcl-proc resetCursor2 ;                                                        
 //---------------------------------                                            
 dcl-pi resetCursor2 ;                                                          
 end-pi ;                                                                       
                                                                                
   getFileListClose() ;                                                         
                                                                                
                                                                                
   // position cursor or from the start ??                                      
                                                                                
 GetFileListCsr() ;                                                             
 getFileListOpen() ;                                                            
                                                                                
 return  ;                                                                      
 end-proc ;  

 //---------------------------------                                            
 dcl-proc setFilter2  ;                                                          
 //---------------------------------                                            
 dcl-pi setFilter2  char(130);                                                   
 end-pi ;                                                                       
                                                                                
 return %trimr(cfBaseFolder) + %trimr(cfBaseFolder2) + %trimr(Z2POSITION) ;                              
 end-proc ;                                                                     
                                                                    
                                                                                
 // routines for the Screen 3 File ------------------------------               
 //    process file 3                                                           
 // 1- Init3                                                                    
 // 2- LoadSubfileOneFile                                                       
 //----------------------------------------                                     
 dcl-proc processFile3  ;   // for screen 3                                     
 //----------------------------------------                                     
 dcl-pi processFile3  ;                                                         
   prFolder3 like(SCPATH02) ;                                                   
 end-pi;                                                                        
                                                                                
 init3(prFolder3) ;                                                             
                                                                                
 LoadSubfileFilesOne() ;                                                        
                                                                                
 Dow (1 = 1) ;                                                                  
     write REC03 ;                                                              
     exfmt CTL03 ;                                                              
                                                                                
     if (Dspf3.Exit) ;                                                          
         leave ;                                                                
     endif ;                                                                    
 enddo ;                                                                        
                                                                                                                                                           
 return ;                                                                       
                                                                                
 end-proc ;                                                                     
                                                                                
                                                                                
 //----------------------------------------                                     
 dcl-proc init3 ;   // for screen 2                                             
 //----------------------------------------                                     
 dcl-pi init3 ;                                                                 
   prFolder3 like(SCPATH02) ;                                                   
 end-pi;                                                                        
                                                                                
 cfBaseFolder3  = prFolder3 ;                                                   
 setSQLBaseFolder3 (prFolder3) ;                                                
                                                                                
 // put in sql select into GetFileOneClose() ;                                  
                                                                                
 return ;                                                                       
                                                                                
 end-proc;                                                                      
                                                                                
 //------------------------------------------                                   
 dcl-proc LoadSubfileFilesOne ;                                                 
 //------------------------------------------                                   
   dcl-pi LoadSubfileFilesOne ;                                                 
   end-pi ;                                                                     
                                                                                
   dcl-s x int(5) ;                                                             
   dcl-s y int(5) inz(1) ;                                                      
   dcl-s z int(5) inz(1) ;                                                      
   dcl-s recsRetFileOne  int(10) ;                                              
                                                                                
   Dspf3.SflDspCtl = *off ;                                                     
   Dspf3.SflDsp = *off ;                                                        
   write CTL03 ;                                                                
   Dspf3.SflDspCtl = *on ;                                                      
   Z3RRN = 0 ;                                                                  
   SCFLDR03   = %trimr(cfBaseFolder) + %trimr(cfBaseFolder2) ;                  
   SCFLDR03B  = cfBaseFolder3 ;                                                   
   stPosFile = %len(%trimr(SCFLDR03))+2 ;                                       
                                                                                
                                                                                
     write rec03 ;                                                              
     wkSqlCode = GetOneRecordSelect(fileOneValuesRec: recsRetFileOne) ;         
                                                                                
     for x = 1 to 6 ;                                                           
       if recsRetFileOne = 0 ;                                                  
         leave ;                                                                
       endif ;                                                                  
                                                                                
       Z3RRN = X ;                                                              
                                                                                
       y = (x-1)* 20 + 1 ;                                                      
       z = (x-1) * 50 + 1 ;                                                     
                                                                                
       SCDESC03 = %subst(FileOneDescs.fileOneDesc: y : 20) ;                    
                                                                                
       SCATTR03 = %subst(fileOneValues.FileOneValue : z : 50) ;                 
       write SFL03 ;                                                            
                                                                                
       Dspf3.SflDsp = *on ;                                                     
                                                                                
     endfor ;                                                                   
                                                                                
 end-proc ;                                                                     