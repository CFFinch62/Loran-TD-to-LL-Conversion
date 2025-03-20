#include "stdafx.h"
#include "common.h"

double str2dbl(CString initString)
{
	TCHAR temp[30];

	_tcscpy(temp,initString);
	return(_tcstod(temp,NULL));

}

CString dbl2str(double initDouble)
{
	CString strOut;

	strOut.Format("%lf",initDouble);
	return(strOut);
}



CFile* OpenFileRead(CString initFilename)
{

CString ExceptionMessage;
CFile *fpFile;

TRY
	{
	fpFile =  new CFile(initFilename.GetBuffer(40),/*CFile::modeCreate | */CFile::shareDenyNone| CFile::modeRead | CFile::modeNoTruncate); //Open if exists but do not truncate, otherwise create a new file
	initFilename.ReleaseBuffer();
	}

	CATCH(CFileException, e)
	{
		if( e->m_cause == CFileException::fileNotFound )
			{
			ExceptionMessage="ERROR: Cannot find ";
			ExceptionMessage+=initFilename;
			
			ExceptionMessage+="\n";
			fpFile=NULL;
	        AfxMessageBox(ExceptionMessage);
			}

		if( e->m_cause == CFileException::accessDenied )
			{
			ExceptionMessage="ERROR: Access to ";
			ExceptionMessage+=initFilename;
 			ExceptionMessage+="denied \n";
			fpFile=NULL;
			AfxMessageBox(ExceptionMessage);
			}

		
			if( e->m_cause == CFileException::badPath)
			{
			ExceptionMessage="ERROR: Access to ";
			ExceptionMessage+=initFilename;
 			ExceptionMessage+="denied - Bad path \n";
			fpFile=NULL;
			AfxMessageBox(ExceptionMessage);
			}

			if( e->m_cause == CFileException::tooManyOpenFiles  )
			{
			ExceptionMessage="ERROR: Access to ";
			ExceptionMessage+=initFilename;
 			ExceptionMessage+="denied - Too many open files \n";
			fpFile=NULL;
			AfxMessageBox(ExceptionMessage);
			}

			if( e->m_cause == CFileException::invalidFile  )
			{
			ExceptionMessage="ERROR: Access to ";
			ExceptionMessage+=initFilename;
 			ExceptionMessage+="denied - Invalid files \n";
			fpFile=NULL;
			AfxMessageBox(ExceptionMessage);
			}

			if( e->m_cause == CFileException::removeCurrentDir )
			{
			ExceptionMessage="ERROR: Access to ";
			ExceptionMessage+=initFilename;
 			ExceptionMessage+="denied \n";
			fpFile=NULL;
			AfxMessageBox(ExceptionMessage);
			}

			if( e->m_cause == CFileException::directoryFull )
			{
			ExceptionMessage="ERROR: Access to ";
			ExceptionMessage+=initFilename;
 			ExceptionMessage+="denied - Directory full \n";
			fpFile=NULL;
			AfxMessageBox(ExceptionMessage);
			}

			if( e->m_cause == CFileException::badSeek )
			{
			ExceptionMessage="ERROR: Access to ";
			ExceptionMessage+=initFilename;
 			ExceptionMessage+="denied - Bad seek \n";
			fpFile=NULL;
			AfxMessageBox(ExceptionMessage);
			}

			if( e->m_cause == CFileException::hardIO )
			{
			ExceptionMessage="ERROR: Access to ";
			ExceptionMessage+=initFilename;
 			ExceptionMessage+="denied - Hard IO \n";
			fpFile=NULL;
			AfxMessageBox(ExceptionMessage);
			}

			if( e->m_cause == CFileException::sharingViolation )
			{
			ExceptionMessage="ERROR: Access to ";
			ExceptionMessage+=initFilename;
 			ExceptionMessage+="denied - Sharing Violation \n";
			fpFile=NULL;
			AfxMessageBox(ExceptionMessage);
			}

			if( e->m_cause == CFileException::lockViolation )
			{
			ExceptionMessage="ERROR: Access to ";
			ExceptionMessage+=initFilename;
 			ExceptionMessage+="denied - Lock Violation\n";
			fpFile=NULL;
			AfxMessageBox(ExceptionMessage);
			}

			if( e->m_cause == CFileException::diskFull  )
			{
			ExceptionMessage="ERROR: Access to ";
			ExceptionMessage+=initFilename;
 			ExceptionMessage+="denied - Disk is Full\n";
			fpFile=NULL;
			AfxMessageBox(ExceptionMessage);
			}

			if( e->m_cause == CFileException::endOfFile     )
			{
			ExceptionMessage="ERROR: Access to ";
			ExceptionMessage+=initFilename;
 			ExceptionMessage+="denied - End of File \n";
			fpFile=NULL;
			AfxMessageBox(ExceptionMessage);
			}
	
	}
	END_CATCH

return (fpFile);
}

CFile* OpenFileWrite(CString initFilename)
{
CString ExceptionMessage;
CFile *fpFile;
	

TRY
	{
	fpFile =  new CFile(initFilename.GetBuffer(40),CFile::modeCreate | CFile::modeWrite );//|File::modeNoTruncate); //Open if exists but do not truncate, otherwise create a new file
	initFilename.ReleaseBuffer();
	}

	CATCH(CFileException, e)
	{
			if( e->m_cause == CFileException::fileNotFound )
			{
			ExceptionMessage="ERROR: Cannot create ";
			ExceptionMessage+=initFilename;
			
			ExceptionMessage+="\n";
	        AfxMessageBox(ExceptionMessage);
			}

			if( e->m_cause == CFileException::accessDenied )
			{
			ExceptionMessage="ERROR: Access to ";
			ExceptionMessage+=initFilename;
			
			ExceptionMessage+="denied \n";
			AfxMessageBox(ExceptionMessage);
			}
		
			if( e->m_cause == CFileException::badPath)
			{
			ExceptionMessage="ERROR: Access to ";
			ExceptionMessage+=initFilename;
 			ExceptionMessage+="denied - Bad Path \n";
			fpFile=NULL;
			AfxMessageBox(ExceptionMessage);
			}

			if( e->m_cause == CFileException::tooManyOpenFiles  )
			{
			ExceptionMessage="ERROR: Access to ";
			ExceptionMessage+=initFilename;
 			ExceptionMessage+="denied - Too many open files \n";
			fpFile=NULL;
			AfxMessageBox(ExceptionMessage);
			}

			if( e->m_cause == CFileException::invalidFile  )
			{
			ExceptionMessage="ERROR: Access to ";
			ExceptionMessage+=initFilename;
 			ExceptionMessage+="denied - Invalid file \n";
			fpFile=NULL;
			AfxMessageBox(ExceptionMessage);
			}

			if( e->m_cause == CFileException::removeCurrentDir )
			{
			ExceptionMessage="ERROR: Access to ";
			ExceptionMessage+=initFilename;
 			ExceptionMessage+="denied \n";
			fpFile=NULL;
			AfxMessageBox(ExceptionMessage);
			}

			if( e->m_cause == CFileException::directoryFull )
			{
			ExceptionMessage="ERROR: Access to ";
			ExceptionMessage+=initFilename;
 			ExceptionMessage+="denied - Directory full \n";
			fpFile=NULL;
			AfxMessageBox(ExceptionMessage);
			}

			if( e->m_cause == CFileException::badSeek )
			{
			ExceptionMessage="ERROR: Access to ";
			ExceptionMessage+=initFilename;
 			ExceptionMessage+="denied - Bad seek \n";
			fpFile=NULL;
			AfxMessageBox(ExceptionMessage);
			}

			if( e->m_cause == CFileException::hardIO )
			{
			ExceptionMessage="ERROR: Access to ";
			ExceptionMessage+=initFilename;
 			ExceptionMessage+="denied - Hard IO \n";
			fpFile=NULL;
			AfxMessageBox(ExceptionMessage);
			}

			if( e->m_cause == CFileException::sharingViolation )
			{
			ExceptionMessage="ERROR: Access to ";
			ExceptionMessage+=initFilename;
 			ExceptionMessage+="denied - Sharing Violation \n";
			fpFile=NULL;
			AfxMessageBox(ExceptionMessage);
			}

			if( e->m_cause == CFileException::lockViolation )
			{
			ExceptionMessage="ERROR: Access to ";
			ExceptionMessage+=initFilename;
 			ExceptionMessage+="denied - Lock Violation\n";
			fpFile=NULL;
			AfxMessageBox(ExceptionMessage);
			}

			if( e->m_cause == CFileException::diskFull  )
			{
			ExceptionMessage="ERROR: Access to ";
			ExceptionMessage+=initFilename;
 			ExceptionMessage+="denied - Disk is Full\n";
			fpFile=NULL;
			AfxMessageBox(ExceptionMessage);
			}

			if( e->m_cause == CFileException::endOfFile     )
			{
			ExceptionMessage="ERROR: Access to ";
			ExceptionMessage+=initFilename;
 			ExceptionMessage+="denied - End of File \n";
			fpFile=NULL;
			AfxMessageBox(ExceptionMessage);
			}

	
	}
	END_CATCH

fpFile->SeekToEnd();
return fpFile;
}


