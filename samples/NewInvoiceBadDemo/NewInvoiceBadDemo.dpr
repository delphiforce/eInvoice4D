program NewInvoiceBadDemo;

uses
  Vcl.Forms,
  FMain in 'FMain.pas' {MainForm},
  FValidateAll in 'FValidateAll.pas' {ValidateAllForm};

{$R *.res}

{$STRONGLINKTYPES ON}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
