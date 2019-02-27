unit uShareMem;

interface
uses
  Windows, TLHelp32, SysUtils;
type
  TShareMemUtil<T> = class
     class var fileHandle: THandle;
     class function GetOrCreateObject(size: Cardinal): Pointer;
     class function CreatShareMem(size: Cardinal): Pointer;
     class procedure UnMappingAndCanFree(aT: Pointer); static;
  end;
implementation
const
  ShareMemName = 'PMShareMemName';

{ TShareMemUtil<T> }
class function TShareMemUtil<T>.CreatShareMem(size: Cardinal): Pointer;
begin
  fileHandle := CreateFileMapping($FFFFFFFF, nil, PAGE_READWRITE, 0, size, PChar(shareMemName));
  Result := MapViewOfFile(fileHandle,FILE_MAP_ALL_ACCESS, 0, 0, size);
end;

class function TShareMemUtil<T>.GetOrCreateObject(size: Cardinal): Pointer;
begin
  //先OpenFile
  fileHandle := OpenFileMapping(FILE_MAP_ALL_ACCESS,false,pchar(shareMemName));
  if self.FileHandle <> 0 then
    Result := MapViewOfFile(fileHandle,FILE_MAP_ALL_ACCESS, 0, 0, size)
  else
  begin
    Result := CreatShareMem(size);
  end;
end;

class procedure TShareMemUtil<T>.UnMappingAndCanFree(aT: Pointer);
var
  ProcessName : string; //进程名
  FSnapshotHandle:THandle; //进程快照句柄
  FProcessEntry32:TProcessEntry32; //进程入口的结构体信息
  ContinueLoop:Boolean;
  MyHwnd:THandle;
  ExeCount: Integer;
begin
  if Assigned(aT) then
     UnmapViewOfFile(aT);
  //如果没有其他程序引用-> 即这是最后一个打开的程序
  ExeCount := 0;
  FSnapshotHandle:=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0); //创建一个进程快照
  FProcessEntry32.dwSize:=Sizeof(FProcessEntry32);
  ContinueLoop:=Process32First(FSnapshotHandle,FProcessEntry32); //得到系统中第一个进程
  //循环例举
  while ContinueLoop do
  begin
    ProcessName := FProcessEntry32.szExeFile;
    if(SameText(ProcessName, ExtractFileName(ParamStr(0)))) then
      Inc(ExeCount);
    ContinueLoop:=Process32Next(FSnapshotHandle,FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle); // 释放快照句柄
  if ExeCount = 1 then
     CloseHandle(fileHandle);
end;

end.
