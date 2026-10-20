unit frameGame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, FMX.Controls, FMX.Forms,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Types, FMX.Objects;

type
  TFrame1 = class(TFrame)
    procedure FrameMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
  private
    d_onJump: TNotifyEvent;
  public
    property OnJump: TNotifyEvent read d_onJump write d_onJump;
  end;

implementation

{$R *.fmx}

procedure TFrame1.FrameMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if Assigned(d_onJump) then
    d_onJump(Self);
end;
//procedure TFrame1.AfterConstruction;
//begin
//  inherited;
//  Self.OnMouseDown := FrameMouseDown;
//end;

end.
