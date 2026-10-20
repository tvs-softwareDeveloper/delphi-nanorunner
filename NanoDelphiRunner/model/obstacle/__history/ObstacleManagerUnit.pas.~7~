unit ObstacleManagerUnit;

interface

uses
  System.Types, System.Classes, System.SysUtils, System.Generics.Collections,
  ObstacleUnit, PlayerUnit, System.Math, ErrorHandlerUnit, GameConfigUnit;

type
  TObstacleManager = class
  private
    // list that owns and stores all active obstacles
    d_obstacles: TObjectList<TObstacle>;

    // timer values used to spawn obstacles with random timing
    d_spawnTimer: Single;
    d_spawnMin: Single;
    d_spawnMax: Single;
    d_nextSpawnTime: Single;

    // default settings used when a new obstacle is created
    d_spawnPosition: TPointF;
    d_speed: Single;
    d_totalFrames: Integer;

    // potato spawn values
    d_potatoTotalFrames: Integer;
    d_potatoDistanceTimer: Single;
    d_nextPotatoDistance: Single;

    // dragon spawn values
    d_dragonDistanceTimer: Single;
    d_nextDragonDistance: Single;
    d_dragonTotalFrames: Integer;
    d_dragonSpawnMinY: Single;
    d_dragonSpawnMaxY: Single;
    d_potatoMinDistanceFromNormal: Single;

    // distance based spawn values
    d_spawnDistanceTimer: Single;
    d_nextSpawnDistance: Single;
    d_nextNetId: Integer;

    //objectpooling
    d_obstaclePool: TObjectList<TObstacle>;

    // for difficultie
    d_difficultyLevel: Integer;
    d_difficultyFactor: Single;

    d_redbullDistanceTimer: Single;
    d_nextRedbullDistance: Single;


    procedure ReturnObstacleToPool(const AObstacle: TObstacle);

    function IsPotatoSpawnSafe(const ASpawnX: Single): Boolean;

    procedure SetNextSpawnDistance;
    procedure SetNextPotatoDistance;
    procedure SetNextDragonDistance;
    procedure SetNextRedbullDistance;
    function HasObstacleInRange(const AMinX, AMaxX: Single): Boolean;
  public
    constructor Create;
    function GetObstacleFromPool: TObstacle;
    procedure RemoveObstaclesLeftOf(const AMinWorldX: Single);
    procedure UpdateRemoteOnly(const ADeltaTime: Single);
    procedure SpawnRedbullObstacle;
    procedure TakeOwnershipOfObstacles;
    procedure EnsureObstacleNearPlayer(const APlayerWorldX, AViewWidth, ASpawnY: Single);
    // potato methods
    procedure SpawnPotatoObstacle;
    procedure SetPotatoTotalFrames(const ACount: Integer);

    // dragon methods
    procedure SpawnDragonObstacle;
    procedure SetDragonTotalFrames(const ACount: Integer);
    procedure SetDragonSpawnYRange(const AMinY, AMaxY: Single);

    destructor Destroy; override;

    // prepares the manager for a new run
    procedure Initialize;

    // updates spawn timing, movement and cleanup
    procedure Update(const ADeltaTime: Single; const APlayer: TPlayer; const SpawnDragon: Boolean; const AWorldSpeed: Single; const AAllowSpecialObstacles: Boolean);

    // creates one normal obstacle
    procedure SpawnObstacle;

    // removes all active obstacles
    procedure ClearObstacles;

    // checks if any obstacle hits the player
    function CheckCollision(const APlayer: TPlayer): Boolean;

    // resets obstacles and spawn values
    procedure Reset;

    // returns active obstacles so the engine can draw them
    function GetObstacles: TObjectList<TObstacle>;

    // applies extra world movement to all obstacles
    procedure ApplyWorldScroll(const AScrollX: Single);

    // settings
    procedure SetSpawnPosition(const APos: TPointF);
    procedure SetSpeed(const ASpeed: Single);
    procedure SetTotalFrames(const ACount: Integer);
    function GetCollidingObstacle(const APlayer: TPlayer): TObstacle;
    procedure RemoveObstacle(const AObstacle: TObstacle);
    function GetNextNetId: Integer;
    procedure SetDifficultyByMeters(const AMeters: Single);
  end;

implementation

procedure TObstacleManager.UpdateRemoteOnly(const ADeltaTime: Single);
var
  i: Integer;
  obstacle: TObstacle;
begin
  try
    if ADeltaTime <= 0 then
      Exit;

    if not Assigned(d_obstacles) then
      Exit;

    // loop backwards because obstacles can be deleted during the loop
    // when deleting from the end to the start, the next indexes stay safe
    for i := d_obstacles.Count - 1 downto 0 do
    begin
      obstacle := d_obstacles[i];

      if not Assigned(obstacle) then
        Continue;

      // move remote obstacle smoothly toward the network target
      obstacle.UpdateRemoteSmooth(ADeltaTime);

      // remove obstacle when it is fully outside the screen
      if obstacle.IsOffScreen then
        ReturnObstacleToPool(d_obstacles.Extract(d_obstacles[i]));
    end;
  except
    on E: Exception do
      TErrorHandler.ReportError('obstacle remote update error: ' + E.Message);
  end;
end;

constructor TObstacleManager.Create;
begin
  inherited;

  try
    // true means this list owns the obstacle objects
    // when an obstacle is removed, it is also freed
    d_obstacles := TObjectList<TObstacle>.Create(True);

    // normal obstacle spawn range in seconds
    d_spawnMin := TGameConfig.NORMAL_OBSTACLE_SPAWN_MIN_METER;
    d_spawnMax := TGameConfig.NORMAL_OBSTACLE_SPAWN_MAX_METER;

    // default obstacle speed and animation frame count
    d_speed := TGameConfig.OBSTACLE_SPEED;
    d_totalFrames := TGameConfig.NORMAL_OBSTACLE_TOTAL_FRAMES;

    // potato starts with its own timer and spawn interval
    d_potatoDistanceTimer := 0;
    d_nextPotatoDistance := TGameConfig.POTATO_SPAWN_MIN_METER * TGameConfig.PIXELS_PER_METER;
    d_potatoMinDistanceFromNormal := TGameConfig.POTATO_MIN_DISTANCE_FROM_NORMAL;
    d_potatoTotalFrames := TGameConfig.POTATO_TOTAL_FRAMES;

    // dragon spawn settings
    d_dragonDistanceTimer := 0;
    d_nextDragonDistance := TGameConfig.DRAGON_SPAWN_MIN_METER * TGameConfig.PIXELS_PER_METER;
    d_dragonTotalFrames := TGameConfig.DRAGON_TOTAL_FRAMES;

    // dragon can spawn between these y values
    d_dragonSpawnMinY := TGameConfig.DRAGON_SPAWN_MIN_Y;
    d_dragonSpawnMaxY := TGameConfig.DRAGON_SPAWN_MAX_Y;

    // distance spawn system
    // this spawns obstacles after the world has moved a certain amount of pixels
    d_spawnDistanceTimer := 0;
    d_nextSpawnDistance := TGameConfig.OBSTACLE_SPEED;

    // used to give every obstacle a unique network id
    d_nextNetId := 1;

    d_difficultyLevel := 0;
    d_difficultyFactor := 1;

    d_redbullDistanceTimer := 0;
    SetNextRedbullDistance;

    // for object pooling
    d_obstaclePool := TObjectList<TObstacle>.Create(True);
  except
    on E: Exception do
    begin
      TErrorHandler.ReportError('obstacle manager create error: ' + E.Message);
      raise;
    end;
  end;
end;

destructor TObstacleManager.Destroy;
begin
  try
    // free the obstacle list and all obstacles inside it
    FreeAndNil(d_obstacles);
    FreeAndNil(d_obstaclePool);
  except
    on E: Exception do
      TErrorHandler.ReportError('obstacle manager destroy error: ' + E.Message);
  end;

  inherited;
end;

procedure TObstacleManager.Initialize;
begin
  try
    // start fresh with no obstacles
    ClearObstacles;

    // reset distance based spawn counter
    d_spawnDistanceTimer := 0;
    SetNextSpawnDistance;

    // reset special obstacle timers
    d_potatoDistanceTimer := 0;
    SetNextPotatoDistance;

    d_dragonDistanceTimer := 0;
    SetNextDragonDistance;
    d_difficultyLevel := 0;
    d_difficultyFactor := 1;

    d_redbullDistanceTimer := 0;
    SetNextRedbullDistance;
  except
    on E: Exception do
      TErrorHandler.ReportError('obstacle manager initialize error: ' + E.Message);
  end;
end;

procedure TObstacleManager.Update(const ADeltaTime: Single; const APlayer: TPlayer; const SpawnDragon: Boolean; const AWorldSpeed: Single; const AAllowSpecialObstacles: Boolean);
var
  i: Integer;
  obstacle: TObstacle;
begin
  try
    if ADeltaTime <= 0 then
      Exit;

    if not Assigned(d_obstacles) then
      Exit;

    if not Assigned(APlayer) then
      Exit;



    // moved distance in pixels this frame
    d_spawnDistanceTimer := d_spawnDistanceTimer + ((d_speed + Max(0, AWorldSpeed)) * ADeltaTime);
    d_potatoDistanceTimer := d_potatoDistanceTimer + ((d_speed + Max(0, AWorldSpeed)) * ADeltaTime);
    d_dragonDistanceTimer := d_dragonDistanceTimer + ((d_speed + Max(0, AWorldSpeed)) * ADeltaTime);
    d_redbullDistanceTimer := d_redbullDistanceTimer + ((d_speed + Max(0, AWorldSpeed)) * ADeltaTime);

    // normal obstacle
    if d_spawnDistanceTimer >= d_nextSpawnDistance then
    begin
      SpawnObstacle;
      d_spawnDistanceTimer := d_spawnDistanceTimer - d_nextSpawnDistance;
      SetNextSpawnDistance;
    end;

    if AAllowSpecialObstacles then
    begin
      if d_potatoDistanceTimer >= d_nextPotatoDistance then
      begin
        SpawnPotatoObstacle;
        d_potatoDistanceTimer := d_potatoDistanceTimer - d_nextPotatoDistance;
        SetNextPotatoDistance;
      end;

      if d_redbullDistanceTimer >= d_nextRedbullDistance then
      begin
       SpawnRedbullObstacle;
       d_redbullDistanceTimer := d_redbullDistanceTimer - d_nextRedbullDistance;
        SetNextRedbullDistance;
      end;

     if SpawnDragon then
      begin
       if d_dragonDistanceTimer >= d_nextDragonDistance then
       begin
         SpawnDragonObstacle;
         d_dragonDistanceTimer := d_dragonDistanceTimer - d_nextDragonDistance;
         SetNextDragonDistance;
        end;
     end
     else
       d_dragonDistanceTimer := 0;
    end
    else
    begin
     d_potatoDistanceTimer := 0;
     d_dragonDistanceTimer := 0;

    end;

    // loop backwards so deleting obstacles does not break the loop
    for i := d_obstacles.Count - 1 downto 0 do
    begin
      obstacle := d_obstacles[i];

      if not Assigned(obstacle) then
        Continue;

      // update obstacle movement and animation
      obstacle.Update(ADeltaTime);

      // delete obstacle when it is fully outside the screen
      if obstacle.IsOffScreen then
        ReturnObstacleToPool(d_obstacles.Extract(d_obstacles[i]));
    end;
  except
    on E: Exception do
      TErrorHandler.ReportError('obstacle manager update error: ' + E.Message);
  end;
end;

procedure TObstacleManager.TakeOwnershipOfObstacles;
var
  I: Integer;
  Obstacle: TObstacle;
  HighestNetId: Integer;
begin
  try
    if not Assigned(d_obstacles) then
      Exit;

    HighestNetId := 0;

    // this client is now host, so all remote obstacles become local obstacles
    for I := 0 to d_obstacles.Count - 1 do
    begin
      Obstacle := d_obstacles[I];

      if not Assigned(Obstacle) then
        Continue;

      // stop following old network target data
      Obstacle.ChangeState(osMoving);

      // remember the highest network id so new obstacles do not reuse old ids
      if Obstacle.GetNetId > HighestNetId then
        HighestNetId := Obstacle.GetNetId;
    end;

    // make sure new obstacle ids are higher than the old synced ids
    if d_nextNetId <= HighestNetId then
      d_nextNetId := HighestNetId + 1;
  except
    on E: Exception do
      TErrorHandler.ReportError('take ownership of obstacles error: ' + E.Message);
  end;
end;

procedure TObstacleManager.SpawnObstacle;
var
  o: TObstacle;
begin
  o := nil;

  try
    if not Assigned(d_obstacles) then
      Exit;

    // create a normal obstacle
    o := GetObstacleFromPool;

    // give the obstacle a unique id for network sync
    o.SetNetId(GetNextNetId);

    // place the obstacle at the spawn position and give it normal speed
    o.Initialize(d_spawnPosition, d_speed);

    // set how many animation frames it has
    o.SetTotalFrames(d_totalFrames);

    // for alien obstacle.
    if d_totalFrames = TGameConfig.MOON_ALIEN_TOTAL_FRAMES then
    begin
      o.SetKind(okAlien);
      o.SetSize(TGameConfig.MOON_ALIEN_WIDTH, TGameConfig.MOON_ALIEN_HEIGHT);
      o.SetPosition(TPointF.Create(
        d_spawnPosition.X,
        d_spawnPosition.Y + TGameConfig.MOON_ALIEN_Y_OFFSET
      ));
   end;

    // add it to the active obstacle list
    d_obstacles.Add(o);
    o := nil;
  except
    on E: Exception do
    begin
      o.Free;
      TErrorHandler.ReportError('spawn obstacle error: ' + E.Message);
    end;
  end;
end;

procedure TObstacleManager.ClearObstacles;
var
  I: Integer;
begin
  for I := d_obstacles.Count - 1 downto 0 do
    ReturnObstacleToPool(d_obstacles.Extract(d_obstacles[I]));
end;

function TObstacleManager.CheckCollision(const APlayer: TPlayer): Boolean;
begin
  Result := False;

  try
    // true when a colliding obstacle is found
    Result := Assigned(GetCollidingObstacle(APlayer));
  except
    on E: Exception do
      TErrorHandler.ReportError('check collision error: ' + E.Message);
  end;
end;

procedure TObstacleManager.Reset;
begin
  try
    // used when starting or restarting the game
    ClearObstacles;

    // reset normal obstacle distance spawn
    d_spawnDistanceTimer := 0;
    SetNextSpawnDistance;

    // reset special obstacle timers
    d_potatoDistanceTimer := 0;
    SetNextPotatoDistance;

    d_dragonDistanceTimer := 0;
    SetNextDragonDistance;
    d_difficultyLevel := 0;
    d_difficultyFactor := 1;
    d_redbullDistanceTimer := 0;
    SetNextRedbullDistance;
  except
    on E: Exception do
      TErrorHandler.ReportError('obstacle manager reset error: ' + E.Message);
  end;
end;

procedure TObstacleManager.ApplyWorldScroll(const AScrollX: Single);
var
  obstacle: TObstacle;
begin
  try
    if not Assigned(d_obstacles) then
      Exit;

    // when the player stays near the middle, the world moves instead
    // obstacles need the same offset so they stay in the right place
    for obstacle in d_obstacles do
    begin
      if Assigned(obstacle) then
        obstacle.AddOffsetX(-AScrollX);
    end;
  except
    on E: Exception do
      TErrorHandler.ReportError('apply world scroll error: ' + E.Message);
  end;
end;

procedure TObstacleManager.SpawnPotatoObstacle;
var
  o: TObstacle;
  leftObs, rightObs: TObstacle;
  obstacle: TObstacle;
  leftX, rightX: Single;
  bestLeftDist, bestRightDist: Single;
begin
  o := nil;

  try
    if not Assigned(d_obstacles) then
      Exit;

//    if not IsPotatoSpawnSafe(d_spawnPosition.X) then
//      Exit;

    leftObs := nil;
    rightObs := nil;

    // start with very large distances
    // any real obstacle distance will be smaller than this
    bestLeftDist := 999999;
    bestRightDist := 999999;

    // find the closest normal obstacle on the left and right side
    for obstacle in d_obstacles do
    begin
      if not Assigned(obstacle) then
        Continue;

      // potato should only use normal obstacles as points around it
      if obstacle.GetKind <> okNormal then
        Continue;

      // obstacle is left from the spawn position
      if obstacle.GetPosition.X < d_spawnPosition.X then
      begin
        // distance from spawn point to the left obstacle
        // smaller distance means this obstacle is closer
        if (d_spawnPosition.X - obstacle.GetPosition.X) < bestLeftDist then
        begin
          bestLeftDist := d_spawnPosition.X - obstacle.GetPosition.X;
          leftObs := obstacle;
        end;
      end
      else
      begin
        // obstacle is right from the spawn position
        // distance is obstacle x minus spawn x
        if (obstacle.GetPosition.X - d_spawnPosition.X) < bestRightDist then
        begin
          bestRightDist := obstacle.GetPosition.X - d_spawnPosition.X;
          rightObs := obstacle;
        end;
      end;
    end;

    // if there is a normal obstacle on both sides, place potato in the middle
    if Assigned(leftObs) and Assigned(rightObs) then
    begin
      leftX := leftObs.GetPosition.X;
      rightX := rightObs.GetPosition.X;

      o := GetObstacleFromPool;
      o.SetNetId(GetNextNetId);

      // middle position between two x values
      // left x plus right x divided by 2 gives the center between them
      o.Initialize(
        TPointF.Create((leftX + rightX) / 2, d_spawnPosition.Y),
        d_speed
      );

      o.SetKind(okPotato);
      o.SetTotalFrames(d_potatoTotalFrames);

      d_obstacles.Add(o);
      o := nil;
    end
    else
    begin
      // fallback when there are not enough normal obstacles yet
      o := GetObstacleFromPool;
      o.SetNetId(GetNextNetId);
      o.Initialize(d_spawnPosition, d_speed);
      o.SetKind(okPotato);
      o.SetTotalFrames(d_potatoTotalFrames);

      d_obstacles.Add(o);
      o := nil;
    end;
  except
    on E: Exception do
    begin
      o.Free;
      TErrorHandler.ReportError('spawn potato obstacle error: ' + E.Message);
    end;
  end;
end;

procedure TObstacleManager.RemoveObstacle(const AObstacle: TObstacle);
var
  RemovedObstacle: TObstacle;
begin
  try
    if not Assigned(d_obstacles) then
      Exit;

    if not Assigned(AObstacle) then
      Exit;

    AObstacle.MarkRemoved;

    RemovedObstacle := d_obstacles.Extract(AObstacle);

    if Assigned(RemovedObstacle) then
      ReturnObstacleToPool(RemovedObstacle);
  except
    on E: Exception do
      TErrorHandler.ReportError('remove obstacle error: ' + E.Message);
  end;
end;

procedure TObstacleManager.SpawnDragonObstacle;
var
  o: TObstacle;
  y: Single;
begin
  o := nil;

  try
    if not Assigned(d_obstacles) then
      Exit;

    // choose random y position between min and max
    // random gives a value from 0 to almost 1
    // max y minus min y gives the full range
    // min y plus random range gives a value inside that range
    y := d_dragonSpawnMinY + Random * (d_dragonSpawnMaxY - d_dragonSpawnMinY);

    o := GetObstacleFromPool;
    o.SetNetId(GetNextNetId);

    // dragon starts at spawn x and random y
    // dragon speed is two times normal speed
    o.Initialize(TPointF.Create(d_spawnPosition.X, y), d_speed * TGameConfig.DRAGON_SPEED_MULTIPLIER);

    o.SetKind(okDragon);
    o.SetTotalFrames(d_dragonTotalFrames);

    // dragon is larger than normal obstacles
    o.SetSize(TGameConfig.DRAGON_WIDTH, TGameConfig.DRAGON_HEIGHT);

    d_obstacles.Add(o);
    o := nil;
  except
    on E: Exception do
    begin
      o.Free;
      TErrorHandler.ReportError('spawn dragon obstacle error: ' + E.Message);
    end;
  end;
end;

function TObstacleManager.IsPotatoSpawnSafe(const ASpawnX: Single): Boolean;
var
  obstacle: TObstacle;
begin
  Result := True;

  try
    if not Assigned(d_obstacles) then
      Exit;

    // check distance between potato spawn x and normal obstacles
    for obstacle in d_obstacles do
    begin
      if not Assigned(obstacle) then
        Continue;

      if obstacle.GetKind = okNormal then
      begin
        // abs removes minus sign
        // this gives distance no matter which side the obstacle is on
        if Abs(obstacle.GetPosition.X - ASpawnX) < d_potatoMinDistanceFromNormal then
          Exit(False);
      end;
    end;
  except
    on E: Exception do
    begin
      TErrorHandler.ReportError('potato spawn safety check error: ' + E.Message);
      Result := False;
    end;
  end;
end;

procedure TObstacleManager.RemoveObstaclesLeftOf(const AMinWorldX: Single);
var
  I: Integer;
  O: TObstacle;
  P: TPointF;
  S: TSizeF;
begin
  try
    if not Assigned(d_obstacles) then
      Exit;

    for I := d_obstacles.Count - 1 downto 0 do
    begin
      O := d_obstacles[I];

      if not Assigned(O) then
        Continue;

      P := O.GetPosition;
      S := O.GetSize;

      if P.X + S.Width < AMinWorldX then
        ReturnObstacleToPool(d_obstacles.Extract(d_obstacles[i]));
    end;
  except
    on E: Exception do
      TErrorHandler.ReportError('remove old obstacles error: ' + E.Message);
  end;
end;

procedure TObstacleManager.SpawnRedbullObstacle;
var
  o: TObstacle;
begin
  o := nil;

  try
    if not Assigned(d_obstacles) then
      Exit;

    o := GetObstacleFromPool;
    o.SetNetId(GetNextNetId);

    o.Initialize(
      d_spawnPosition,
      d_speed * TGameConfig.REDBULL_SPEED_MULTIPLIER
    );

    o.SetKind(okRedbull);
    o.SetSize(TGameConfig.REDBULL_WIDTH, TGameConfig.REDBULL_HEIGHT);

    if d_totalFrames = TGameConfig.MOON_ALIEN_TOTAL_FRAMES then
    o.SetPosition(TPointF.Create(
      d_spawnPosition.X,
      d_spawnPosition.Y + TGameConfig.MOON_REDBULL_Y_OFFSET
    ));

    o.SetTotalFrames(1);

    d_obstacles.Add(o);
    o := nil;
  except
    on E: Exception do
    begin
      o.Free;
      TErrorHandler.ReportError('spawn redbull obstacle error: ' + E.Message);
    end;
  end;
end;

//////////////////////////////////////////////////////////////////// setters getters ////////////////////////////////////////////////////////////////////////////////

function TObstacleManager.GetCollidingObstacle(const APlayer: TPlayer): TObstacle;
var
  obstacle: TObstacle;
  hitBox: TRectF;
  playerBounds: TRectF;
begin
  Result := nil;

  try
    if not Assigned(d_obstacles) then
      Exit;

    if not Assigned(APlayer) then
      Exit;



    // get player collision rectangle once
    playerBounds := APlayer.GetBounds;

    // check every obstacle loop
    for obstacle in d_obstacles do
    begin
      if not Assigned(obstacle) then
        Continue;

      if not obstacle.CanCollide then
        Continue;

      // some obstacles have more than one hitbox
      // each hitbox is checked against the player
      for hitBox in obstacle.GetHitBoxes do
      begin
        // if player rectangle touches an obstacle hitbox, return that obstacle
        if playerBounds.IntersectsWith(hitBox) then
          Exit(obstacle);
      end;
    end;
  except
    on E: Exception do
      TErrorHandler.ReportError('get colliding obstacle error: ' + E.Message);
  end;
end;

function TObstacleManager.GetObstacles: TObjectList<TObstacle>;
begin
  Result := nil;

  try
    // the game engine uses this list to draw obstacles
    Result := d_obstacles;
  except
    on E: Exception do
      TErrorHandler.ReportError('get obstacles error: ' + E.Message);
  end;
end;

procedure TObstacleManager.SetSpawnPosition(const APos: TPointF);
begin
  try
    d_spawnPosition := APos;
  except
    on E: Exception do
      TErrorHandler.ReportError('set spawn position error: ' + E.Message);
  end;
end;

procedure TObstacleManager.SetSpeed(const ASpeed: Single);
begin
  try
    d_speed := Max(1, ASpeed);
  except
    on E: Exception do
      TErrorHandler.ReportError('set speed error: ' + E.Message);
  end;
end;

procedure TObstacleManager.SetTotalFrames(const ACount: Integer);
begin
  try
    d_totalFrames := Max(1, ACount);
  except
    on E: Exception do
      TErrorHandler.ReportError('set total frames error: ' + E.Message);
  end;
end;

procedure TObstacleManager.SetPotatoTotalFrames(const ACount: Integer);
begin
  try
    d_potatoTotalFrames := Max(1, ACount);
  except
    on E: Exception do
      TErrorHandler.ReportError('set potato total frames error: ' + E.Message);
  end;
end;

procedure TObstacleManager.SetDragonTotalFrames(const ACount: Integer);
begin
  try
    d_dragonTotalFrames := Max(1, ACount);
  except
    on E: Exception do
      TErrorHandler.ReportError('set dragon total frames error: ' + E.Message);
  end;
end;

procedure TObstacleManager.SetDragonSpawnYRange(const AMinY, AMaxY: Single);
begin
  try
    d_dragonSpawnMinY := AMinY;
    d_dragonSpawnMaxY := Max(AMinY, AMaxY);
  except
    on E: Exception do
      TErrorHandler.ReportError('set dragon spawn y range error: ' + E.Message);
  end;
end;

function TObstacleManager.GetNextNetId: Integer;
begin
  Result := 1;

  try
    // return current id and then increase it for the next obstacle
    Result := d_nextNetId;
    Inc(d_nextNetId);

    if d_nextNetId = MaxInt then
      d_nextNetId := 1;
  except
    on E: Exception do
      TErrorHandler.ReportError('get next net id error: ' + E.Message);
  end;
end;

//pooling
function TObstacleManager.GetObstacleFromPool: TObstacle;
begin
  if d_obstaclePool.Count > 0 then
  begin
    Result := d_obstaclePool.Last;
    d_obstaclePool.Extract(Result);
  end
  else
    Result := TObstacle.Create;
end;

procedure TObstacleManager.ReturnObstacleToPool(const AObstacle: TObstacle);
begin
  if not Assigned(AObstacle) then
    Exit;

  AObstacle.MarkRemoved;

  if d_obstaclePool.Count < TGameConfig.OBSTACLE_POOL_MAX then
    d_obstaclePool.Add(AObstacle)
  else
    AObstacle.Free;
end;

procedure TObstacleManager.SetNextSpawnDistance;
var
  MeterDistance: Single;
  MinMeter: Single;
  MaxMeter: Single;
begin
  try
    MinMeter := TGameConfig.NORMAL_OBSTACLE_SPAWN_MIN_METER * d_difficultyFactor;
    MaxMeter := TGameConfig.NORMAL_OBSTACLE_SPAWN_MAX_METER * d_difficultyFactor;

    if MinMeter < 2 then
      MinMeter := 2;

    if MaxMeter < MinMeter + 1 then
      MaxMeter := MinMeter + 1;

    MeterDistance := MinMeter + Random * (MaxMeter - MinMeter);

    d_nextSpawnDistance := MeterDistance * TGameConfig.PIXELS_PER_METER;

    if d_nextSpawnDistance < 1 then
      d_nextSpawnDistance := 1;
  except
    on E: Exception do
      TErrorHandler.ReportError('set next spawn distance error: ' + E.Message);
  end;
end;

procedure TObstacleManager.SetNextPotatoDistance;
var
  MeterDistance: Single;
begin
  try
    MeterDistance :=
      TGameConfig.POTATO_SPAWN_MIN_METER +
      Random * (TGameConfig.POTATO_SPAWN_MAX_METER - TGameConfig.POTATO_SPAWN_MIN_METER);

    d_nextPotatoDistance := MeterDistance * TGameConfig.PIXELS_PER_METER;

    if d_nextPotatoDistance < 1 then
      d_nextPotatoDistance := 1;
  except
    on E: Exception do
      TErrorHandler.ReportError('set next potato distance error: ' + E.Message);
  end;
end;

procedure TObstacleManager.SetNextDragonDistance;
var
  MeterDistance: Single;
begin
  try
    MeterDistance :=
      TGameConfig.DRAGON_SPAWN_MIN_METER +
      Random * (TGameConfig.DRAGON_SPAWN_MAX_METER - TGameConfig.DRAGON_SPAWN_MIN_METER);

    d_nextDragonDistance := MeterDistance * TGameConfig.PIXELS_PER_METER;

    if d_nextDragonDistance < 1 then
      d_nextDragonDistance := 1;
  except
    on E: Exception do
      TErrorHandler.ReportError('set next dragon distance error: ' + E.Message);
  end;
end;

procedure TObstacleManager.SetDifficultyByMeters(const AMeters: Single);
begin
  try
    d_difficultyLevel := Trunc(AMeters / 50);

    d_difficultyFactor := 1 - (d_difficultyLevel * TGameConfig.DIFFICULTY);

    if d_difficultyFactor < 0.45 then
      d_difficultyFactor := 0.45;
  except
    on E: Exception do
      TErrorHandler.ReportError('set difficulty by meters error: ' + E.Message);
  end;
end;


procedure TObstacleManager.SetNextRedbullDistance;
var
  MeterDistance: Single;
begin
  try
    MeterDistance :=
      TGameConfig.REDBULL_SPAWN_MIN_METER +
      Random * (TGameConfig.REDBULL_SPAWN_MAX_METER - TGameConfig.REDBULL_SPAWN_MIN_METER);

    d_nextRedbullDistance := MeterDistance * TGameConfig.PIXELS_PER_METER;

    if d_nextRedbullDistance < 1 then
      d_nextRedbullDistance := 1;
  except
    on E: Exception do
      TErrorHandler.ReportError('set next redbull distance error: ' + E.Message);
  end;
end;

function TObstacleManager.HasObstacleInRange(const AMinX, AMaxX: Single): Boolean;
var
  Obstacle: TObstacle;
  P: TPointF;
begin
  Result := False;

  try
    for Obstacle in d_obstacles do
    begin
      if not Assigned(Obstacle) then
        Continue;

      if Obstacle.CanBeRemoved then
        Continue;

      P := Obstacle.GetPosition;

      if (P.X >= AMinX) and (P.X <= AMaxX) then
        Exit(True);
    end;
  except
    on E: Exception do
      TErrorHandler.ReportError('has obstacle in range error: ' + E.Message);
  end;
end;

procedure TObstacleManager.EnsureObstacleNearPlayer(const APlayerWorldX, AViewWidth, ASpawnY: Single);
var
  CheckStartX: Single;
  CheckEndX: Single;
  SpawnX: Single;
  OldSpawnPos: TPointF;
  MeterDistance: Single;
  PixelDistance: Single;
begin
  try
    if not Assigned(d_obstacles) then
      Exit;

    CheckStartX := APlayerWorldX + AViewWidth;
    CheckEndX := CheckStartX + (TGameConfig.NORMAL_OBSTACLE_SPAWN_MAX_METER * TGameConfig.PIXELS_PER_METER);

    if HasObstacleInRange(CheckStartX, CheckEndX) then
      Exit;

    MeterDistance :=
      TGameConfig.NORMAL_OBSTACLE_SPAWN_MIN_METER +
      Random * (TGameConfig.NORMAL_OBSTACLE_SPAWN_MAX_METER - TGameConfig.NORMAL_OBSTACLE_SPAWN_MIN_METER);

    PixelDistance := MeterDistance * TGameConfig.PIXELS_PER_METER;

    if PixelDistance < TGameConfig.OBSTACLE_MIN_SPAWN_GAP then
      PixelDistance := TGameConfig.OBSTACLE_MIN_SPAWN_GAP;

    SpawnX := CheckStartX + PixelDistance;

    OldSpawnPos := d_spawnPosition;

    d_spawnPosition := TPointF.Create(SpawnX, ASpawnY);
    SpawnObstacle;

    d_spawnPosition := OldSpawnPos;
  except
    on E: Exception do
      TErrorHandler.ReportError('ensure obstacle near player error: ' + E.Message);
  end;
end;

end.
