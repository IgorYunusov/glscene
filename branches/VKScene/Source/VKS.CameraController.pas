//
// VKScene project based on GLScene library, http://glscene.sourceforge.net 
//

{

  Component for animating camera movement.
  Can be used to zoom in/out, for linear movement, orbiting and Google Earth - like "fly-to"
  Main purpose was the SafeOrbitAndZoomToPos method, the others are usable as well
       
     
     
}


//IMPORTANT!
//You should block user GUI access to the GLSceneViewer
//while movement is being done, check the AllowUserAction property!
//Block user GUI access while AllowUserAction is false to avoid behaviour errors
//simply put
//if GLCameraController1.AllowUserAction then
//do whatever you want on mouse move, form wheel etc

// methods and properties are explained in the interface section (through comments)
// additional comments might apear in implementation section where needed

unit VKS.CameraController;

interface

uses
  System.Classes, System.SysUtils, System.Math, System.Contnrs,
  //VKS
  VKS.Scene, VKS.VectorGeometry,
  VKS.SmoothNavigator, VKS.VectorTypes;

type

  EGLCameraController = class(Exception);

  // Forward declaration of the camera controller main class
  TVKCameraController = class;

  // Forward declaration of a generic camera job
  TVKCameraJob = class;

  TVKCameraJobList = class(TObjectList)
  private
    FController : TVKCameraController;
    function GetCameraJob(const AIndex: integer): TVKCameraJob;
    procedure SetCameraJob(const AIndex: integer; const Value: TVKCameraJob);
  public
    constructor Create(AController: TVKCameraController);
    function Add(ACameraJob: TVKCameraJob): integer;
    property Items[const AIndex: integer]: TVKCameraJob read GetCameraJob write SetCameraJob; default;
    function First: TVKCameraJob;
    function Last: TVKCameraJob;
  end;

  TVKCameraJob = class(TObject)
  private
    FJoblist : TVKCameraJobList;
  protected
    FAbort         : boolean;
    FInit          : boolean;
    FRunning       : Boolean;

    FElapsedTime   : Double;
    FDeltaTime      : Double;
    FStartTime     : Double;
    FProceedTime   : Double;
  public
    constructor Create(const AJoblist : TVKCameraJobList); virtual;
    destructor Destroy; override;

    procedure Abort;
    procedure Step; virtual; abstract;
    procedure Init; virtual; abstract;

    property Running: Boolean read FRunning write FRunning;
    property ElapsedTime: Double read FElapsedTime write FElapsedTime;
    property StartTime: Double read FStartTime write FStartTime;
    property ProceedTime: Double read FProceedTime write FProceedTime;
  end;

  TVKMoveToPosJob = class(TVKCameraJob)
  private
    FInitialPos    : TVector;
    FFinalPos      : TVector;
  public
    X : Double;
    Y : Double;
    Z : Double;
    Time : Double;
    procedure Step; override;
    procedure Init; override;

    // Properties.
    property InitialPos: TVector read FInitialPos;
    property FinalPos: TVector read FFinalPos;    
  end;

  TVKZoomToDistanceJob = class(TVKCameraJob)
  private
    FInitialPos    : TVector;
    FFinalPos      : TVector;
  public
    Distance : Double;
    Time : Double;
    procedure Step; override;
    procedure Init; override;

    // Properties.
    property InitialPos: TVector read FInitialPos;
    property FinalPos: TVector read FFinalPos;
  end;

  TVKOrbitToPosJob = class(TVKCameraJob)
  private
    FFinalPos: TVector; // Yep, FFinalPos is stored in relative coordinates.
    FRotateSpeed: TVector2f;
    FCameraUpVector: TVector;

    // Absolute Coordinates, can even be not normalized by radius.
    // Procesed in Init, not used anywhere else.
    FTargetPosition: TVector;
    FTime : Double;
  public
    procedure Step; override;
    procedure Init; override;

    // Properties.
    property RotateSpeed: TVector2f read FRotateSpeed;
    property CameraUpVector: TVector read FCameraUpVector;
    property TargetPosition: TVector read FTargetPosition;
    property FinalPos: TVector read FFinalPos;
    property Time: Double read FTime;
  end;

  TVKSmoothOrbitToPos = class(TVKOrbitToPosJob)
  private
    FCutoffAngle: Single;
    FNeedToRecalculateZoom: Boolean;
    FShouldBeMatrix: TMatrix;
    FSmoothNavigator: TVKNavigatorSmoothChangeVector;
  public
    constructor Create(const AJoblist : TVKCameraJobList); override;
    procedure Step; override;
    property CutoffAngle: Single read FCutoffAngle write FCutoffAngle;
    property NeedToRecalculateZoom: Boolean read FNeedToRecalculateZoom write FNeedToRecalculateZoom;
  end;

  TVKOrbitToPosAdvJob = class(TVKCameraJob)
  private
    FInitialPos    : TVector;
    FFinalPos      : TVector;
    FInitialUp     : TVector;
    FInitialDir    : TVector;

    FRotAxis : TVector;
    FAngle   : Double;
  public
    X : Double;
    Y : Double;
    Z : Double;
    Time : Double;
    PreferUpAxis : Boolean;
    procedure Step; override;
    procedure Init; override;

    // Properties.
    property InitialPos: TVector read FInitialPos;
    property InitialUp: TVector read FInitialUp;
    property InitialDir: TVector read FInitialDir;
    property FinalPos: TVector read FFinalPos;
  end;

  TVKSmoothOrbitToPosAdvJob = class(TVKOrbitToPosAdvJob)
  private
    FPreviousPosition: TVector;
    FSmoothNavigator: TVKNavigatorSmoothChangeVector;
    FRestoreUpVector: Boolean;
  public
    procedure Step; override;
    procedure Init; override;
  end;

  TVKCameraJobEvent = procedure(Sender : TVKCameraJob) of object;

  TVKCameraController = class(TComponent)
  private
    // Objects.
    FCameraJobList : TVKCameraJobList;
    FCamera: TVKBaseSceneObject;
    FCameraTarget: TVKBaseSceneObject;

    // Events.
    FOnJobAdded: TVKCameraJobEvent;
    FOnJobFinished: TVKCameraJobEvent;
    FOnJobStep: TVKCameraJobEvent;

    //fields used by SafeOrbitAndZoomToPos
    FsoSafeDist, FsoTimeToSafePlacement, FsoTimeToOrbit, FsoTimeToZoomBackIn:double;

    //private methods
    //used to test whether camera and cadencer are assigned
    //Extended = true -> will test also for Camera.TargetObject
    procedure CheckAssignments(Extended: boolean);

    //after AdjustScene the Camera.DepthofView will be modified
    //if you want to zoom back in from GUI
    //you should use something like
    //  Camera.DepthOfView:=2*Camera.DistanceToTarget+2*camera.TargetObject.BoundingSphereRadius;
    procedure SetOnJobAdded(const Value: TVKCameraJobEvent);
    procedure SetOnJobFinished(const Value: TVKCameraJobEvent);
    procedure SetOnJobStep(const Value: TVKCameraJobEvent);
    procedure SetCamera(const Value: TVKBaseSceneObject);
    procedure SetCameraTarget(const Value: TVKBaseSceneObject);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    // Constructor.
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;

    //methods
    //linear movement from current pos
    function MoveToPos(x,y,z,time:double): TVKMoveToPosJob;

    //orbiting from current pos to the pos where
    //the camera points at the camera.targetObject TROUGH the given point
    //it will not move to the given point(!), use SafeOrbitAndZoomToPos instead
    //there has to be a camera.targetObject assigned!
    function OrbitToPos(x,y,z,time:double): TVKOrbitToPosJob;

    // Same as OrbitToPos(), but makes use of SmoothNavigator to make
    // sure all camera movements are smooth.
    function OrbitToPosSmooth(const ATargetPosition: TVector; const ATime: Double;
      const ASmoothNavigator: TVKNavigatorSmoothChangeVector; const AFNeedToRecalculateZoom: Boolean;
      const ACameraUpVector: PVector = nil): TVKSmoothOrbitToPos;

    //Same function as OrbitToPos but support all camera states
    //PreferUpAxis value is to setup if function use Camera Up based rotation axis
    //instead of Camera direction based rotation axis when destination and camera
    //position are opposite from Camera Target
    function OrbitToPosAdvanced(x,y,z,time:double; PreferUpAxis: Boolean = True): TVKOrbitToPosAdvJob;


    // Same as OrbitToPosAdvanced(), but makes use of SmoothNavigator to make
    // sure all camera movements are smooth.
    function OrbitToPosAdvancedSmooth(const x,y,z, time: double;
      const ASmoothNavigator: TVKNavigatorSmoothChangeVector;
      const PreferUpAxis: Boolean = True): TVKSmoothOrbitToPosAdvJob;

    //zooms in/out by moving to the given distance from camera.targetObject
    //there has to be a camera.targetObject assigned!
    function ZoomToDistance(Distance,Time:double): TVKZoomToDistanceJob;

    //google earth - like "fly-to"
    // = zoom out to safe distance, orbit, and then zoom in to the given point
    //there has to be a camera.targetObject assigned!
    procedure SafeOrbitAndZoomToPos(x,y,z:double);

    //Dan Bartlett said in the GLScene newsgroup that it might be a good idea
    //to introduce ability to stop movement and return control to user
    //here it is
    procedure StopMovement;

    // Called by the cadencer to animate the camera
    procedure Step(const deltaTime, newTime: Double);

    property CameraJobList: TVKCameraJobList read FCameraJobList;
  published
    // Assign a Moving object (usually a TVKCamera).
    property Camera: TVKBaseSceneObject read FCamera write SetCamera;

    // Assign a target, around which Moving object should rotate(usually TVKCamera.TargetObject).
    property CameraTarget: TVKBaseSceneObject read FCameraTarget write SetCameraTarget;

    //specifies whether user should be able interract with the GLSceneViewer
    //it is set to false while the camera is moving and
    //coders should check this value and block GUI access to GLSceneViewer
    //property AllowUserAction:boolean read FAllowUserAction;

    //safe distance to avoid moving the camera trough the camera.targetObject
    //while performing  SafeOrbitAndZoomToPos
    property soSafeDistance:double read FsoSafeDist write FsoSafeDist;
    //time to zoom in/out to the safe position while performing  SafeOrbitAndZoomToPos
    property soTimeToSafePlacement:double read FsoTimeToSafePlacement write FsoTimeToSafePlacement;
    //time to orbit while performing  SafeOrbitAndZoomToPos
    property soTimeToOrbit:double read FsoTimeToOrbit write FsoTimeToOrbit;
    //time to zoom in/out to the given final position while performing  SafeOrbitAndZoomToPos
    property soTimeToZoomBackIn:double read FsoTimeToZoomBackIn write FsoTimeToZoomBackIn;

    //this event is triggered when a job is init
    property OnJobAdded : TVKCameraJobEvent read FOnJobAdded write SetOnJobAdded;

    //this event is triggered when a job is step (like an OnMove)
    property OnJobStep : TVKCameraJobEvent read FOnJobStep write SetOnJobStep;

    //this event is triggered when a job is finished (not canceled)
    property OnJobFinished : TVKCameraJobEvent read FOnJobFinished write SetOnJobFinished;
  end;

implementation


const
  cGLCAMERACONTROLLER_CHECK_EXTENDED = TRUE;
  cEPSILON = 0.001;

{ TVKCameraController }

constructor TVKCameraController.Create(AOwner:TComponent);
begin
  inherited;
  //create the job list container
  FCameraJobList := TVKCameraJobList.Create(Self);
  FCameraJobList.OwnsObjects := true;

  //initialize values
  soSafeDistance:=10;
  soTimeToSafePlacement:=1;
  soTimeToOrbit:=2;
  soTimeToZoomBackIn:=1;
end;

destructor TVKCameraController.Destroy;
begin
  //delete job list and all jobs inside
  FCameraJobList.Free;
  inherited;
end;


procedure TVKCameraController.CheckAssignments(Extended:boolean);
begin
  /// Check camera assignment
  if not Assigned(FCamera) then
  begin
    Raise EGLCameraController.CreateFmt('%s (%s) needs to have a Camera assigned',[Self.Name, Self.ClassName]);
  end;

  if Extended then
    /// Check camera;TargetObject assignment
    if not Assigned(FCameraTarget) then
    begin
      Raise EGLCameraController.CreateFmt('%s (%s) needs Camera to have a TargetObject assigned',[Self.Name, Self.ClassName]);
    end;
end;

procedure TVKCameraController.Step(const deltaTime, newTime: Double);
var
  CurrentJob : TVKCameraJob;
begin

  if FCameraJobList.Count > 0 then
  begin
    CurrentJob := FCameraJobList.First;

    if CurrentJob.FInit then
    begin
      CurrentJob.Init;
      CurrentJob.FStartTime := newTime;
      CurrentJob.FRunning := True;
      CurrentJob.FInit := False;

      // Notify job
      if Assigned(FOnJobAdded) then
        FOnJobAdded(CurrentJob);
    end;

    if CurrentJob.FRunning then
    begin
      CurrentJob.FElapsedTime := newTime - CurrentJob.FStartTime;
      CurrentJob.FDeltaTime := deltaTime;// newTime - CurrentJob.FElapsedTime;
      CurrentJob.Step;

      // Notify job
      if Assigned(FOnJobStep) then
        FOnJobStep(CurrentJob);
    end;

    if not CurrentJob.FRunning then
    begin
      FCameraJobList.Remove(CurrentJob);

      // Notify job
      if Assigned(FOnJobFinished) then
        FOnJobFinished(CurrentJob);
    end;

  end;

  //AdjustScene;
end;


function TVKCameraController.MoveToPos(x,y,z, time:double): TVKMoveToPosJob;
begin
  Result := TVKMoveToPosJob.Create(FCameraJobList);

  Result.X := x;
  Result.Y := y;
  Result.Z := z;
  Result.Time := time;
end;


function TVKCameraController.ZoomToDistance(Distance, Time:double): TVKZoomToDistanceJob;
begin
  Result := TVKZoomToDistanceJob.Create(FCameraJobList);
  Result.Distance := Distance;
  Result.Time := Time;
end;


function TVKCameraController.OrbitToPos(x,y,z,time:double): TVKOrbitToPosJob;
begin
  Result := TVKOrbitToPosJob.Create(FCameraJobList);
  Result.FTargetPosition := PointMake(x, y, z);
  Result.FCameraUpVector := FCameraJobList.FController.FCamera.AbsoluteUp;
  Result.FTime := time;
end;


function TVKCameraController.OrbitToPosSmooth(const ATargetPosition: TVector; const ATime: Double;
  const ASmoothNavigator: TVKNavigatorSmoothChangeVector; const AFNeedToRecalculateZoom: Boolean;
  const ACameraUpVector: PVector = nil): TVKSmoothOrbitToPos;
begin
  Result := TVKSmoothOrbitToPos.Create(FCameraJobList);

  Result.FTargetPosition := ATargetPosition;
  Result.FTime := ATime;
  Result.FSmoothNavigator := ASmoothNavigator;
  Result.FShouldBeMatrix := FCameraJobList.FController.FCamera.Matrix;
  Result.FNeedToRecalculateZoom := AFNeedToRecalculateZoom;
  if ACameraUpVector = nil then
    Result.FCameraUpVector := FCameraJobList.FController.FCamera.AbsoluteUp
  else
    Result.FCameraUpVector := ACameraUpVector^;
end;

function TVKCameraController.OrbitToPosAdvanced(x,y,z,time:double; PreferUpAxis: Boolean = True): TVKOrbitToPosAdvJob;
begin
  Result := TVKOrbitToPosAdvJob.Create(FCameraJobList);

  Result.X := x;
  Result.Y := y;
  Result.Z := z;
  Result.PreferUpAxis := PreferUpAxis;
  Result.Time := time;
end;

function TVKCameraController.OrbitToPosAdvancedSmooth(const x,y,z, time: double;
  const ASmoothNavigator: TVKNavigatorSmoothChangeVector; const PreferUpAxis: Boolean = True): TVKSmoothOrbitToPosAdvJob;
begin
  Result := TVKSmoothOrbitToPosAdvJob.Create(FCameraJobList);

  Result.X := x;
  Result.Y := y;
  Result.Z := z;
  Result.PreferUpAxis := PreferUpAxis;
  Result.Time := time;
  Result.FSmoothNavigator := ASmoothNavigator;
  Result.FPreviousPosition := ASmoothNavigator.OnGetCurrentValue(ASmoothNavigator);
  Result.FRestoreUpVector := True;
end;

procedure TVKCameraController.SafeOrbitAndZoomToPos(x,y,z:double);
begin
  //this was the main purpose of this component
  //as you can see, it actually is a combination of the other 3 methods
  CheckAssignments(cGLCAMERACONTROLLER_CHECK_EXTENDED);
  ZoomToDistance(soSafeDistance,soTimeToSafePlacement);
  OrbitToPos(x,y,z,soTimeToOrbit);
  MoveToPos(x,y,z,soTimeToZoomBackIn);
end;


procedure TVKCameraController.StopMovement;
begin
  FCameraJobList.Clear;
end;


procedure TVKCameraController.SetOnJobAdded(const Value: TVKCameraJobEvent);
begin
  FOnJobAdded := Value;
end;

procedure TVKCameraController.SetOnJobStep(const Value: TVKCameraJobEvent);
begin
  FOnJobStep := Value;
end;

procedure TVKCameraController.SetOnJobFinished(const Value: TVKCameraJobEvent);
begin
  FOnJobFinished := Value;
end;

procedure TVKCameraController.SetCamera(const Value: TVKBaseSceneObject);
begin
  if FCamera <> nil then FCamera.RemoveFreeNotification(Self);
  FCamera := Value;
  if FCamera <> nil then FCamera.FreeNotification(Self);
  
  if (FCamera is TVKCamera) and (FCameraTarget = nil) then
    SetCameraTarget(TVKCamera(FCamera).TargetObject);
end;

procedure TVKCameraController.SetCameraTarget(
  const Value: TVKBaseSceneObject);
begin
  if FCameraTarget <> nil then FCameraTarget.RemoveFreeNotification(Self);
  FCameraTarget := Value;
  if FCameraTarget <> nil then FCameraTarget.FreeNotification(Self);
end;

procedure TVKCameraController.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if Operation = opRemove then
  begin
    if AComponent = FCamera then
      FCamera := nil
    else if AComponent = FCameraTarget then
      FCameraTarget := nil;
  end;
end;

{ TVKCameraJobList }


constructor TVKCameraJobList.Create(AController: TVKCameraController);
begin
  inherited Create;
  FController := AController;
end;

function TVKCameraJobList.GetCameraJob(const AIndex: integer): TVKCameraJob;
begin
  Result := inherited Get(AIndex);
end;

procedure TVKCameraJobList.SetCameraJob(const AIndex: integer;
  const Value: TVKCameraJob);
begin
  inherited Put(AIndex, Value);
end;

function TVKCameraJobList.Add(ACameraJob: TVKCameraJob): integer;
begin
  Result := inherited Add(ACameraJob);
end;

function TVKCameraJobList.First: TVKCameraJob;
begin
  Result := TVKCameraJob(inherited First);
end;

function TVKCameraJobList.Last: TVKCameraJob;
begin
  Result := TVKCameraJob(inherited Last);
end;

{ TVKCameraJob }

constructor TVKCameraJob.Create(const AJoblist : TVKCameraJobList);
begin
  FJoblist := AJoblist;
  FJoblist.Add(Self);

  FInit := True;
  FStartTime := 0;
  FProceedTime := 0;
end;

destructor TVKCameraJob.Destroy;
begin

  inherited;
end;

procedure TVKCameraJob.Abort;
begin

end;


{ TVKMoveToPosJob }

procedure TVKMoveToPosJob.Init;
begin
  FProceedTime := Time;
  FInitialPos := VectorSubtract(FJobList.FController.FCamera.AbsolutePosition, FJobList.FController.FCameraTarget.AbsolutePosition);
  MakeVector(FFinalPos, X, Y, Z);
end;

procedure TVKMoveToPosJob.Step;
var
  Vect : TVector;
begin
  if FElapsedTime < FProceedTime then
  begin
    Vect := VectorLerp(FInitialPos, FFinalPos, FElapsedTime/FProceedTime);
  end
    else
  begin
    Vect := FFinalPos;
    FRunning := false;
  end;

  if Assigned(FJobList.FController.FCamera.Parent) then
    Vect:=FJobList.FController.FCamera.Parent.AbsoluteToLocal(Vect);

  FJobList.FController.FCamera.Position.AsVector := Vect;
end;

{ TVKZoomToDistanceJob }

procedure TVKZoomToDistanceJob.Init;
begin
  FProceedTime := Time;
  FInitialPos := VectorSubtract(FJobList.FController.FCamera.AbsolutePosition, FJobList.FController.FCameraTarget.AbsolutePosition);
  // To determine final position, we normalize original position and scale it with final distance
  SetVector(FFinalPos, FInitialPos);
  NormalizeVector(FFinalPos);
  ScaleVector(FFinalPos, Distance);
end;

procedure TVKZoomToDistanceJob.Step;
var
  Vect : TVector;
begin
  if FElapsedTime < FProceedTime then
  begin
    Vect := VectorLerp(FInitialPos, FFinalPos, FElapsedTime/FProceedTime);
  end
    else
  begin
    Vect := FFinalPos;
    FRunning := false;
  end;

  if Assigned(FJobList.FController.FCamera.Parent) then
    Vect:=FJobList.FController.FCamera.Parent.AbsoluteToLocal(Vect);

  FJobList.FController.FCamera.Position.AsVector := Vect;
end;



{ TVKOrbitToPosJob }


procedure TVKOrbitToPosJob.Init;
begin
  FProceedTime := FTime;

  FFinalPos := ShiftObjectFromCenter(FTargetPosition, FJobList.FController.FCameraTarget.AbsolutePosition,
    VectorDistance(FJobList.FController.FCamera.AbsolutePosition, FJobList.FController.FCameraTarget.AbsolutePosition), True);

  // Yep, FFinalPos is stored in relative coordinates.
  if FJobList.FController.FCamera.Parent <> nil then
    FFinalPos := FJobList.FController.FCamera.Parent.AbsoluteToLocal(FFinalPos);

  FRotateSpeed := GetSafeTurnAngle(
    FJobList.FController.FCamera.AbsolutePosition, FCameraUpVector, FTargetPosition,
    FJobList.FController.FCameraTarget.AbsolutePosition);

  ScaleVector(FRotateSpeed, 1 / FProceedTime);

  FInit := True;
end;

procedure TVKOrbitToPosJob.Step;
begin

  if FElapsedTime < FProceedTime then
  begin
    FJobList.FController.FCamera.AbsolutePosition := MoveObjectAround(
      FJobList.FController.FCamera.AbsolutePosition, FCameraUpVector,
      FJobList.FController.FCameraTarget.AbsolutePosition,
      FRotateSpeed.V[0] * FDeltaTime, FRotateSpeed.V[1] * FDeltaTime);
  end
    else
  begin
    // Yep, FFinalPos is stored in ralative coordinates.
    FJobList.FController.FCamera.Position.AsVector := FFinalPos;
    FRunning := False;
  end;

end;


{ TVKOrbitToPosAdvJob }

procedure TVKOrbitToPosAdvJob.Init;
var
  Right: TVector;
  lAbsVectorToTarget: TVector;
begin

  FProceedTime := time;
  FInitialPos := VectorSubtract(FJobList.FController.FCamera.AbsolutePosition, FJobList.FController.FCameraTarget.AbsolutePosition);

  if Assigned(FJobList.FController.FCamera.Parent) then
    FFinalPos := VectorSubtract(FJobList.FController.FCamera.Parent.LocalToAbsolute(VectorMake(x,y,z,1)), FJobList.FController.FCameraTarget.AbsolutePosition)
  else
    FFinalPos := VectorSubtract(VectorMake(x,y,z,1), FJobList.FController.FCameraTarget.AbsolutePosition);

  //if destination is Target Pos, we can't compute
  if VectorLength(FFinalPos)<cEPSILON then
  begin
    //FAllowUserAction := True;
    Exit;
  end;

  //Compute Angle of Rotation
  FAngle:= ArcCos(VectorAngleCosine(Vector3fMake(FFinalPos), Vector3fMake(FInitialPos)));

  lAbsVectorToTarget := VectorNormalize(VectorSubtract(
      FJobList.FController.FCameraTarget.AbsolutePosition,
      FJobList.FController.FCamera.AbsolutePosition));

  Right := VectorNormalize(VectorCrossProduct(lAbsVectorToTarget, FJobList.FController.FCamera.AbsoluteUp));

  FInitialDir := FJobList.FController.FCamera.AbsoluteDirection;
  FInitialUp := FJobList.FController.FCamera.AbsoluteUp;

  // Determine rotation Axis
  // if Angle equals 0 degrees.
  if FAngle < cEPSILON then
    if PreferUpAxis then
      FRotAxis := VectorNormalize(VectorCrossProduct(
                   VectorCrossProduct(FFinalPos, FInitialUp), FFinalPos))
    else
      FRotAxis := Right
  else
    // if Angle equals 180 degrees.
    if FAngle >Pi - cEPSILON  then
      if PreferUpAxis then
        FRotAxis := VectorNormalize(VectorCrossProduct(VectorCrossProduct(FFinalPos, FInitialUp), FFinalPos))
      else
        FRotAxis := Right
    else
      FRotAxis:= VectorNormalize(VectorCrossProduct(FFinalPos, FInitialPos));

end;

procedure TVKOrbitToPosAdvJob.Step;
var
  tempUp, tempDir, tempPos : TVector;
begin

  if FElapsedTime < FProceedTime then
  begin
    //Compute Position
    tempPos := FInitialPos;
    RotateVector(tempPos, Vector3fMake(FRotAxis), FAngle * FElapsedTime/FProceedTime);
    FJobList.FController.FCamera.AbsolutePosition := VectorAdd(FJobList.FController.FCameraTarget.AbsolutePosition, tempPos);

    //Compute Direction vector
    tempDir := FInitialDir;
    RotateVector(tempDir, Vector3fMake(FRotAxis), FAngle * FElapsedTime/FProceedTime);
    FJobList.FController.FCamera.AbsoluteDirection := tempDir;

    //Compute Up Vector
    tempUp := FInitialUp;
    RotateVector(tempUp, Vector3fMake(FRotAxis), FAngle * FElapsedTime/FProceedTime);
    FJobList.FController.FCamera.AbsoluteUp := tempUp;
  end
    else
  begin
    //Compute Position
    tempPos := FInitialPos;
    RotateVector(tempPos, Vector3fMake(FRotAxis), FAngle);
    FJoblist.FController.FCamera.AbsolutePosition := VectorAdd(
       FJoblist.FController.FCameraTarget.AbsolutePosition, tempPos);

    //Compute Direction vector
    tempDir := FInitialDir;
    RotateVector(tempDir, Vector3fMake(FRotAxis), FAngle);
    FJoblist.FController.FCamera.AbsoluteDirection := tempDir;

    //Compute Up Vector
    tempUp := FInitialUp;
    RotateVector(tempUp, Vector3fMake(FRotAxis), FAngle);
    FJoblist.FController.FCamera.AbsoluteUp := tempUp;

    FRunning := false;
  end;

end;

{ TVKSmoothOrbitToPosAdvJob }

procedure TVKSmoothOrbitToPosAdvJob.Init;
var
  Right: TVector;
begin
  FProceedTime := time;
  FInitialPos:= VectorSubtract(FPreviousPosition, FJobList.FController.FCameraTarget.AbsolutePosition);

  if Assigned(FJobList.FController.FCamera.Parent) then
    FFinalPos := VectorSubtract(FJobList.FController.FCamera.Parent.LocalToAbsolute(VectorMake(x,y,z,1)), FJobList.FController.FCameraTarget.AbsolutePosition)
  else
    FFinalPos := VectorSubtract(VectorMake(x,y,z,1), FJobList.FController.FCameraTarget.AbsolutePosition);

  //if destination is Target Pos, we can't compute
  if VectorLength(FFinalPos)<cEPSILON then
  begin
    //FAllowUserAction := True;
    Exit;
  end;

  //Compute Angle of Rotation
  FAngle:= ArcCos(VectorAngleCosine(Vector3fMake(FFinalPos), Vector3fMake(FInitialPos)));

  Right := VectorNormalize(VectorCrossProduct(
//    FJobList.FController.FCamera.AbsoluteVectorToTarget,
    VectorNormalize(VectorSubtract(FJobList.FController.FCameraTarget.AbsolutePosition, FPreviousPosition)),
    FJobList.FController.FCamera.AbsoluteUp));

  FInitialDir := FJobList.FController.FCamera.AbsoluteDirection;
  FInitialUp := FJobList.FController.FCamera.AbsoluteUp;

  // Determine rotation Axis
  // if Angle equals 0 degrees.
  if FAngle < cEPSILON then
    if PreferUpAxis then
      FRotAxis := VectorNormalize(VectorCrossProduct(
                   VectorCrossProduct(FFinalPos, FInitialUp), FFinalPos))
    else
      FRotAxis := Right
  else
    // if Angle equals 180 degrees.
    if FAngle >Pi - cEPSILON  then
      if PreferUpAxis then
        FRotAxis := VectorNormalize(VectorCrossProduct(VectorCrossProduct(FFinalPos, FInitialUp), FFinalPos))
      else
        FRotAxis := Right
    else
      FRotAxis:= VectorNormalize(VectorCrossProduct(FFinalPos, FInitialPos));

end;

procedure TVKSmoothOrbitToPosAdvJob.Step;
var
  tempUp, tempDir, tempPos : TVector;
begin

  if FElapsedTime < FProceedTime then
  begin
    //Compute Position
    tempPos := FInitialPos;
    RotateVector(tempPos, Vector3fMake(FRotAxis), FAngle * FElapsedTime/FProceedTime);
    FSmoothNavigator.TargetValue.DirectVector := VectorAdd(FJobList.FController.FCameraTarget.AbsolutePosition, tempPos);
    FPreviousPosition := FSmoothNavigator.TargetValue.DirectVector;

    //Compute Direction vector
    tempDir := FInitialDir;
    RotateVector(tempDir, Vector3fMake(FRotAxis), FAngle * FElapsedTime/FProceedTime);
    FJobList.FController.FCamera.AbsoluteDirection := tempDir;

    //Compute Up Vector
    if FRestoreUpVector then
      FJobList.FController.FCamera.AbsoluteUp := FInitialUp
    else
    begin
      tempUp := FInitialUp;
      RotateVector(tempUp, Vector3fMake(FRotAxis), FAngle * FElapsedTime/FProceedTime);
      FJobList.FController.FCamera.AbsoluteUp := tempUp;
    end;
  end
  else
  begin
    //Compute Position
    tempPos := FInitialPos;
    RotateVector(tempPos, Vector3fMake(FRotAxis), FAngle);
    FJoblist.FController.FCamera.AbsolutePosition := VectorAdd(
      FJoblist.FController.CameraTarget.AbsolutePosition, tempPos);

    //Compute Direction vector
    tempDir := FInitialDir;
    RotateVector(tempDir, Vector3fMake(FRotAxis), FAngle);
    FJoblist.FController.FCamera.AbsoluteDirection := tempDir;

    //Compute Up Vector
    if FRestoreUpVector then
      FJoblist.FController.FCamera.AbsoluteUp := FInitialUp
    else
    begin
      tempUp := FInitialUp;
      RotateVector(tempUp, Vector3fMake(FRotAxis), FAngle);
      FJoblist.FController.FCamera.AbsoluteUp := tempUp;
      FRunning := false;
    end;

    FRunning := false;
  end;
end;

{ TVKSmoothOrbitToPosAdv }

constructor TVKSmoothOrbitToPos.Create(const AJoblist: TVKCameraJobList);
begin
  inherited;
  FCutoffAngle := 0.1;
end;

procedure TVKSmoothOrbitToPos.Step;
var
  lCurrentDistanceToTarget: Single;
  lTargetPosition: TVector;
  lCurrentMatrix: TMatrix;
  lAngle: Single;
  lAbsTargetPosition: TVector;

  procedure RestoreDistanceToTarget();
  var
    lDirection: TVector;
  begin
    lDirection := VectorNormalize(VectorSubtract(
      FJobList.FController.FCameraTarget.AbsolutePosition,
      FJobList.FController.FCamera.AbsolutePosition));

    FJobList.FController.FCamera.AbsolutePosition := VectorAdd(
      FJobList.FController.FCameraTarget.AbsolutePosition,
      VectorScale(lDirection, - lCurrentDistanceToTarget));
  end;


  procedure SetTargetValueRelative(const AAbsolutePosition: TVector);
  begin
    if FJobList.FController.FCamera.Parent = nil then
      FSmoothNavigator.TargetValue.DirectVector := AAbsolutePosition
    else
      FSmoothNavigator.TargetValue.DirectVector := FJobList.FController.FCamera.Parent.AbsoluteToLocal(AAbsolutePosition);
  end;

  procedure ApplyDistanceToResult();
  var
    lDirection, lNewTargetPosition: TVector;
  begin
    lDirection := VectorNormalize(VectorSubtract(
      FJobList.FController.FCameraTarget.AbsolutePosition,
      lAbsTargetPosition));

    lNewTargetPosition := VectorAdd(
      FJobList.FController.FCameraTarget.AbsolutePosition,
      VectorScale(lDirection, - lCurrentDistanceToTarget));

    SetTargetValueRelative(lNewTargetPosition);
  end;

begin
  if FElapsedTime < FProceedTime then
  begin
    // Save current matrix.
    lCurrentMatrix := FJobList.FController.FCamera.Matrix;

    if FNeedToRecalculateZoom then
      lCurrentDistanceToTarget := FJobList.FController.FCamera.DistanceTo(FJobList.FController.FCameraTarget)
    else
      lCurrentDistanceToTarget := 0; // To avoid warning message.

    // Calculate the position, in which camera should have been.
    FJobList.FController.FCamera.Matrix := FShouldBeMatrix;

    FJobList.FController.FCamera.AbsolutePosition := MoveObjectAround(
      FJobList.FController.FCamera.AbsolutePosition, FCameraUpVector,
      FJobList.FController.FCameraTarget.AbsolutePosition,
      FRotateSpeed.V[0] * FDeltaTime, FRotateSpeed.V[1] * FDeltaTime);

    if FNeedToRecalculateZoom then
      RestoreDistanceToTarget();

    lTargetPosition := FJobList.FController.FCamera.AbsolutePosition;
    FShouldBeMatrix := FJobList.FController.FCamera.Matrix;

    // Restore Camera position and move it to the desired vector.
    FJobList.FController.FCamera.Matrix := lCurrentMatrix;
    SetTargetValueRelative(lTargetPosition);
  end
  else
  begin
    if FNeedToRecalculateZoom then
    begin
      if FJobList.FController.FCamera.Parent = nil then
        lAbsTargetPosition := FFinalPos
      else
        lAbsTargetPosition := FJobList.FController.FCamera.Parent.LocalToAbsolute(FFinalPos);

      lAngle := RadToDeg(AngleBetweenVectors(FJobList.FController.FCamera.AbsolutePosition,
         lAbsTargetPosition, FJobList.FController.FCameraTarget.AbsolutePosition));
      if lAngle < FCutoffAngle then
      begin
        FSmoothNavigator.Enabled := False;
        FRunning := False;
      end
      else
      begin
        lCurrentDistanceToTarget := FJobList.FController.FCamera.DistanceTo(FJobList.FController.FCameraTarget);
        ApplyDistanceToResult();
      end;
    end
    else
    begin
      FSmoothNavigator.TargetValue.DirectVector := FFinalPos;
      FRunning := False;
    end;
  end;
end;

end.
