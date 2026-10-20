unit InputStateUnit;

interface

uses
  System.Classes, System.UITypes;

type
  TInputState = class
  private
    d_jumpPressed: Boolean;
    d_jumpQueued: Boolean;
    d_moveLeft: Boolean;
    d_moveRight: Boolean;
    d_moveUp: Boolean;
    d_moveDown: Boolean;
  public
    procedure Reset;
    procedure KeyDown(const AKey: Word);
    procedure KeyUp(const AKey: Word);
    procedure MouseDown(const Button: TMouseButton);

    function ConsumeJump: Boolean;
    function IsMovingLeft: Boolean;
    function IsMovingRight: Boolean;
    function isMovingDown: Boolean;
    function isMovingUp: Boolean;

  end;

implementation

procedure TInputState.Reset;
begin
  d_jumpPressed := False;
  d_jumpQueued := False;
  d_moveLeft := False;
  d_moveRight := False;
  d_moveUp := False;
  d_moveDown := False;
end;

procedure TInputState.KeyDown(const AKey: Word);
begin
  if AKey = vkSpace then
    d_jumpQueued := True;

  if AKey = vkLeft then
    d_moveLeft := True;

  if AKey = vkRight then
    d_moveRight := True;

  if AKey = vkUp then
    d_moveUp := True;

  if AKey = vkDown then
    d_moveDown := True;
end;

procedure TInputState.KeyUp(const AKey: Word);
begin
  if AKey = vkLeft then
    d_moveLeft := False;

  if AKey = vkRight then
    d_moveRight := False;

  if AKey = vkUp then
    d_moveUp := False;

  if AKey = vkDown then
    d_moveDown := False;
end;

procedure TInputState.MouseDown(const Button: TMouseButton);
begin
  if Button = TMouseButton.mbLeft then
    d_jumpQueued := True;
end;

function TInputState.ConsumeJump: Boolean;
begin
  if d_jumpQueued then
  begin
    d_jumpPressed := True;
    d_jumpQueued := False;
  end;

  Result := d_jumpPressed;
  d_jumpPressed := False;
end;

function TInputState.IsMovingLeft: Boolean;
begin
  Result := d_moveLeft;
end;

function TInputState.IsMovingRight: Boolean;
begin
  Result := d_moveRight;
end;

function TInputState.IsMovingUp: Boolean;
begin
  Result := d_moveUp;
end;

function TInputState.IsMovingDown: Boolean;
begin
  Result := d_moveDown;
end;

end.
