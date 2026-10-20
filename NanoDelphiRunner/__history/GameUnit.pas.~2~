unit GameUnit;

interface
type
  TGame = class
  private
  d_player: TPlayer;
    d_backgroundLayers: array of TBackgroundLayer;
    d_obstacleManager: TObstacleManager;
    d_assetManager: TAssetManager;
    d_inputState: TInputState;
    d_isRunning: Boolean;
    d_score: Integer;
  public
    procedure Initialize;
    procedure Update(const ADeltaTime: Single);
    procedure Render;
    procedure StartGame;
    procedure GameOver;
    procedure RestartGame;
  end;

implementation

end.
