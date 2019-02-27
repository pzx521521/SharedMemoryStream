program GlobalAlloc;

uses
  ExceptionLog,
  Forms,
  ufrmCopy in 'ufrmCopy.pas' {Form1},
  uAllocStreamMgr in 'uAllocStreamMgr.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
