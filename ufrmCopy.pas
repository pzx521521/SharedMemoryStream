unit ufrmCopy;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uAllocStreamMgr;

type
  PMyRec = ^TMyRec;

  TMyRec = record
    MC: PChar;
    LX: Integer;
  end;

  TTestClass= class
    name: string;
    description: string;
    age: Integer;
  end;

  TForm1 = class(TForm)
    btnPaste: TButton;
    btnCopy: TButton;
    Button1: TButton;
    CopyNew: TButton;
    PasteNew: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure btnPasteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure CopyNewClick(Sender: TObject);
    procedure PasteNewClick(Sender: TObject);
  private
    FAllocStreamMgr: TAllocStreamMgr;
    aShareMemStreamRec: TShareMemStreamRec;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  Clipbrd;

var
  CF_PMFormat: Word;

{$R *.dfm}

procedure TForm1.btnCopyClick(Sender: TObject);
var
  aTestClass: TTestClass;
  aTestClass2: TTestClass;
  Data: THandle;
begin
  Data := GlobalAlloc(GMEM_DDESHARE, TTestClass.InstanceSize);
  if Data <> 0 then
  begin
    aTestClass := GlobalLock(Data);
    aTestClass2 := TTestClass.Create;
    try
      aTestClass2.name := '张三tadstr';
      aTestClass2.age := 10000;
      CopyMemory(aTestClass, aTestClass2, TTestClass.InstanceSize);
    finally
      GlobalUnlock(Data);
    end;
    Clipboard.Open;
    try
      Clipboard.SetAsHandle(CF_PMFormat, Data);
    finally
      Clipboard.Close;
    end;
  end;
  // GlobalFree(Data);
end;

procedure TForm1.btnPasteClick(Sender: TObject);
var
  aTestClass: TTestClass;
  Data: THandle;
begin
  if not Clipboard.HasFormat(CF_PMFormat) then
    Exit;
  Data := Clipboard.GetAsHandle(CF_PMFormat);
  ShowMessage(IntToStr(Integer(GlobalLock(Data))) );
  if Data <> 0 then
  begin
    CopyMemory(aTestClass, GlobalLock(Data), TTestClass.InstanceSize);
    try
      ShowMessageFmt('名称：%s 类型：%d', [aTestClass.name, aTestClass.age]);
    finally
      GlobalUnlock(Data);
    end;
    //Clipboard.Clear;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  si: STARTUPINFO;
  pi: PROCESS_INFORMATION;
begin
  try
    FillChar(si, SizeOf(si), 0);
    FillChar(pi, SizeOf(pi), 0);
    si.cb := SizeOf(si);
    CreateProcess('calc.exe',//不在此指定可执行文件的文件名
        nil,//命令行参数
        nil,//默认进程安全性
        nil,//默认进程安全性
        FALSE,//指定当前进程内句柄不可以被子进程继承
        CREATE_NEW_CONSOLE,//为新进程创建一个新的控制台窗口
        nil,//使用本进程的环境变量
        nil,//使用本进程的驱动器和目录
        si, pi);
  except
    //
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  aStream: TMemoryStream;
begin
  aStream :=  TMemoryStream.Create();
  try
    aStream.LoadFromFile( 'F:/1.xml');
    aShareMemStreamRec.aToken := 'para new Unit Test wer wer tre wt!';
    aShareMemStreamRec.aLabel := 'para new Unit Test!';
    aShareMemStreamRec.aBrief := '99';

    FAllocStreamMgr.SetShareMemContent(aShareMemStreamRec, aStream);
  finally
    aStream.Free;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  aStream: TMemoryStream;
begin
  aStream :=  TMemoryStream.Create();
  try
    aShareMemStreamRec := FAllocStreamMgr.GetShareMemContent(aStream);
    MessageDlg(aShareMemStreamRec.aToken + ',' + aShareMemStreamRec.aLabel + ',' +aShareMemStreamRec.aBrief , mtWarning, [mbOK], 0);
    if aStream.Size > 0 then
      aStream.SaveToFile('F:/1111.xml');
  finally
    aStream.Free;
  end;
end;

procedure TForm1.CopyNewClick(Sender: TObject);
var
  PRec: PMyRec;
  Data: THandle;
begin
  Data := GlobalAlloc(GMEM_DDESHARE, SizeOf(TMyRec));
  if Data <> 0 then
  begin
    PRec := GlobalLock(Data);
    try
      PRec.MC := '张三tadstr';
      PRec.LX := 10000;
    finally
      GlobalUnlock(Data);
    end;
    Clipboard.Open;
    try
      Clipboard.SetAsHandle(CF_PMFormat, Data);
    finally
      Clipboard.Close;
    end;
  end;
  // GlobalFree(Data);
end;

procedure TForm1.PasteNewClick(Sender: TObject);
var
  PRec: PMyRec;
  Data: THandle;
begin
  if not Clipboard.HasFormat(CF_PMFormat) then
    Exit;
  Data := Clipboard.GetAsHandle(CF_PMFormat);
  ShowMessage(IntToStr(Integer(GlobalLock(Data))) );
  if Data <> 0 then
  begin
    PRec := GlobalLock(Data);
    try
      ShowMessageFmt('名称：%s 类型：%d', [PRec.MC, PRec.LX]);
    finally
      GlobalUnlock(Data);
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  CF_PMFormat := RegisterClipboardFormat(PChar('PMSL'));
  FAllocStreamMgr := TAllocStreamMgr.Create;
end;

end.
