(*----------------------------------------------------
PS：“写入程序”解除映射关系，关闭内存映射文件对“读取程序”的影响。
1) 写入程序解除映射关系，不影响读取程序的读取操作关闭内存映射文件，会
   影响读取程序的读取操作
2) 解除映射关系与关闭内存映射文件无顺序要求，及时不解除映射关系也可直
   接关闭内存映射文件
3) 两个程序通讯时，要使用sendmessage,同步操作，而不是postmessage,
   防止前者已关闭内存映射文件，而后者还没读取。


CreateFileMapping（）的使用心得
HANDLE CreateFileMapping(
HANDLE hFile,                       //物理文件句柄
LPSECURITY_ATTRIBUTES lpAttributes, //安全设置
DWORD flProtect,                    //保护设置
DWORD dwMaximumSizeHigh,            //高位文件大小
DWORD dwMaximumSizeLow,             //低位文件大小
LPCTSTR lpName                      //共享内存名称
);
--------------------------------------------------------*)
unit ufrmShareMem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uShareMemStreamMgr;

type
  //共享内存结构：
  PShareMem = ^TShareMem;
  TShareMem = Record
    id:string[10];
    name:string[20];
    age:Integer;
    MemSize: Cardinal;
    astream: TFileStream;
  end;

  TMyClass = class
  public
    name: string;
    haha: string;
    age: Integer;
    function erqerewqr: string;
  end;

  TfrmShareMem = class(TForm)
    Memo1: TMemo;
    BtnCreatFile: TButton;
    BtnOpenFile: TButton;
    BtnBuildMapping: TButton;
    BtnWriteInfoIntoMem: TButton;
    BtnRemoveTheBindding: TButton;
    BtnCloseTheMappingFile: TButton;
    BtnReadTheInfo: TButton;
    BtnClear: TButton;
    btnCopy: TButton;
    BtnPast: TButton;
    CopyNew: TButton;
    PasteNew: TButton;
    FreeWhenClose: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnOpenFileClick(Sender: TObject);
    procedure BtnCreatFileClick(Sender: TObject);
    procedure BtnBuildMappingClick(Sender: TObject);
    procedure BtnWriteInfoIntoMemClick(Sender: TObject);
    procedure BtnRemoveTheBinddingClick(Sender: TObject);
    procedure BtnCloseTheMappingFileClick(Sender: TObject);
    procedure BtnReadTheInfoClick(Sender: TObject);
    procedure BtnClearClick(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure BtnPastClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure CopyNewClick(Sender: TObject);
    procedure FreeWhenCloseClick(Sender: TObject);
    procedure PasteNewClick(Sender: TObject);
  private
    //基本变量：
    aShareMemStreamRec: TShareMemStreamRec;
    FShareMemStreamMgr: TShareMemStreamMgr;
    shareMemName:string; //共享内存名
    fileHandle : THandle;//内存映射文件句柄
    pUserInfoShareMem : PShareMem;//指向共享内存的指针
    aUserInfoShareMem : TShareMem;//指向共享内存的指针
    aUserInfoShareMem2 : TShareMem;//指向共享内存的指针
    aMyClass: TMyClass;
  public
    /// <summary>
    /// 创建“内存映射文件”
    /// </summary>
    procedure CreatShareMem;
    /// <summary>
    /// 建立映射关系
    ///将“内存映射文件”与“应用程序地址空间”建立映射关系
    /// </summary>
    procedure BiuldTheMapping;
    /// <summary>
    /// 写入信息
    /// </summary>
    procedure WriteInfoIntoMem;
    /// <summary>
    /// 解除映射关系
    ///  解除“内存映射文件”与“应用程序地址空间”的映射关系
    /// </summary>
    procedure RemoveTheBindding;
    /// <summary>
    /// 关闭“内存映射文件”
    /// </summary>
    procedure CloseTheMappingFile;
    /// <summary>
    /// 打开“内存映射文件”
    /// </summary>
    procedure OpenTheMappingMemFile;
    /// <summary>
    /// 读取信息
    /// </summary>
    procedure ReadTheInfo;

  end;

var
  frmShareMem: TfrmShareMem;

implementation
uses
  uShareMem, uShareMemStream;
{$R *.dfm}

procedure TfrmShareMem.FormDestroy(Sender: TObject);
begin
  FShareMemStreamMgr.Free;
end;

procedure TfrmShareMem.FormCreate(Sender: TObject);
begin
  shareMemName := 'PMTestShareMapping';
  FShareMemStreamMgr := TShareMemStreamMgr.Create;
end;

{ TfrmShareMem }

procedure TfrmShareMem.BiuldTheMapping;
begin
  //将“内存映射文件”与“应用程序地址空间”建立映射关系
  aMyClass := MapViewOfFile(fileHandle,FILE_MAP_ALL_ACCESS, 0, 0, TMyClass.InstanceSize);
  if aMyClass <> nil then
  begin
     Self.Memo1.Lines.Add('已成功建立映射关系！');
  end;
end;

procedure TfrmShareMem.CloseTheMappingFile;
begin
  //关闭内存映射文件
  if fileHandle<> 0 then
     CloseHandle(fileHandle);
  Self.Memo1.Lines.Add('已成功关闭内存映射文件！');
end;

procedure TfrmShareMem.CreatShareMem;
begin
  //创建“内存映射文件”
  fileHandle:=CreateFileMapping($FFFFFFFF, nil, PAGE_READWRITE, 0, TMyClass.InstanceSize, PChar(shareMemName));
  if fileHandle <> 0 then
  begin
    Self.Memo1.Lines.Add('已成功创建内存映射文件！');
  end;
end;

procedure TfrmShareMem.OpenTheMappingMemFile;
begin
  // 打开“内存映射文件”
  fileHandle:=OpenFileMapping(FILE_MAP_ALL_ACCESS,false,pchar(shareMemName));
  if self.FileHandle <> 0 then
  begin
    Self.Memo1.Lines.Add('已成功打开内存映射文件！')
  end;
end;

procedure TfrmShareMem.ReadTheInfo;
var
  userInfoStr: string;
begin
  //读取信息
  if aMyClass <> nil then
  begin
    userInfoStr:='共享内存中获取的MyClass信息如下:'+#13#10;
    userInfoStr:=userInfoStr+'MyClassId号：'+aMyClass.name+#13#10;
    userInfoStr:=userInfoStr+'MyClass姓名：'+aMyClass.haha+#13#10;
    userInfoStr:=userInfoStr+'MyClass年龄：'+IntToStr(aMyClass.age);
    Self.Memo1.Lines.Add(userInfoStr);
  end;
end;

procedure TfrmShareMem.RemoveTheBindding;
begin
  //解除“内存映射文件”与“应用程序地址空间”的映射关系
  if aMyClass<> nil then
     UnmapViewOfFile(aMyClass);
  Self.Memo1.Lines.Add('已成功解除映射关系！');
end;

procedure TfrmShareMem.WriteInfoIntoMem;
begin
  //写入信息
  aMyClass.name := 'para';
  aMyClass.haha := 'test';
  aMyClass.age := 11;
  Self.Memo1.Lines.Add('写入信息！');
end;

procedure TfrmShareMem.BtnBuildMappingClick(Sender: TObject);
begin
  BiuldTheMapping;
end;

procedure TfrmShareMem.BtnClearClick(Sender: TObject);
begin
  Memo1.Clear;
end;

procedure TfrmShareMem.BtnCloseTheMappingFileClick(Sender: TObject);
begin
  CloseTheMappingFile;
end;

procedure TfrmShareMem.BtnCreatFileClick(Sender: TObject);
begin
  CreatShareMem;
end;

procedure TfrmShareMem.BtnOpenFileClick(Sender: TObject);
begin
  OpenTheMappingMemFile;
end;

procedure TfrmShareMem.BtnReadTheInfoClick(Sender: TObject);
begin
  ReadTheInfo
end;

procedure TfrmShareMem.BtnRemoveTheBinddingClick(Sender: TObject);
begin
  RemoveTheBindding;
end;

procedure TfrmShareMem.BtnWriteInfoIntoMemClick(Sender: TObject);
begin
  WriteInfoIntoMem;
end;

procedure TfrmShareMem.btnCopyClick(Sender: TObject);
begin
  CreatShareMem;
  BiuldTheMapping;
  WriteInfoIntoMem;
end;

procedure TfrmShareMem.BtnPastClick(Sender: TObject);
begin
  OpenTheMappingMemFile;
  BiuldTheMapping;
  ReadTheInfo;
end;

procedure TfrmShareMem.Button1Click(Sender: TObject);
var
  ms : TShareMemStream;
  aStream: TMemoryStream;
begin
  aStream :=  TMemoryStream.Create();
  aStream.LoadFromFile( 'F:/1.xml');
  ms := TShareMemStream.Create('Globaltest', FILE_MAP_ALL_ACCESS, 99);
  if (ms.Memory <> nil)(*and(ms.AlreadyExists)*) then
  //如果创建失败Memory指针是空指针
  //AlreadyExists表示已经存在了,也就是之前被别人(也许是别的进程)创建过了.
  begin
    aUserInfoShareMem.name := 'para new Unit Test wer wer tre wt!';
    aUserInfoShareMem.id := 'para new Unit Test!';
    aUserInfoShareMem.age := 99;
    aUserInfoShareMem.MemSize :=  aStream.Size;
    //获取锁,多个进程线程访问安全访问
    if ms.GetLock(INFINITE) then
    begin
      Self.Memo1.Lines.Add('TShareMem size: ' + IntToStr(sizeof(aUserInfoShareMem)));
      ms.write(aUserInfoShareMem, SizeOf(aUserInfoShareMem));
      Self.Memo1.Lines.Add('aStream size: ' + IntToStr(aStream.Size));
      ms.CopyFrom(aStream, aStream.Size);
      //释放锁
      ms.ReleaseLock();
    end;
  end;
  //ms.UnMappingAndFree;
  ms.free;
  aStream.Free;
end;

procedure TfrmShareMem.Button2Click(Sender: TObject);
var
  ms : TShareMemStream;
  aStream: TMemoryStream;
begin
  aStream := TMemoryStream.Create;
  ms := TShareMemStream.Create('Globaltest', FILE_MAP_ALL_ACCESS, 4096);
  if (ms.Memory <> nil)(*and(ms.AlreadyExists)*) then
  //如果创建失败Memory指针是空指针
  //AlreadyExists表示已经存在了,也就是之前被别人(也许是别的进程)创建过了.
  begin
    //获取锁,多个进程线程访问安全访问
    if ms.GetLock(INFINITE) then
    begin
      Self.Memo1.Lines.Add('TShareMem size: ' + IntToStr(sizeof(aUserInfoShareMem2)));
      ms.Read(aUserInfoShareMem2, SizeOf(aUserInfoShareMem2));
      Self.Memo1.Lines.Add('aStream size: ' + IntToStr(aUserInfoShareMem2.MemSize));
      aStream.CopyFrom(ms, aUserInfoShareMem2.MemSize);
      //释放锁
      ms.ReleaseLock();
      aStream.SaveToFile('F:/1111.xml');
    end;
  end;
  ms.UnMappingAndFree;
  ms.free;
  aStream.Free;
end;

procedure TfrmShareMem.Button3Click(Sender: TObject);
var
  ms:TMemoryStream;
begin
  aUserInfoShareMem.name := 'para new Unit Test wer wer tre wt!';
  aUserInfoShareMem.id := 'para new Unit Test!';
  aUserInfoShareMem.age := 99;
  ms:=TMemoryStream.Create;
  ms.Write(aUserInfoShareMem,SizeOf(aUserInfoShareMem));

  ms.Position:=0;
  ms.Read(aUserInfoShareMem2,SizeOf(aUserInfoShareMem2));
  ms.Free;
  ShowMessage(aUserInfoShareMem2.name);
end;

procedure TfrmShareMem.Button4Click(Sender: TObject);
var
  aStream: TMemoryStream;
begin
  aStream :=  TMemoryStream.Create();
  try
    aStream.LoadFromFile( 'F:/1.xml');
    aShareMemStreamRec.aToken := 'para new Unit Test wer wer tre wt!';
    aShareMemStreamRec.aLabel := 'para new Unit Test!';
    aShareMemStreamRec.aBrief := '99';

    FShareMemStreamMgr.SetShareMemContent(@aShareMemStreamRec, aStream);
  finally
    aStream.Free;
  end;
end;

procedure TfrmShareMem.Button5Click(Sender: TObject);
var
  aStream: TMemoryStream;
begin
  aStream :=  TMemoryStream.Create();
  try
    aShareMemStreamRec := FShareMemStreamMgr.GetShareMemContent(aStream);
    MessageDlg(aShareMemStreamRec.aToken + ',' + aShareMemStreamRec.aLabel + ',' +aShareMemStreamRec.aBrief , mtWarning, [mbOK], 0);
    if aStream.Size > 0 then
      aStream.SaveToFile('F:/1111.xml');
  finally
    aStream.Free;
  end;
end;

procedure TfrmShareMem.CopyNewClick(Sender: TObject);
var
  aStream: TStream;
begin
  try
    pUserInfoShareMem := (TShareMemUtil<TShareMem>.GetOrCreateObject(sizeof(TShareMem) + aStream.Size));
    pUserInfoShareMem.name := 'para new Unit Test wer wer tre wt!';
    pUserInfoShareMem.id := 'para new Unit Test!';
    pUserInfoShareMem.age := 99;
    pUserInfoShareMem.MemSize := (aStream.Size);
    Self.Memo1.Lines.Add('TShareMem size: ' + IntToStr(sizeof(TShareMem)));
    Self.Memo1.Lines.Add('aStream size: ' + IntToStr(aStream.Size));
    //复制流
    CopyMemory((@pUserInfoShareMem.astream), aStream, aStream.Size)
  finally
    aStream.Free;
  end;
end;

procedure TfrmShareMem.FreeWhenCloseClick(Sender: TObject);
begin
  TShareMemUtil<TShareMem>.UnMappingAndCanFree(pUserInfoShareMem);
end;

procedure TfrmShareMem.PasteNewClick(Sender: TObject);
var
  aStream: TStream;
begin
  pUserInfoShareMem := (TShareMemUtil<TShareMem>.GetOrCreateObject(sizeof(TShareMem)+529));
  Self.Memo1.Lines.Add(pUserInfoShareMem.name);
  Self.Memo1.Lines.Add(pUserInfoShareMem.id);
  Self.Memo1.Lines.Add(IntToStr(pUserInfoShareMem.age));
  Self.Memo1.Lines.Add(IntToStr(pUserInfoShareMem.MemSize));
  aStream:= TStream.Create;
  try
    CopyMemory(aStream, @pUserInfoShareMem.astream, pUserInfoShareMem.MemSize);
    MessageDlg(IntToStr(astream.Size), mtWarning, [mbOK], 0);
  finally
    aStream.Free;
  end;
end;

{ TMyClass }

function TMyClass.erqerewqr: string;
begin

end;

end.
