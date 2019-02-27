unit uAllocStreamMgr;

interface
uses
   Classes;
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

  TAllocStreamMgr = Class(TMemoryStream)
  private
    FSize: Integer;
    FHandle: THandle;
    FDataPointer: Pointer;
    FShareMemStreamRec: TShareMemStreamRec;
  public
    procedure SetShareMemContent(aRec: TShareMemStreamRec; aStream: TStream);
    function GetShareMemContent(aStream: TStream): TShareMemStreamRec;
    destructor Destroy; override;
    constructor Create;
  End;
implementation

{ TAllocStreamMgr }
uses
  Windows, SysUtils, Clipbrd;
var
  CF_PMFormat: Word;
constructor TAllocStreamMgr.Create;
begin
  CF_PMFormat := RegisterClipboardFormat(PChar('PMSL'));
end;

destructor TAllocStreamMgr.Destroy;
begin
  GlobalFree(FHandle);
  inherited;
end;

function TAllocStreamMgr.GetShareMemContent(
  aStream: TStream): TShareMemStreamRec;
var
  aHandle: THandle;
begin
  if not Clipboard.HasFormat(CF_PMFormat) then
    Exit;
  aHandle := Clipboard.GetAsHandle(CF_PMFormat);
  if aHandle <> 0 then
  begin
    FDataPointer := GlobalLock(aHandle);
    try
       //两种读取方式 通过stream 或者自己读(都可以)
       //1.通过stream
       SetPointer(FDataPointer, SizeOf(TShareMemStreamRec));
       Position := 0;
       Read(Result, SizeOf(TShareMemStreamRec));
       SetPointer(FDataPointer, Result.StreamSize + SizeOf(TShareMemStreamRec));

       //2.通过CopyMemory
       //CopyMemory(@Result, FDataPointer, SizeOf(TShareMemStreamRec));
       //SetPointer(FDataPointer, Result.StreamSize + SizeOf(TShareMemStreamRec));
       //Position := SizeOf(TShareMemStreamRec);

       aStream.CopyFrom(Self, Result.StreamSize);
    finally
      GlobalUnlock(aHandle);
    end;
  end;
end;

procedure TAllocStreamMgr.SetShareMemContent(aRec: TShareMemStreamRec; aStream:
    TStream);
var
  StreamSize: Int64;
  NewRec: TShareMemStreamRec;
begin
  StreamSize := aStream.Size;
  //这里用复制 没指针(怕别的地方释放掉)
  FShareMemStreamRec := aRec;
  FShareMemStreamRec.StreamSize :=  StreamSize;
  FSize := SizeOf(TShareMemStreamRec) +  StreamSize;

  if FHandle <> 0  then
    GlobalFree(FHandle);

  FHandle := GlobalAlloc(GMEM_DDESHARE, FSize);
  if FHandle <> 0 then
  begin
    FDataPointer := GlobalLock(FHandle);
    try
      SetPointer(FDataPointer, FSize);
      Write(FShareMemStreamRec, SizeOf(TShareMemStreamRec));
      CopyFrom(aStream, StreamSize);
    finally
      GlobalUnlock(FHandle);
    end;
    Clipboard.Open;
    try
      Clipboard.SetAsHandle(CF_PMFormat, FHandle);
    finally
      Clipboard.Close;
    end;
  end;
end;

end.
