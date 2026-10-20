unit ErrorHandlerUnit;

interface

uses
  System.SysUtils;

type
  TErrorMessageEvent = procedure(const AError: string) of object;

  TErrorHandler = class
  private
    class var FOnError: TErrorMessageEvent;
  public
    class procedure ReportError(const AError: string); static;
    class property OnError: TErrorMessageEvent read FOnError write FOnError;
  end;

implementation

class procedure TErrorHandler.ReportError(const AError: string);
begin
  if Assigned(FOnError) then
    FOnError(AError);
end;

end.
