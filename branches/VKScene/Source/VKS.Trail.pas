//
// This unit is part of the GLScene Project   
//
{: VKS.Trail<p>

	Creates a trail-like mesh.
  Based on Jason Lanford's demo. <p>

	<b>History : </b><font size=-1><ul>
        <li>23/08/10 - Yar - Added VKS.OpenGLTokens to uses, replaced OpenGL1x functions to OpenGLAdapter
        <li>03/04/07 - DaStr - Added default values to some properties
                               Added TVKTrail.AntiZFightOffset
                               Subscribed for Notification in TVKTrail.SetTrailObject
        <li>28/03/07 - DaStr - Renamed parameters in some methods
                              (thanks Burkhard Carstens) (Bugtracker ID = 1678658)
        <li>19/12/06 - DaS - msRight (TMarkStyle) support added
        <li>09/12/04 - LR  - Suppress windows uses
        <li>12/10/04 - Mrqzzz - Creation (Based on Jason Lanford's demo - june 2003)
   </ul></font>
}

unit VKS.Trail;

interface

{$I VKScene.inc}

uses
  System.Classes, System.SysUtils,

  VKS.Scene, VKS.VectorTypes, VKS.MeshUtils, VKS.VectorGeometry,
  VKS.VectorFileObjects, VKS.Mesh, VKS.Objects, VKS.Material,
  VKS.Strings, VKS.BaseClasses;

const cMaxVerts = 2000;

type

  TMarkStyle = (msUp, msDirection, msFaceCamera, msRight);

  TVKTrail = class(TGlMesh)
  private

    fVertLimit: integer;
    fTimeLimit: single;
    fMinDistance: single;
    fAlpha: single;
    fAlphaFade: Boolean;
    fUVScale: Single;
    fVerts: array[1..cMaxVerts] of TVector3f;
    fUVs: array[1..cMaxVerts] of TTexpoint;
    fTimeStamps: array[1..cMaxVerts] of Double;
    fVertStart,fVertEnd,fVertCount: integer;


    fLastV0Pos,fLastPos, fLastDir, fLastUp: TVector3f;
    FLastUVs: single;

    // used for UV scaling
    fLastP1,fLastP2: TVector3f;
    FTrailObject: TVKBaseSceneObject;
    FMarkStyle: TMarkStyle;
    FMarkWidth: single;
    FEnabled: boolean;
    FAntiZFightOffset: Single;
    procedure SetTrailObject(const Value: TVKBaseSceneObject);
    procedure SetMarkStyle(const Value: TMarkStyle);
    procedure SetAlpha(const Value: single);
    procedure SetAlphaFade(const Value: Boolean);
    procedure SetMinDistance(const Value: single);
    procedure SetTimeLimit(const Value: single);
    procedure SetUVScale(const Value: single);
    procedure SetVertLimit(const Value: integer);
    procedure SetMarkWidth(const Value: single);
    procedure SetEnabled(const Value: boolean);
    function StoreAntiZFightOffset: Boolean;
    
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public

    //EnableUVmapping: boolean; // generate UV's or not

    procedure DoProgress(const progressTime : TProgressTimes); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure CreateMark(obj: TGlBaseSceneObject; width: single;CurrentTime : Double); overload;
    procedure CreateMark(APos,ADir,AUp: TVector3f; AWidth: single;ACurrentTime : Double); overload;
    function CreateMark(p1,p2: TVector3f;CurrentTime : Double):boolean; overload;

    procedure ClearMarks;

  published
    {: Add a tiny bit of offset to help prevent z-fighting..
       Need a better solution here as this will get out of whack on really
       long trails and is dependant on scene scale. }
     property AntiZFightOffset: Single read FAntiZFightOffset write FAntiZFightOffset stored StoreAntiZFightOffset;

     property VertLimit: integer  read FVertLimit write SetVertLimit default 150;
     property TimeLimit: single  read FTimeLimit write SetTimeLimit;
     {: Don't create mark unless moved at least this distance. }
     property MinDistance: single  read FMinDistance write SetMinDistance;
     property Alpha: single  read FAlpha write SetAlpha;
     property AlphaFade: Boolean  read FAlphaFade write SetAlphaFade default True;
     property UVScale: single  read FUVScale write SetUVScale;
     property MarkStyle : TMarkStyle read FMarkStyle write SetMarkStyle default msFaceCamera;
     property TrailObject : TVKBaseSceneObject read FTrailObject write SetTrailObject default nil;
     property MarkWidth : single read FMarkWidth write SetMarkWidth;
     property Enabled : boolean read FEnabled write SetEnabled default True;
  end;

//-----------------------------------------------------------------------------
implementation
//-----------------------------------------------------------------------------

constructor TVKTrail.Create(AOwner: TComponent);
begin
 inherited Create(AOwner);
 vertices.Clear;    // inherited tglmesh makes a triangle... remove it.
 Mode := mmTriangleStrip;
 FAntiZFightOffset := 0.0000266;
 VertexMode := vmVNCT;
 fVertStart := 1;
 fVertEnd := 0;
 fVertCount := 0;
 fVertLimit := 150;
 fTimeLimit := 0.5;
 fMinDistance := 0.05;
 fAlphaFade := True;
 fAlpha := 1.0;
 fLastUVs := 0;
 fUVScale := 1.0;
 FMarkWidth := 0.5;
 FEnabled := True;
 FMarkStyle := msFaceCamera;
 Material.BlendingMode := bmAdditive;
 Material.FaceCulling := fcNoCull;
end;

destructor TVKTrail.Destroy;
begin
  // notta?
   inherited Destroy;
end;

procedure TVKTrail.DoProgress(const progressTime: TProgressTimes);
begin
  inherited;
  if Enabled and Assigned(TrailObject) then
  begin
       CreateMark(TrailObject,MarkWidth,progressTime.NewTime);
  end;
end;

procedure TVKTrail.ClearMarks;
begin
 Vertices.Clear;
 fVertCount := 0;
 fVertEnd := 0;
 fVertStart := 1;
end;

procedure TVKTrail.CreateMark(obj: TGlBaseSceneObject; width: single;CurrentTime : Double);
var
   v0,dv,p1,p2 : TVector3f;
   v: TVector3f;
   c: TVKCamera;
begin
     case MarkStyle of
     msUp:         begin
                         v := AffinevectorMake(obj.AbsoluteUp);
                    end;
     msDirection:  begin
                         v := AffinevectorMake(obj.AbsoluteDirection);

                    end;
     msRight:       begin
                         v := AffinevectorMake(obj.AbsoluteRight);
                    end;
     msFaceCamera: begin
                         c := Scene.CurrentGLCamera;
                         if c<>nil then
                         begin
                              dv := VectorSubtract(fLastV0Pos,AffinevectorMake(obj.AbsolutePosition));
                              v := VectorCrossProduct(AffinevectorMake(VectorSubtract(c.AbsolutePosition,obj.AbsolutePosition)),dv);
                              NormalizeVector(v);

                         end;
                    end;
     else Assert(False, glsErrorEx + glsUnknownType);
     end;
     v0 := AffinevectorMake(Obj.AbsolutePosition);
     VectorScale(v,width,v);
     p1:=VectorSubtract(v0,v);
     p2:=VectorAdd(v0,v);

     // PREVENT REFLAT
     if not PointIsInHalfSpace(p1,fLastV0Pos,VectorSubtract(v0,fLastV0Pos)) then
        p1 := fLastp1;
     if not PointIsInHalfSpace(p2,fLastV0Pos,VectorSubtract(v0,fLastV0Pos)) then
        p2 := fLastp2;
     

     if CreateMark(p1,p2,CurrentTime) then
     begin
          fLastV0Pos := v0;
     end;
end;



function TVKTrail.CreateMark(p1,p2: TVector3f; CurrentTime : Double): boolean;
var
   diff: integer;
   uv1,uv2: TTexPoint;
   apoint1,apoint2: TVector3f;
   currentvert: integer;
   i: integer;
   color: tVector4f;
   ramp: single;
   distance: single;
   uvsize: single;
   tinyoffset: TVector3f;
   MustRebuild : Boolean;
begin
    Result := false;
    apoint1 := p1;
    apoint2 := p2;

    // get distance moved, based on average of 2 point movement;
    distance := ( VectorDistance(fLastp1,p1) + VectorDistance(fLastp2,p2) ) / 2;

    if distance = 0 then
    begin
         apoint1 := AffineVectorMake(fLastp1.V[0],fLastp1.V[1],fLastp1.V[2]);
         apoint2 := AffineVectorMake(fLastp2.V[0],fLastp2.V[1],fLastp2.V[2]);
    end;

    uvsize :=  distance / fUVScale; // scale UV's
    uv2.S := 0+fLastUVs+uvsize; uv2.T := 0;
    uv1.S := 0+fLastUVs+uvsize; uv1.T := 1;


    // process verts, then send them to .vertices for rendering
    if fVertEnd >= cMaxVerts then
       fVertEnd := 0;


    fVerts[fVertEnd+1] := apoint2;
    fVerts[fVertEnd+2] := apoint1;
    fUVs[fVertEnd+1] := uv2;
    fUVs[fVertEnd+2] := uv1;
    //tstamp := GetTickCount; // win api
    fTimeStamps[fVertEnd+1] := CurrentTime;
    fTimeStamps[fVertEnd+2] := CurrentTime;


    MustRebuild := false;
    if distance >= fMinDistance then
    begin
         inc(fVertCount,2);
         inc(fVertEnd,2);

         // remember stuff
         fLastUVs := fLastUVs + uvsize;
         fLastp1 := p1; fLastp2 := p2;
         MustRebuild := true;
         Result := true;
    end;


    // remove expired verts over VertLimit
    if fVertCount > fVertLimit then
    begin
         diff := fVertCount - fVertLimit;
         inc(fVertStart,diff); // inc start, reducing count to fit in limit - rollover handled later
         dec(fVertCount,diff);
    end;

    // remove time expired verts over TimeLimit
    //currentvert := fVertStart;
    for i := 0 to fVertCount-1 do
    begin
         if (i + fVertStart)  > cMaxVerts then
            currentvert := (i + fVertStart) - cMaxVerts  // rollover
         else
             currentvert := (i + fVertStart);

         if fTimeLimit > 0 then
           if  CurrentTime - fTimeStamps[ currentvert ] > fTimeLimit then
           begin
               inc(fVertStart,1); // inc start, reducing count to fit in limit - rollover handled later
               dec(fVertCount,1);
               MustRebuild := true;
           end;
    end;

    // handle rollover
    if fVertStart > cMaxVerts then fVertStart := 0 + ( fVertStart - cMaxVerts); // adjust if rollover

    if MustRebuild then
    begin
         // give to .vertices, from start to count
         //currentvert := fVertStart;
         ramp := fAlpha / (fVertCount) ;
         color := material.FrontProperties.Diffuse.Color;
         Vertices.Clear;
         for i := 0 to fVertCount-1 do
         begin
              if (i + fVertStart)  > cMaxVerts then
                 currentvert := (i + fVertStart) - cMaxVerts  // rollover
              else
                  currentvert := (i + fVertStart);

              if fAlphaFade then
                 color.V[3] :=  (ramp * i)
              else
                  color.V[3] := fAlpha;
              // add a tiny bit of offset to help prevent z-fighting..
              // need a better solution here
              // as this will get out of whack on really long trails
              // and is dependant on scene scale
              TinyOffset.V[0] := FAntiZFightOffset * i;
              TinyOffset.V[1] := FAntiZFightOffset * i;
              TinyOffset.V[2] := FAntiZFightOffset * i;
              TinyOffset :=  VectorAdd( fVerts[ currentvert ],Tinyoffset);
              //TinyOffset := fVerts[ currentvert]; // bypass
              Vertices.AddVertex( TinyOffset, NullVector, Color, fUVs[currentvert]  );
         end;
    end;

end;

procedure TVKTrail.CreateMark(APos,ADir,AUp: TVector3f; AWidth: single;ACurrentTime : Double);
var
apoint1,apoint2,crossp: TVector3f;
begin

    if fMinDistance > 0 then
        if vectorDistance(APos,fLastPos) < fMinDistance then
           exit;

    fLastPos := APos;
    fLastDir := ADir;
    fLastUp := AUp;

    apoint1 := APos;
    apoint2 := APos;
    crossp :=  vectorcrossproduct(ADir,AUp);

    CombineVector( apoint1,vectornormalize(crossp),AWidth);
    CombineVector( apoint2,vectornormalize(VectorNegate(crossp)),AWidth);

    CreateMark( apoint1, apoint2,ACurrentTime);

end;

// NOTES and stuff:

 { // UV mapped 4x4 square for refrence /debug
  uv.S := 0; uv.T := 0;
  Vertices.AddVertex( AffineVectorMake(1, 1, 1), NullVector, NullHmgVector, UV  );
  uv.S := 0; uv.T := 1;
  Vertices.AddVertex( AffineVectorMake(1, 1, 4), NullVector, NullHmgVector, UV  );
  uv.S := 1; uv.T := 0;
  Vertices.AddVertex( AffineVectorMake(4, 1, 1), NullVector, NullHmgVector, UV  );
  uv.S := 1; uv.T := 1;
  Vertices.AddVertex( AffineVectorMake(4, 1, 4), NullVector, NullHmgVector, UV  );


// Directmode: append .vertices only, no way to process/delete except .clear;
// else we manage vertices/UV in our own arrays then dump them all to .vertices
// I don't know if directmode is that much faster, but could be considerably?

if directmode then
 begin
 if fUVTop then // start a new UV tile
   begin
    uv2.S := 0; uv2.T := 0;
    Vertices.AddVertex( AffineVectorMake(apoint2[0], apoint2[1],apoint2[2]), NullVector, NullHmgVector, UV2  );
    uv1.S := 0; uv1.T := 1;
    Vertices.AddVertex( AffineVectorMake(apoint1[0],apoint1[1],apoint1[2]), NullVector, NullHmgVector, UV1  );
   end
  else // finish a UV tile
   begin
    uv2.S := 1; uv2.T := 0;
    Vertices.AddVertex( AffineVectorMake(apoint2[0], apoint2[1],apoint2[2]), NullVector, NullHmgVector, UV2  );
    uv1.S := 1; uv1.T := 1;
    Vertices.AddVertex( AffineVectorMake(apoint1[0],apoint1[1],apoint1[2]), NullVector, NullHmgVector, UV1  );
   end;
 end
 }


procedure TVKTrail.SetTrailObject(const Value: TVKBaseSceneObject);
begin
  if FTrailObject <> nil then FTrailObject.RemoveFreeNotification(Self);
  FTrailObject := Value;
  if FTrailObject <> nil then FTrailObject.FreeNotification(Self);
end;

procedure TVKTrail.SetMarkStyle(const Value: TMarkStyle);
begin
  FMarkStyle := Value;
end;

procedure TVKTrail.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
   if (Operation = opRemove) and (AComponent = FTrailObject) then
      TrailObject:=nil;
  inherited;
end;

procedure TVKTrail.SetAlpha(const Value: single);
begin
  FAlpha := Value;
end;

procedure TVKTrail.SetAlphaFade(const Value: Boolean);
begin
  FAlphaFade := Value;
end;

procedure TVKTrail.SetMinDistance(const Value: single);
begin
  FMinDistance := Value;
end;

procedure TVKTrail.SetTimeLimit(const Value: single);
begin
  FTimeLimit := Value;
end;

procedure TVKTrail.SetUVScale(const Value: single);
begin
  FUVScale := Value;
end;

procedure TVKTrail.SetVertLimit(const Value: integer);
begin
  FVertLimit := Value;
end;


procedure TVKTrail.SetMarkWidth(const Value: single);
begin
  FMarkWidth := Value;
end;

procedure TVKTrail.SetEnabled(const Value: boolean);
begin
  FEnabled := Value;
end;

function TVKTrail.StoreAntiZFightOffset: Boolean;
begin
  Result := FAntiZFightOffset <> 0.0000266;
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
initialization
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

   // class registrations
   RegisterClasses([TVKTrail]);


end.
