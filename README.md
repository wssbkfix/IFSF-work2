# IFSF-work2

This is a second in a series of using table functions to view the IFS. The first in this series took the approach of creating a file from runing the qss...  table function to retrieve IFS information.  This first approach maybe best if one is not sure what exact data it is that they are looking for. In the case where you know the data you are looking for, then the approach where a program uses an existing SQL statement to read information about the IFS might be better. This is the premis of this approach. There are two major pieces of code. First the regular RPG program that manages the subfile interface and calls the appropriate sub procedures in the second program that contains embedded SQL statements. Below are two major divisions of the documentation. First is the documentation of the SQL embedded statements. Second I will document the program that manages the subfile interface and how that program interfaces with the SQL component. One could argue there is a third component, and this is the source data. That is true. The source data will be covered first as a summary of the data used and potentially what other data could be used. 

## The source data 
The SQL function QSYS2.IFS_OBJECT_STATISTICS: 
As might be expeced, the best way to get information about this is to go straight to the IBM docs. The syntax is a bit strange but not hard to master.
	[link to QSYS2.IFS table Function](https://www.ibm.com/docs/en/i/7.4?topic=services-ifs-object-statistics-table-function))
### Filtering component
You probably don't want every IFS  object out there so you will need to filter it. This is done by the filter that is right after the from statement. There are 3 components of this filter 
1- START_PATH_NAME =>   This is where you would put the path to start any searches.  Think of it as a CD command if you were using WRKLNK.
2- SUBTREE_DIRECTORIES => You simple put YES or NO. Just want to see the parents, then this limits the search. 
3- OMIT_LIST =>  There may be numerous entries that you want to avoid. I installed some NPM installations and did not want those folders to show up in the display. A very handy feature. 
  note: you can leave the keywords out and just enter the values. They are positional 
  Where statement. I uses this to further filter the entries. 

### Field list. 
Best to go to IBM's documentation to get the full list
I use the following Fields 

PATH_NAME 
OBJECT_TYPE 
TEXT_DESCRIPTION 
CCSID 
CREATE_TIMESTAMP 
DAYS_USED_COUNT 
ALLOCATED_SIZE 

There are many others. If you were to build your own utility, you could include other values. 

## SQL Program 
Name: SHWIFS2S 
The program has 3 major divisions. 
1-Sub procedures to list the IFS folders. 
2-Sub procedures to list files within a IFS folder 
3-Sub procedures to show the attributs of a single file. 
4-Sub procedure that setup the START_PATH_NAME, OMIT_LIST, and WHERE clause. 

I'll just list the modules in order of function. This will give a good understanding of what the program does 
### modules to list the IFS folders 
GETDIRLISTCSR - declares the READDIR cursor. 
GETDIRLISTOPEN - opens the cursor declared above. 
GETDIRLISTCLOSE - closes the cursor           
GETDIRLISTFETCH - Fetches the data based on the READDIR declaration. I use global variables to use with the START_PATH_NAME, and the WHERE clause.           
            
### modles to list the files in a folder 
GETFILELISTCSR
GETFILELISTOPEN 
GETFILELISTCLOSE                        
GETFILELISTFETCH                      

### modules to list the attributes in a file 
GETONERECORDSELECT

A cursor is not need since the program is only reading one record. A simple select statement will do. 
             
### modules to setup the filters 
SETSQLBASEFOLDER - sets up the SET_PATH_NAME in the cursor that reads folders. The wsBaseFolder global variable is set. This makes it availabe to all subprocedures.       
SETSQLFILTER - set the WHERE clause in the READDIR cursor. The wsfilter global variable is set. This makes it availabe to all subprocedures. 
SETSQLOMITLIST - sets the OMIT_LIST in all query statements. The wsOmitList global variable is set. This makes it availabe to all subprocedures.
SETSQLBASEFOLDER2 - sets the SET_PATH_NAME in cursor that reads files in a folder.       
SETSQLFILTER2 - sets the WHERE clause in the READFILE cursor. The wsfilter2 global variable is set. This makes it availabe to all subprocedures. 
SETSQLBASEFOLDER3 - sets the WHERE clause in the SELECT statement for listing the attributes of one file.      

## RPG program SHWIFS2 
This program manages to subfile interface, sets the filters correctly, and calls the SQL procecures in the correct order. 

### modules in the RPG program 

#### Entry procedure 
SETDEFAULTVALUES - sets values that will populate START_PATH_NAME, OMIT_LIST

#### modules for Read folder screen 
PROCESSDIRECTORIES 
  INIT1 - Calls subprocedures to set values
  LOADSUBFILEDIR
  SETFILTER - sets the values that will populate the wsFilter in the SQL modules.
  READSUBFILE
  RESETCURSOR
       
#### modles for Read files screen 
PROCESSFILES - calls routines that populate the file list. 
  INIT2 
  SETFILTER2
  LOADSUBFILEFILES                   
  READSUBFILE2                     
  RESETCURSOR2                       
     

#### modules for list attribute for file screen 
PROCESSFILE3
  INIT3                               
  LOADSUBFILEFILESONE                          
                             
                   

                     
                     
                                      



         
          
          
             
 
          
         


