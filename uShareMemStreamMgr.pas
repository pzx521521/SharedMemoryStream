{ ************************************************************* }
{ 产品名称：共享内存->管理类                                    }
{ 单元描述：多个程序都可以读的内存                              }
{ 单元作者：pzx                                                 }
{ 创建时间：2019/02/26                                          }
{ 备    注：1. CloseHandle 一定要注意 防止内存泄漏
              1.1 Get的时候  应该要 CloseHandle(UnMappingAndFree)
              1.2 Set的时候 一定要  Close上一次的Handle
              1.3 Destroy的时候  一定要  CloseHandle
 ************************************************************* }
unit uShareMemStreamMgr;

interface
uses
  uShareMemStream, Classes;
type
  //记录信息-> 默认开头为大小
  //结尾为流
  TShareMemStreamRec = record
    //这里一定要用 PChar
    aToken, aLabel, aBrief: PChar;
    Stream: TStream;
    StreamSize: Int64;
  end;
  PShareMemStreamRec = ^TShareMemStreamRec;

  TShareMemStreamMgr = class
  private
     FSize: Int64;
     FShareMemStream: TShareMemStream;
     FShareMemStreamRec: TShareMemStreamRec;
  public
    procedure SetShareMemContent(PRec: PShareMemStreamRec; aStream: TStream);
    function GetShareMemContent(aStream: TStream): TShareMemStreamRec;
    destructor Destroy; override;
    constructor Create;
  end;
implementation
uses
  Windows;
Const CST_PM_SL_Clipboard_SS = 'PM_SL_Clipboard_SS';
{ TShareMemStreamMgr }

constructor TShareMemStreamMgr.Create;
begin

end;

destructor TShareMemStreamMgr.Destroy;
begin
  if FShareMemStream <> nil then
  begin
    // 完全释放-> 会导致其他程序找不到粘贴板内容
    FShareMemStream.UnMappingAndFree;
    FShareMemStream.Free;
  end;
  inherited;
end;

function TShareMemStreamMgr.GetShareMemContent(aStream: TStream):
    TShareMemStreamRec;
var
  aShareMemStream: TShareMemStream;
begin
  //分两次搞 第一次先搞出流的大小
  aShareMemStream := TShareMemStream.Create(CST_PM_SL_Clipboard_SS, FILE_MAP_ALL_ACCESS, SizeOf(Result), True);
  try
    if (aShareMemStream.Memory <> nil)(*and(ms.AlreadyExists)*) then
    //如果创建失败Memory指针是空指针
    //AlreadyExists表示已经存在了,也就是之前被别人(也许是别的进程)创建过了.
    begin
      //获取锁,多个进程线程访问安全访问
      if aShareMemStream.GetLock(INFINITE) then
      begin
        aShareMemStream.Read(Result, SizeOf(Result));
        //释放锁
        aShareMemStream.ReleaseLock();
      end;
    end;
  finally
    aShareMemStream.UnMappingAndFree;
    aShareMemStream.free;
  end;
  //第二次先搞出流
  aShareMemStream := TShareMemStream.Create(CST_PM_SL_Clipboard_SS, FILE_MAP_ALL_ACCESS, SizeOf(Result)+Result.StreamSize);
  try
    if (aShareMemStream.Memory <> nil)(*and(ms.AlreadyExists)*) then
    //如果创建失败Memory指针是空指针
    //AlreadyExists表示已经存在了,也就是之前被别人(也许是别的进程)创建过了.
    begin
      //获取锁,多个进程线程访问安全访问
      if aShareMemStream.GetLock(INFINITE) then
      begin
        aShareMemStream.Read(Result, SizeOf(Result));
        aStream.CopyFrom(aShareMemStream, Result.StreamSize);
        //释放锁
        aShareMemStream.ReleaseLock();
      end;
    end;
  finally
    aShareMemStream.UnMappingAndFree;
    aShareMemStream.free;
  end;
end;

procedure TShareMemStreamMgr.SetShareMemContent(PRec: PShareMemStreamRec;
    aStream: TStream);
var
  StreamSize: Int64;
begin
  StreamSize := aStream.Size;
  //这里用复制 没指针(怕别的地方释放掉)
  FShareMemStreamRec := PRec^;
  FShareMemStreamRec.StreamSize :=  StreamSize;
  FSize := SizeOf(TShareMemStreamRec) +  StreamSize;

  //注意不能释放-> 其他要读到  -> Set之前要先释放上一次的东西
  if FShareMemStream <> nil then
  begin
    FShareMemStream.UnMappingAndFree;
    FShareMemStream.Free;
  end;

  FShareMemStream := TShareMemStream.Create(CST_PM_SL_Clipboard_SS, FILE_MAP_ALL_ACCESS, FSize);
  try
    //这里有应对多线程的锁
    if FShareMemStream.GetLock(INFINITE) then
    begin
      //把这两个东西放在共享内存中
      FShareMemStream.write(FShareMemStreamRec, SizeOf(FShareMemStreamRec));
      FShareMemStream.CopyFrom(aStream, aStream.Size);
      //释放锁
      FShareMemStream.ReleaseLock();
    end;
  finally

  end;
end;

end.
