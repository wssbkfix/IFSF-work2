**free 
ctl-opt NoMain ;

// Service program or module for sql statements for the Show IFS utilities
// see github documentation  
// 
dcl-ds dirAllRecs qualified ; 
dcl-ds dirList dim(15) ;
    path_name        char(500) ; 
    Text_Description char(50) ;
    CodeSet          int(10) ; 
end-ds ; 
end-ds ; 

dcl-ds fileAllRecs qualified ; 
    dcl-ds fileList dim(10) ;
        pathName      char(500) ;
        objectType    char(10) ; 
        Desc          char(50) ; 
        charSet       int(10) ; 
        size          int(20) ;  
        createTimeStamp   timestamp ;
    end-ds ;
end-ds ;  

dcl-ds fileOneValuesRec qualified ;
  fileText              char(50) ; 
  createTimeStamp       char(50) ; 
  objectChangeTimestamp char(50) ; 
  lastUsedTimeStamp     char(50) ;  
  allocatedSize         char(50)  ; 
  CCSSID                char(50) ; 
end-ds ;


dcl-s  wsBaseFolder char(50) ; 
dcl-s  wsBaseFolder2 Char(80) ; 
dcl-s  wsBaseFolder3 Char(240) ; 
dcl-s  wsFilter     char(80) ;
dcl-s  wsFilter2    char(160) ; 
dcl-s  wsFolder   char(100) ;  
dcl-s  wsOmitList char(200) ;
dcl-s  wsPosition char(30) ;                 


//--------------------------------------------------------------------
dcl-proc GetDirListCsr  export ; 
//--------------------------------------------------------------------
 dcl-pi getDirListCsr ; 
 end-pi ; 

  exec SQL declare readDir cursor for
     SELECT CAST(PATH_NAME AS CHAR(500)),
            COALESCE(CAST(TEXT_DESCRIPTION AS CHAR(50)),' ') , 
            CCSID
    FROM TABLE(QSYS2.IFS_OBJECT_STATISTICS(START_PATH_NAME => TRIM(:wsBaseFolder) , 
                                           SUBTREE_DIRECTORIES => 'YES' , 
                                           OMIT_LIST => TRIM(:wsOmitList)))
    WHERE OBJECT_TYPE = '*DIR' 
     AND  UPPER(PATH_NAME) >=  UPPER(TRIM(:wsFilter))  
    ORDER BY UPPER(PATH_NAME) ; 

return ;
end-proc;

//--------------------------------------------------------------------
dcl-proc GetDirListClose export ;  
//--------------------------------------------------------------------
dcl-pi getDirListClose ; 
end-pi ; 

exec SQL close readDir ;

wsPosition = *blanks ; 

return ; 

end-proc ;

//--------------------------------------------------------------------
dcl-proc GetDirListOpen export ;  
//--------------------------------------------------------------------
dcl-pi GetDirListOpen ; 
    prPosition char(30) ;
end-pi ; 

exec SQL open readDir ;

return ; 

end-proc ; 

//--------------------------------------------------------------------
dcl-proc GetDirListFetch export ;
//--------------------------------------------------------------------
dcl-pi GetDirListFetch int(10) ; 
    prDirAllRecs        LIKEDS(dirAllRecs) ; 
    prDirRecCnt         int(10) ; 
end-pi ; 
 
 dcl-s wsrows int(10)  inz(10) ; 
 dcl-s wsRecCnt  int(10) ; 
 dcl-s x      int(05) ;

dcl-ds wsDirList DIM(10) qualified ;
    path_name char(500) ; 
    text_description Char(50) ; 
    ccsid int(10) ; 
end-ds ; 

    exec SQL fetch next from readDir 
    for :wsrows ROWS INTO :wsdirList ;

    if SQLCODE >= 0 ; 
       exec SQL GET DIAGNOSTICS :wsRecCnt  = ROW_COUNT ;  
    endif;

    prDirRecCnt = wsRecCnt;

    for x = 1 to wsRecCnt ; 
        prDirAllRecs.dirList(x)  = wsdirList(x) ;  
    endfor;   

return SQLCODE ; 

end-proc ; 

//--------------------------------------------------------------------
dcl-proc SetSQLBaseFolder export ; 
//--------------------------------------------------------------------
 dcl-pi SetSQLBaseFolder ; 
    prBaseFolder char(50) ; 
 end-pi ; 

 wsBaseFolder = prBaseFolder ; 


 return ; 
 end-proc ;

//--------------------------------------------------------------------
dcl-proc SetSQLBaseFolder2 export ; 
//--------------------------------------------------------------------
 dcl-pi SetSQLBaseFolder2 ; 
    prBaseFolder2 char(30) ; 
 end-pi ; 

 wsBaseFolder2 = %trimr(wsBaseFolder) + %trimr(prBaseFolder2) ; 

 return ; 
 end-proc ;

//--------------------------------------------------------------------
dcl-proc SetSQLFilter export ; 
//--------------------------------------------------------------------
 dcl-pi SetSQLFilter ; 
    prFilter char(80) ; 
 end-pi ; 

 wsFilter = prFilter ; 

 return ; 
end-proc ;

//--------------------------------------------------------------------
dcl-proc setSQLOmitList export ; 
//--------------------------------------------------------------------
 dcl-pi setSQLOmitList ; 
    prOmitList char(200) ; 
 end-pi ; 

 wsOmitList = prOmitList ; 

 return ; 
end-proc ;

// Second Screen  ----------------------------------------

//--------------------------------------------------------------------
dcl-proc GetFileListCsr  export ; 
//--------------------------------------------------------------------
 dcl-pi GetFileListCsr ; 
 end-pi ; 

 

 exec SQL declare readFile cursor for
     SELECT CAST(PATH_NAME AS CHAR(500)),
     coalesce(OBJECT_TYPE, ' '),
     coalesce(CAST(TEXT_DESCRIPTION AS CHAR(50)) , ' '),
     CCSID,
     ALLOCATED_SIZE,
     CREATE_TIMESTAMP 
    FROM TABLE(QSYS2.IFS_OBJECT_STATISTICS(START_PATH_NAME => TRIM(:wsBaseFolder2) , 
                                           SUBTREE_DIRECTORIES => 'YES',
                                           OMIT_LIST => TRIM(:wsOmitList)))  
    WHERE OBJECT_TYPE = '*STMF' 
    AND  UPPER(PATH_NAME) >=  UPPER(TRIM(:wsFilter2))  
    ORDER BY UPPER(PATH_NAME)
    ; 

return ;
end-proc; 

//--------------------------------------------------------------------
dcl-proc GetFileListClose export; 
//--------------------------------------------------------------------
dcl-pi GetFileListClose ; 
end-pi ; 

exec SQL close readFile ;

return ; 
end-proc ; 

//--------------------------------------------------------------------
dcl-proc GetFileListOpen export ;  
//--------------------------------------------------------------------
dcl-pi GetFileListOpen ; 
end-pi ; 

exec SQL open readFile ;

return ; 

end-proc ; 

//--------------------------------------------------------------------
dcl-proc GetFileListFetch export ;
//--------------------------------------------------------------------
dcl-pi GetFileListFetch int(10) ; 
    prFileAllRecs        LIKEDS(FileAllRecs) ; 
    prRecReturned        int(10) ; 
end-pi ; 
 
 dcl-s wsrows int(10)  inz(10) ; 
 dcl-s x      int(05) ;
 dcl-s wkRecCnt int(10) ; 

dcl-ds wsFileList dim(15) qualified ;
    path_name char(500) ; 
    OBJECT_TYPE char(10) ;
    Text_Description char(50) ;
    CodeSet  int(10) ;  
    size          int(20) ;  
    createTimeStamp   timestamp ;
end-ds ; 


    exec SQL fetch next from readFile 
    for :wsRows rows INTO :wsFileList ;

    if SQLCODE >= 0 ; 
       exec SQL GET DIAGNOSTICS :wkRecCnt  = ROW_COUNT ; 
    endif;   

    prRecReturned = wkRecCnt; 

    for x = 1 to wkRecCnt ;  
        prFileAllRecs.FileList(x)  = wsFileList(x) ;  
    endfor; 
   
return SQLCODE ; 

end-proc;

//--------------------------------------------------------------------
dcl-proc SetSQLFilter2 export ; 
//--------------------------------------------------------------------
 dcl-pi SetSQLFilter2 ; 
    prFilter2 char(80) ; 
 end-pi ; 

 wsFilter2 = %trimr(prFilter2) ; 

 return ; 
end-proc ;


// third screen 

//--------------------------------------------------------------------
dcl-proc SetSQLBaseFolder3 export ; 
//--------------------------------------------------------------------
 dcl-pi SetSQLBaseFolder3 ; 
    prBaseFolder3 char(30) ; 
 end-pi ; 

 wsBaseFolder3 = %trimr(wsBaseFolder2) + %trimr(prBaseFolder3) ; 

 return ; 
 end-proc ;

//--------------------------------------------------------------------
dcl-proc GetOneRecordSelect  export ;
//--------------------------------------------------------------------
dcl-pi GetOneRecordSelect int(10) ; 
    prfileOneValueRec     likeds(fileOneValuesRec) ; 
    prRecReturned        int(10) ;
end-pi ; 
 
  dcl-s wkRecCnt int(10) ; 


    exec sql     
     select 
       OBJECT_TYPE , 
       COALESCE(CAST(TEXT_DESCRIPTION AS CHAR(50)), ' ') AS DESC  , 
       CAST(CREATE_TIMESTAMP AS CHAR(50)) AS CRTTMPS,
       CAST(OBJECT_CHANGE_TIMESTAMP AS CHAR(50)) AS CHGTMPS, 
       COALESCE(CAST(DAYS_USED_COUNT AS CHAR(50)), '0') AS DAYUSEDCNT ,
       CAST(ALLOCATED_SIZE AS CHAR(50))  AS ALLC  
       INTO :prfileOneValueRec  
                                              
       FROM TABLE(QSYS2.IFS_OBJECT_STATISTICS(START_PATH_NAME => TRIM(:wsBaseFolder) , 
                                            SUBTREE_DIRECTORIES => 'YES',
                                            OMIT_LIST => TRIM(:wsOmitList) ))
       WHERE PATH_NAME = :wsBaseFolder3
       LIMIT 1
       ; 


    if (SQLCODE >= 0 and SQLCODE <> 100) ; 
       prRecReturned = 1 ; 
    endif;   

return SQLCODE ; 

end-proc;
