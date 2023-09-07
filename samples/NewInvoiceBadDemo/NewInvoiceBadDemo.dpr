program NewInvoiceBadDemo;

uses
  Vcl.Forms,
  FMain in 'FMain.pas' {MainForm};

{$R *.res}

{$STRONGLINKTYPES ON}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
