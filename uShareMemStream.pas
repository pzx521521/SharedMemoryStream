{ ************************************************************* }
{ 产品名称：共享内存(继承TMemoryStream)多线程安全               }
{ 单元描述：多个程序都可以读的内存                              }
{ 单元作者：pzx                                                 }
{ 创建时间：2019/02/26                                          }
{ 备    注：1.正常用读写 Read/write 如对象和Record
            2.但是流的话注意用CopyForm(注意1.2区别)
            3.不能随意释放(会导致其他程序找不到)
            4.尝试释放的原理是只剩1个exe
            5.多线程安全
            6.注意释放问题 Get数据一定要 UnMappingAndFree
                           Set数据一定要 清空前一个的Handle

 ************************************************************* }
unit uShareMemStream;

interface

uses
  SysUtils, Classes, Syncobjs, Windows;

type
  TShareMemStream = class(TMemoryStream)
  private
    FFile: THandle;
    FSize: Int64;
    FEvent: TEvent;
    FAlreadyExists: Boolean;
  protected
    property Event: TEvent read FEvent;
  public
    constructor Create(const ShareName: string; ACCESS: DWORD =
        FILE_MAP_ALL_ACCESS; ASize: Int64 = 16 * 1024 * 1024; OpenFile: Boolean =
        false);
    /// <summary>
    /// 仅仅释放该对象-> 不会释放对应的内存
    /// </summary>
    destructor Destroy; override;
    function UnMappingAndFree: Boolean;

    /// <summary>
    /// 尝试释放-> 仅仅剩余1个该Exe时才进行释放
    /// </summary>
    function UnMappingAndCanFree: Boolean;
    function GetLock(ATimeOut: DWORD = INFINITE): Boolean;
    procedure ReleaseLock();
    function GetFileHandle:THandle;
    property AlreadyExists: Boolean read FAlreadyExists;
  end;

implementation
uses
  TlHelp32, Dialogs;
procedure InitSecAttr(var sa: TSecurityAttributes; var sd: TSecurityDescriptor);
begin
  sa.nLength := sizeOf(sa);
  sa.lpSecurityDescriptor := @sd;
  sa.bInheritHandle := false;
  InitializeSecurityDescriptor(@sd, SECURITY_DESCRIPTOR_REVISION);
  SetSecurityDescriptorDacl(@sd, true, nil, false);
end;

{ TShareMem }
function TShareMemStream.UnMappingAndFree: Boolean;
begin
  Result := False;
  if Memory <> nil then
  begin
    UnmapViewOfFile(Memory);
    SetPointer(nil, 0);
    Position := 0;
  end;
  if FFile <> 0 then
  begin
    CloseHandle(FFile);
    Result := True;
    FFile := 0;
  end;
end;

function TShareMemStream.UnMappingAndCanFree: Boolean;
var
  ProcessName : string; //进程名
  FSnapshotHandle:THandle; //进程快照句柄
  FProcessEntry32:TProcessEntry32; //进程入口的结构体信息
  ContinueLoop:Boolean;
  MyHwnd:THandle;
  ExeCount: Integer;
begin
  Result := False;
  if Memory <> nil then
  begin
    UnmapViewOfFile(Memory);
    SetPointer(nil, 0);
    Position := 0;
  end;
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
    if FFile <> 0 then
    begin
      CloseHandle(FFile);
      Result := True;
      FFile := 0;
    end;
end;

constructor TShareMemStream.Create(const ShareName: string; ACCESS: DWORD =
    FILE_MAP_ALL_ACCESS; ASize: Int64 = 16 * 1024 * 1024; OpenFile: Boolean =
    false);
var
  sa: TSecurityAttributes;
  sd: TSecurityDescriptor;
  lprotect: DWORD;
  e: Integer;
begin
  FEvent := TEvent.Create(nil, false, true, ShareName +
    '_TShareMemStream_Event');
  FSize := ASize;
  InitSecAttr(sa, sd);
  ACCESS := ACCESS and (not SECTION_MAP_EXECUTE);
  if (ACCESS and FILE_MAP_WRITE) = FILE_MAP_WRITE then
    lprotect := PAGE_READWRITE
  else if (ACCESS and FILE_MAP_READ) = FILE_MAP_READ then
    lprotect := PAGE_READONLY;
  if OpenFile then
  begin
    FFile := OpenFileMapping(FILE_MAP_ALL_ACCESS, False, PChar('Global\'+ShareName));
    if FFile = 0 then
    begin
      MessageDlg('No Data Found!', mtWarning, [mbOK], 0);
      Exit;
    end;
  end
  else
  begin
    FFile := CreateFileMapping(INVALID_HANDLE_VALUE, @sa, lprotect,
      Int64Rec(FSize).Hi, Int64Rec(FSize).Lo, PChar('Global\'+ShareName));
    e := GetLastError;
    if FFile = 0 then
    begin
      raise Exception.Create('CreateFileMapping Error!');
      Exit;
    end;
    FAlreadyExists := e = ERROR_ALREADY_EXISTS;
  end;
  SetPointer(MapViewOfFile(FFile, ACCESS, 0, 0, Int64Rec(FSize).Lo),
    Int64Rec(FSize).Lo);
end;

destructor TShareMemStream.Destroy;
begin
  if FEvent <> nil then
    FEvent.Free;
  inherited Destroy;
end;

function TShareMemStream.GetFileHandle: THandle;
begin
  Result := FFile;
end;

function TShareMemStream.GetLock(ATimeOut: DWORD): Boolean;
var
  wr : TWaitResult;
begin
  wr := FEvent.WaitFor(ATimeOut);
  Result := wr = wrSignaled;
end;

procedure TShareMemStream.ReleaseLock;
begin
  FEvent.SetEvent;
end;

end.
