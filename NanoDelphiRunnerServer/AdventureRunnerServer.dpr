program AdventureRunnerServer;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.IOUtils,
  GameServerUnit, GameConfigUnit;

var
  Server: TSimpleGameServer;
  Command: string;
  LogFile: string;

procedure Log(const AText: string);
var
  Line: string;
begin
  Line := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + '  ' + AText;
  Writeln(Line);
  TFile.AppendAllText(LogFile, Line + sLineBreak);
end;

begin
  LogFile := ExtractFilePath(ParamStr(0)) + 'server.log';
  Server := nil;

  try
    Log('starting adventure runner server');

    Server := TSimpleGameServer.Create;

    if not Server.Start(TGameConfig.SERVER_PORT) then
    begin
      Log('server could not start');
      Log('port may already be used: ' + TGameConfig.SERVER_PORT.ToString);
      Readln;
      Exit;
    end;

    Log('server running on port ' + TGameConfig.SERVER_PORT.ToString);
    Log('commands: status, stop');

    repeat
      Readln(Command);
      Command := LowerCase(Trim(Command));

      if Command = 'status' then
        Log('server is running on port ' + TGameConfig.SERVER_PORT.ToString)
      else if (Command <> '') and (Command <> 'stop') then
        Log('unknown command: ' + Command);

    until Command = 'stop';

    Log('stopping server');

  except
    on E: Exception do
    begin
      try
        Log('fatal server error: ' + E.Message);
      except
        Writeln('fatal server error: ' + E.Message);
      end;

      Readln;
    end;
  end;

  try
    FreeAndNil(Server);
    Log('server closed');
  except
    on E: Exception do
      Writeln('server close error: ' + E.Message);
  end;
end.
