// GLImposter
{: Imposter building and rendering implementation for GLScene.<p>

   <b>History : </b><font size=-1><ul>
      <li>14/04/04 - SG - Fixed texture clamping for old cards and 
                          switched to GL_NEAREST texture sampling.
      <li>24/03/04 - SG - Initial.
   </ul></font><p>
}
unit GLImposter;

interface

uses
  Classes, GLScene, GLContext, GLTexture, VectorGeometry, GeometryBB, GLMisc,
  PersistentClasses, GLCrossPlatform;

type
   TGLImposterBuilder = class;

   // TImposter
   //
   TImposterOption = (impoBlended);
   TImposterOptions = set of TImposterOption;

   // TImposter
   //
   {: Base class for imposters manipulation and handling.<br>
      Rendering imposters is performed by three methods, BeginRender must
      be invoked first, then Render for each of the impostr
      This class assumes a single impostor per texture. }
   TImposter = class (TObject)
      private
	      { Private Declarations }
         FBuilder : TGLImposterBuilder;
         FTexture : TGLTextureHandle;
         FOptions : TImposterOptions;

		protected
			{ Protected Declarations }
         FVx, FVy : TAffineVector;
         FQuad : array [0..3] of TAffineVector;

         procedure PrepareTexture; dynamic;

      public
	      { Public Declarations }
         constructor Create(aBuilder : TGLImposterBuilder); virtual;
         destructor Destroy; override;

         procedure BeginRender(var rci : TRenderContextInfo); virtual;
         procedure Render(var rci : TRenderContextInfo;
                          const objPos, localCameraPos : TVector;
                          size : Single); virtual;
         procedure EndRender(var rci : TRenderContextInfo); virtual;

         property Builder : TGLImposterBuilder read FBuilder;
         property Texture : TGLTextureHandle read FTexture;
         property Options : TImposterOptions read FOptions write FOptions;
   end;

   // TGLImposterBuilder
   //
   {: Abstract ImposterBuilder class. }
   TGLImposterBuilder = class (TGLUpdateAbleComponent)
      private
	      { Private Declarations }
         FImposterRegister : TPersistentObjectList;

      protected
			{ Protected Declarations }

      public
	      { Public Declarations }
         constructor Create(AOwner : TComponent); override;
         destructor Destroy; override;
			procedure NotifyChange(Sender : TObject); override;

         function CreateNewImposter : TImposter; virtual;
         
      published
	      { Published Declarations }

   end;

	// TGLStaticImposterBuilderCorona
	//
	TGLStaticImposterBuilderCorona = class (TCollectionItem)
	   private
	      { Private Declarations }
         FSamples : Integer;
         FElevation : Single;

	   protected
	      { Protected Declarations }
         function GetDisplayName : String; override;
         procedure SetSamples(val : Integer);
         procedure SetElevation(val : Single);

      public
	      { Public Declarations }
	      constructor Create(Collection : TCollection); override;
	      destructor Destroy; override;
	      procedure Assign(Source: TPersistent); override;
         function SampleBaseIndex : Integer;

	   published
	      { Published Declarations }
         property Samples : Integer read FSamples write SetSamples default 8;
         property Elevation : Single read FElevation write SetElevation;
	end;

	// TGLStaticImposterBuilderCoronas
	//
	TGLStaticImposterBuilderCoronas = class (TOwnedCollection)
	   private
	      { Private Declarations }

	   protected
	      { Protected Declarations }
         procedure SetItems(index : Integer; const val : TGLStaticImposterBuilderCorona);
	      function GetItems(index : Integer) : TGLStaticImposterBuilderCorona;
         procedure Update(Item: TCollectionItem); override;

      public
	      { Public Declarations }
	      constructor Create(AOwner : TPersistent);

         function Add : TGLStaticImposterBuilderCorona;
	      property Items[index : Integer] : TGLStaticImposterBuilderCorona read GetItems write SetItems; default;
         function SampleCount : Integer;

         procedure NotifyChange; virtual;
         procedure EndUpdate; override;
   end;

   // TStaticImposter
   //
   {: Imposter class whose texture contains several views from different angles. }
   TStaticImposter = class (TImposter)
      private
	      { Private Declarations }

		protected
			{ Protected Declarations }

      public
	      { Public Declarations }
         procedure Render(var rci : TRenderContextInfo;
                          const objPos, localCameraPos : TVector;
                          size : Single); override;
   end;

   // TGLStaticImposterBuilder
   //
   {: Builds imposters whose texture is a catalog of prerendered views. }
   TGLStaticImposterBuilder = class (TGLImposterBuilder)
      private
	      { Private Declarations }
         FCoronas : TGLStaticImposterBuilderCoronas;
         FSampleSize : Integer;
         FTextureSize : TGLPoint;
         FSamplesPerAxis : TGLPoint;

      protected
			{ Protected Declarations }
         procedure SetCoronas(val : TGLStaticImposterBuilderCoronas);
         procedure SetSampleSize(val : Integer);

      public
	      { Public Declarations }
         constructor Create(AOwner : TComponent); override;
         destructor Destroy; override;
         function CreateNewImposter : TImposter; override;

         {: Render imposter texture.<p>
            Buffer and object must be compatible, RC must have been activated. }
         procedure Render(var rci : TRenderContextInfo;
                          impostoredObject : TGLBaseSceneObject;
                          buffer : TGLSceneBuffer;
                          destImposter : TImposter);

         {: Meaningful only after imposter texture has been prepared. }
         property TextureSize : TGLPoint read FTextureSize;
         property SamplesPerAxis : TGLPoint read FSamplesPerAxis;

      published
	      { Published Declarations }
         property Coronas : TGLStaticImposterBuilderCoronas read FCoronas write SetCoronas;
         property SampleSize : Integer read FSampleSize write SetSampleSize default 32;

   end;

{   // TGLDynamicImposterBuilder
   //
   TGLDynamicImposterBuilder = class(TGLBaseSceneObject)
      private
         FMinTexSize, FMaxTexSize : Integer;
         FMinDistance, FTolerance : Single;
         FImposterRegister : TList;
         FEnabled, FUseMatrixError : Boolean;

      protected
         procedure SetMinDistance(const Value : Single);
         procedure SetEnabled(const Value : Boolean);

      public
         constructor Create(AOwner : TComponent); override;
         destructor Destroy; override;
         procedure DoRender(var rci : TRenderContextInfo;
                            renderSelf, renderChildren : Boolean); override;
         procedure RegisterImposter(anImposter : TGLImposter);
         procedure UnregisterImposter(anImposter : TGLImposter);

      published
         property MinTexSize : Integer read FMinTexSize write FMinTexSize;
         property MaxTexSize : Integer read FMaxTexSize write FMaxTexSize;
         property MinDistance : Single read FMinDistance write SetMinDistance;
         property Tolerance : Single read FTolerance write FTolerance;
         property Enabled : Boolean read FEnabled write SetEnabled;
         property UseMatrixError : Boolean read FUseMatrixError write FUseMatrixError;

   end; }

   // TGLImposter
   //
   TGLImposter = class(TGLImmaterialSceneObject)
      private
         FTextureHandle : Cardinal;
//         FBuilder : TGLImposterBuilder;
//         FOldMatrix : TMatrix;
         FDrawImposter : Boolean;
         FSize : Single;
         FTexSize : Integer;
         FLastTexSize : Integer;
         FInvalidated,
         FUseAlphaTest : Boolean;

      protected
{         procedure SetBuilder(const val : TGLImposterBuilder);
         function CalcError(NewMatrix : TMatrix) : Single;
         function GetTextureHandle : Cardinal;}

      public
         constructor Create(AOwner : TComponent); override;
         destructor Destroy; override;
         procedure DoRender(var rci : TRenderContextInfo;
                            renderSelf, renderChildren : Boolean); override;
{         procedure Invalidate;
         function AxisAlignedDimensionsUnscaled : TVector; override;

         property TextureHandle : Cardinal read GetTextureHandle;}

      published
{         property Builder : TGLImposterBuilder read FBuilder write SetBuilder;
         property AlphaTest : Boolean read FUseAlphaTest write FUseAlphaTest;}
  end;

//-------------------------------------------------------------
//-------------------------------------------------------------
//-------------------------------------------------------------
implementation
//-------------------------------------------------------------
//-------------------------------------------------------------
//-------------------------------------------------------------

uses SysUtils, OpenGL1x, GLUtils;

// ----------
// ---------- TImposter ----------
// ----------

// Create
//
constructor TImposter.Create(aBuilder : TGLImposterBuilder);
begin
   inherited Create;
   FBuilder:=aBuilder;
   FTexture:=TGLTextureHandle.Create;
end;

// Destroy
//
destructor TImposter.Destroy;
begin
   FTexture.Free;
   inherited;
end;

// PrepareTexture
//
procedure TImposter.PrepareTexture;
var
   i : Integer;
begin
   if FTexture.Handle<>0 then Exit;

   FTexture.AllocateHandle;
   glBindTexture(GL_TEXTURE_2D, FTexture.Handle);
   if GL_EXT_texture_edge_clamp then
      i:=GL_CLAMP_TO_EDGE
   else i:=GL_CLAMP;
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, i);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, i);
 	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
end;

// BeginRender
//
procedure TImposter.BeginRender(var rci : TRenderContextInfo);
var
   mat : TMatrix;
begin
   glPushAttrib(GL_ENABLE_BIT);
   glDisable(GL_LIGHTING);
   glDisable(GL_CULL_FACE);
   glDisable(GL_ALPHA_TEST);

   if impoBlended in Options then begin
      glEnable(GL_BLEND);
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
   end else glDisable(GL_BLEND);

   glEnable(GL_TEXTURE_2D);
   glBindTexture(GL_TEXTURE_2D, Texture.Handle);

   if GL_VERSION_1_2 or GL_EXT_texture_edge_clamp then begin
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
   end else begin
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
   end;

   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

   glGetFloatv(GL_MODELVIEW_MATRIX, @mat);
   FVx[0]:=mat[0][0];   FVy[0]:=mat[0][1];
   FVx[1]:=mat[1][0];   FVy[1]:=mat[1][1];
   FVx[2]:=mat[2][0];   FVy[2]:=mat[2][1];
   NormalizeVector(FVx);
   NormalizeVector(FVy);

   FQuad[0]:=VectorCombine(FVx, FVy,  1,  1);
   FQuad[1]:=VectorCombine(FVx, FVy, -1,  1);
   FQuad[2]:=VectorCombine(FVx, FVy, -1, -1);
   FQuad[3]:=VectorCombine(FVx, FVy,  1, -1);
end;

// Render
//
procedure TImposter.Render(var rci : TRenderContextInfo;
                           const objPos, localCameraPos : TVector;
                           size : Single);
begin
   glBegin(GL_QUADS);
      glTexCoord2f(1, 1);  glVertex3f(FQuad[0][0]*size+objPos[0], FQuad[0][1]*size+objPos[1], FQuad[0][2]*size+objPos[2]);
      glTexCoord2f(0, 1);  glVertex3f(FQuad[1][0]*size+objPos[0], FQuad[1][1]*size+objPos[1], FQuad[1][2]*size+objPos[2]);
      glTexCoord2f(0, 0);  glVertex3f(FQuad[2][0]*size+objPos[0], FQuad[2][1]*size+objPos[1], FQuad[2][2]*size+objPos[2]);
      glTexCoord2f(1, 0);  glVertex3f(FQuad[3][0]*size+objPos[0], FQuad[3][1]*size+objPos[1], FQuad[3][2]*size+objPos[2]);
   glEnd;
end;

// EndRender
//
procedure TImposter.EndRender(var rci : TRenderContextInfo);
begin
   glPopAttrib;
end;

// ----------
// ---------- TGLImposterBuilder ----------
// ----------

// Create
//
constructor TGLImposterBuilder.Create(AOwner : TComponent);
begin
   inherited;
   FImposterRegister:=TPersistentObjectList.Create;
end;

// Destroy
//
destructor TGLImposterBuilder.Destroy;
var
   i : Integer;
begin
   for i:=0 to FImposterRegister.Count-1 do
      TImposter(FImposterRegister[i]).FBuilder:=nil;
   FImposterRegister.Free;
   inherited;
end;

// CreateNewImposter
//
function TGLImposterBuilder.CreateNewImposter : TImposter;
begin
   Result:=TImposter.Create(Self);
end;

// NotifyChange
//
procedure TGLImposterBuilder.NotifyChange(Sender : TObject);
var
   i : Integer;
begin
   for i:=0 to FImposterRegister.Count-1 do
      TImposter(FImposterRegister).Texture.DestroyHandle;
   inherited;
end;

// ----------
// ---------- TGLStaticImposterBuilderCorona ----------
// ----------

// Create
//
constructor TGLStaticImposterBuilderCorona.Create(Collection : TCollection);
begin
   inherited;
   FSamples:=8;
end;

// Destroy
//
destructor TGLStaticImposterBuilderCorona.Destroy;
begin
   inherited;
end;

// Assign
//
procedure TGLStaticImposterBuilderCorona.Assign(Source: TPersistent);
begin
   if Source is TGLStaticImposterBuilderCorona then begin
      FSamples:=TGLStaticImposterBuilderCorona(Source).FSamples;
      FElevation:=TGLStaticImposterBuilderCorona(Source).FElevation;
   end;
   inherited;
end;

// SampleBaseIndex
//
function TGLStaticImposterBuilderCorona.SampleBaseIndex : Integer;
var
   i : Integer;
begin
   Result:=0;
   with Collection as TGLStaticImposterBuilderCoronas do begin
      for i:=0 to Self.Index-1 do
         Result:=Result+Items[i].Samples;
   end;
end;

// GetDisplayName
//
function TGLStaticImposterBuilderCorona.GetDisplayName : String;
begin
   Result:=Format('%.1f� / %d samples', [Elevation, Samples]);
end;

// SetSamples
//
procedure TGLStaticImposterBuilderCorona.SetSamples(val : Integer);
begin
   if val<>FSamples then begin
      FSamples:=val;
      if FSamples<1 then FSamples:=1;
      (Collection as TGLStaticImposterBuilderCoronas).NotifyChange;
   end;
end;

// SetElevation
//
procedure TGLStaticImposterBuilderCorona.SetElevation(val : Single);
begin
   if val<>FElevation then begin
      FElevation:=ClampValue(val, -90, 90);
      (Collection as TGLStaticImposterBuilderCoronas).NotifyChange;
   end;
end;

// ----------
// ---------- TGLStaticImposterBuilderCoronas ----------
// ----------

// Create
//
constructor TGLStaticImposterBuilderCoronas.Create(AOwner : TPersistent);
begin
   inherited Create(AOwner, TGLStaticImposterBuilderCorona);
end;

// Add
//
function TGLStaticImposterBuilderCoronas.Add : TGLStaticImposterBuilderCorona;
begin
	Result:=(inherited Add) as TGLStaticImposterBuilderCorona;
end;

// SetItems
//
procedure TGLStaticImposterBuilderCoronas.SetItems(index : Integer; const val : TGLStaticImposterBuilderCorona);
begin
   inherited Items[index]:=val;
end;

// GetItems
//
function TGLStaticImposterBuilderCoronas.GetItems(index : Integer) : TGLStaticImposterBuilderCorona;
begin
   Result:=TGLStaticImposterBuilderCorona(inherited Items[index]);
end;

// Update
//
procedure TGLStaticImposterBuilderCoronas.Update(Item: TCollectionItem);
begin
   inherited;
   NotifyChange;
end;

// NotifyChange
//
procedure TGLStaticImposterBuilderCoronas.NotifyChange;
begin
   if (UpdateCount=0) and (GetOwner<>nil) and (GetOwner is TGLUpdateAbleComponent) then
      TGLUpdateAbleComponent(GetOwner).NotifyChange(Self);
end;

// EndUpdate
//
procedure TGLStaticImposterBuilderCoronas.EndUpdate;
begin
   inherited;
   NotifyChange;
end;

// SampleCount
//
function TGLStaticImposterBuilderCoronas.SampleCount : Integer;
var
   i : Integer;
begin
   Result:=0;
   for i:=0 to Count-1 do
      Result:=Result+Items[i].Samples;
end;

// ----------
// ---------- TStaticImposter ----------
// ----------

// Render
//
procedure TStaticImposter.Render(var rci : TRenderContextInfo;
                                 const objPos, localCameraPos : TVector;
                                 size : Single);
var
   elevationAngle, bestAngleDelta, angleDelta, azimuthAngle : Single;
   i : Integer;
   bestCorona : TGLStaticImposterBuilderCorona;
   tx, ty, tdx, tdy : Single;
   siBuilder : TGLStaticImposterBuilder;
begin
   // determine closest corona
   elevationAngle:=c180divPI*ArcTan2(localCameraPos[1], VectorLength(localCameraPos[0], localCameraPos[2]));
   bestAngleDelta:=1e20;
   bestCorona:=nil;
   siBuilder:=Builder as TGLStaticImposterBuilder;
   with siBuilder.Coronas do begin
      for i:=0 to Count-1 do begin
         angleDelta:=Abs(Items[i].Elevation-elevationAngle);
         if angleDelta<bestAngleDelta then begin
            bestAngleDelta:=angleDelta;
            bestCorona:=Items[i];
         end;
      end;
   end;
   Assert(Assigned(bestCorona));

   // determine closest sample in corona
   azimuthAngle:=ArcTan2(localCameraPos[2], localCameraPos[0])+PI;
   i:=Round(azimuthAngle*bestCorona.Samples*cInv2PI-0.5);
   if i<0 then i:=0;
   if i>=bestCorona.Samples then i:=bestCorona.Samples-1;
   i:=bestCorona.SampleBaseIndex+i;

   tdx:=1/siBuilder.SamplesPerAxis.X;
   tdy:=1/siBuilder.SamplesPerAxis.Y;
   tx:=tdx*(i mod siBuilder.SamplesPerAxis.X);
   ty:=tdy*(i div siBuilder.SamplesPerAxis.X);

   // then render it
   glBegin(GL_QUADS);
      glTexCoord2f(tx+tdx, ty+tdy); glVertex3f(FQuad[0][0]*size+objPos[0], FQuad[0][1]*size+objPos[1], FQuad[0][2]*size+objPos[2]);
      glTexCoord2f(tx, ty+tdy);     glVertex3f(FQuad[1][0]*size+objPos[0], FQuad[1][1]*size+objPos[1], FQuad[1][2]*size+objPos[2]);
      glTexCoord2f(tx, ty);         glVertex3f(FQuad[2][0]*size+objPos[0], FQuad[2][1]*size+objPos[1], FQuad[2][2]*size+objPos[2]);
      glTexCoord2f(tx+tdx, ty);     glVertex3f(FQuad[3][0]*size+objPos[0], FQuad[3][1]*size+objPos[1], FQuad[3][2]*size+objPos[2]);
   glEnd;
end;

// ----------
// ---------- TGLStaticImposterBuilder ----------
// ----------

// Create
//
constructor TGLStaticImposterBuilder.Create(AOwner : TComponent);
begin
   inherited;
   FCoronas:=TGLStaticImposterBuilderCoronas.Create(Self);
   FSampleSize:=16;
   FCoronas.Add;
end;

// Destroy
//
destructor TGLStaticImposterBuilder.Destroy;
begin
   FCoronas.Free;
   inherited;
end;

// CreateNewImposter
//
function TGLStaticImposterBuilder.CreateNewImposter : TImposter;
begin
   Result:=TStaticImposter.Create(Self);
end;

// SetCoronas
//
procedure TGLStaticImposterBuilder.SetCoronas(val : TGLStaticImposterBuilderCoronas);
begin
   FCoronas.Assign(val);
   NotifyChange(Self);
end;

// SetSampleSize
//
procedure TGLStaticImposterBuilder.SetSampleSize(val : Integer);
begin
   val:=RoundUpToPowerOf2(val);
   if val<8 then val:=8;
   if val>512 then val:=512;
   if val<>FSampleSize then begin
      FSampleSize:=val;
      NotifyChange(Self);
   end;
end;

// Render
//
procedure TGLStaticImposterBuilder.Render(var rci : TRenderContextInfo;
            impostoredObject : TGLBaseSceneObject; buffer : TGLSceneBuffer;
            destImposter : TImposter);
var
   nbSamples, maxSamples, maxTexSize : Integer;
   texDim, bestTexDim : TGLPoint;
   requiredSurface, currentSurface, bestSurface : Integer;
   i, coronaIdx, curSample : Integer;
   radius : Single;
   cameraDirection, cameraOffset : TVector;
   xDest, xSrc, yDest, ySrc : Integer;
   corona : TGLStaticImposterBuilderCorona;
   fx, fy : Single;
   memBuffer : Pointer;
begin
   nbSamples:=Coronas.SampleCount;
   glGetIntegerv(GL_MAX_TEXTURE_SIZE, @maxTexSize);
   maxSamples:=Sqr(maxTexSize div SampleSize);
   Assert(nbSamples<maxSamples, 'Too many samples, can''t fit in a texture!');
   requiredSurface:=nbSamples*SampleSize*SampleSize;

   // determine the texture size with the best fill ratio
   bestSurface:=MaxInt;
   texDim.X:=SampleSize; while texDim.X<=maxTexSize do begin
      texDim.Y:=SampleSize; while texDim.Y<=maxTexSize do begin
         currentSurface:=texDim.X*texDim.Y;
         if currentSurface>=requiredSurface then begin
            if currentSurface<bestSurface then begin
               bestTexDim:=texDim;
               bestSurface:=currentSurface;
            end else if (currentSurface=bestSurface)
                  and (MaxInteger(texDim.X, texDim.Y)<MaxInteger(bestTexDim.X, bestTexDim.Y)) then begin
               bestTexDim:=texDim;
               bestSurface:=currentSurface;
            end else Break;
         end;
         texDim.Y:=texDim.Y*2;
      end;
      texDim.X:=texDim.X*2;
   end;
   Assert(bestSurface<>MaxInt);

   FTextureSize:=bestTexDim;
   FSamplesPerAxis.X:=bestTexDim.X div SampleSize;
   FSamplesPerAxis.Y:=bestTexDim.Y div SampleSize;

   radius:=impostoredObject.BoundingSphereRadius;

   // Setup the buffer in a suitable fashion for our needs
   glPushAttrib(GL_ENABLE_BIT+GL_COLOR_BUFFER_BIT);
   glClearColor(0, 0, 0, 0);
   //   glDisable(GL_LIGHTING);

   glMatrixMode(GL_PROJECTION);
   glPushMatrix;
   glLoadIdentity;
   fx:=buffer.Width/SampleSize;
   fy:=buffer.Height/SampleSize;
   glOrtho(-radius*fx, radius*fx, -radius*fy, radius*fy, radius*0.5, radius*5);
   xSrc:=(buffer.Width-SampleSize) div 2;
   ySrc:=(buffer.Height-SampleSize) div 2;

   glMatrixMode(GL_MODELVIEW);
   glPushMatrix;

   // setup imposter texture
   if destImposter.Texture.Handle=0 then begin
      destImposter.PrepareTexture;
      memBuffer:=GetMemory(bestSurface*4);
      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, TextureSize.X, TextureSize.Y, 0,
                   GL_RGBA, GL_UNSIGNED_BYTE, memBuffer);
      FreeMemory(memBuffer);
   end else glBindTexture(GL_TEXTURE_2D, destImposter.Texture.Handle);

   // Now render each sample
   curSample:=0;
   for coronaIdx:=0 to Coronas.Count-1 do begin
      corona:=Coronas[coronaIdx];
      for i:=0 to corona.Samples-1 do begin
         cameraDirection:=XHmgVector;
         RotateVector(cameraDirection, YHmgVector, (c2PI*i)/corona.Samples);
         cameraOffset:=VectorScale(cameraDirection, radius*2);

         glClear(GL_COLOR_BUFFER_BIT+GL_DEPTH_BUFFER_BIT);
         glLoadIdentity;
         gluLookAt(cameraOffset[0], cameraOffset[1], cameraOffset[2], 0, 0, 0, 0, 1, 0);
         impostoredObject.Render(rci);

         xDest:=(curSample mod FSamplesPerAxis.X)*SampleSize;
         yDest:=(curSample div FSamplesPerAxis.X)*SampleSize;
         glCopyTexSubImage2D(GL_TEXTURE_2D, 0, xDest, yDest, xSrc, ySrc,
                             SampleSize, SampleSize);

         Inc(curSample);
      end;
   end;

   // Restore buffer stuff
   glPopAttrib;
   glPopMatrix;
   glMatrixMode(GL_PROJECTION);
   glPopMatrix;
   glMatrixMode(GL_MODELVIEW);

   glClear(GL_COLOR_BUFFER_BIT+GL_DEPTH_BUFFER_BIT);
end;

{
// ----------
// ---------- TGLDynamicImposterBuilder ----------
// ----------

// Create
//
constructor TGLDynamicImposterBuilder.Create(AOwner : TComponent);
begin
  inherited;
  FImposterRegister:=TList.Create;
  FTolerance:=0.1;
  FUseMatrixError:=True;
  FMinTexSize:=16;
  FMaxTexSize:=64;
  ObjectStyle:=ObjectStyle+[osDirectDraw];
end;

// Destroy
//
destructor TGLDynamicImposterBuilder.Destroy;
var
  i : Integer;
begin
  for i:=FImposterRegister.Count-1 downto 0 do
    TGLImposter(FImposterRegister[i]).Builder:=nil;
  FImposterRegister.Free;
  inherited;
end;

// DoRender
//
procedure TGLDynamicImposterBuilder.DoRender(var rci : TRenderContextInfo;
  renderSelf, renderChildren : Boolean);
var
  i, size, Left, Top, Width, Height : Integer;
  imposter : TGLImposter;
  mat, projection, modelview : TMatrix;
  BackColor, pos, temp : TVector;
  rad : Single;
  AABB : TAABB;
begin
  if (csDesigning in ComponentState) or not FEnabled then exit;

  // Store the current clear color
  glGetFloatv(GL_COLOR_CLEAR_VALUE, @BackColor[0]);

  // Get the projection matrix
  if UseMatrixError then
    glGetFloatv(GL_PROJECTION_MATRIX, @projection);

  // Render and save each imposter as required
  for i:=0 to FImposterRegister.Count-1 do begin
    imposter:=TGLImposter(FImposterRegister[i]);
    if (imposter.Count = 0) or not imposter.Visible then Continue;
    imposter.FDrawImposter:=True;

    if VectorDistance(imposter.AbsolutePosition, rci.cameraPosition)<FMinDistance then begin
      imposter.FDrawImposter:=False;
      Continue;
    end;

    glMatrixMode(GL_MODELVIEW);
    glPushMatrix;
    glMultMatrixf(@imposter.AbsoluteMatrixAsAddress[0]);
    glGetFloatv(GL_MODELVIEW_MATRIX, @modelview);

    // Get imposters dimensions
    AABB:=imposter.AxisAlignedBoundingBox;
    rad:=MaxFloat(AABB.max[0],AABB.max[1],AABB.max[2]);
    pos:=imposter.AbsolutePosition;
    temp:=Scene.CurrentBuffer.Camera.AbsoluteEyeSpaceVector(0,1,0);
    temp:=VectorAdd(pos, VectorScale(temp,rad));
    pos:=Scene.CurrentBuffer.WorldToScreen(pos);
    temp:=Scene.CurrentBuffer.WorldToScreen(temp);
    size:=RoundUpToPowerOf2(Round(2*VectorDistance(pos,temp)));
    if size<FMinTexSize then size:=FMinTexSize;
    if size>FMaxTexSize then begin
      imposter.FDrawImposter:=False;
      glPopMatrix;
      Continue;
    end;
    temp:=pos;
    temp[0]:=temp[0]+size;
    temp:=Scene.CurrentBuffer.ScreenToWorld(temp);
    Imposter.FSize:=VectorDistance(imposter.AbsolutePosition,temp);
    imposter.FTexSize:=size;
    pos[0]:=pos[0]-size/2;
    pos[1]:=pos[1]-size/2;

    // Calculate error
    if UseMatrixError then begin
      mat:=MatrixMultiply(modelview, projection);
      if (imposter.CalcError(mat)>FTolerance) or (imposter.FInvalidated) then
        imposter.FOldMatrix:=mat
      else begin
        glPopMatrix;
        Continue;
      end;
    end;

    // Clear to transparent black
    glClearColor(0,0,0,0);

    // Determine size by color (for debug purposes)
    (*case size of
      16 : glClearColor(0,0,1,0.1);
      32 : glClearColor(0,1,0,0.1);
      64 : glClearColor(1,0,0,0.1);
      128 : glClearColor(1,1,0,0.1);
      256 : glClearColor(1,0,1,0.1);
    end;// *)

    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);

    // Render the imposter's children
    imposter.RenderChildren(0, imposter.Count-1, rci);
    glPopMatrix;

    // Select the imposters texture (will create the handle if null)
    glBindTexture(GL_TEXTURE_2D,imposter.TextureHandle);

    // Check for resize or invalidation
    if (imposter.FTexSize <> imposter.FLastTexSize)
    or (imposter.FInvalidated) then begin
      glTexImage2d(GL_TEXTURE_2D, 0, GL_RGBA, size, size, 0, GL_RGBA, GL_UNSIGNED_BYTE, nil);
      imposter.FLastTexSize:=imposter.FTexSize;
      imposter.FInvalidated:=False;
      imposter.NotifyChange(self);
    end;

    // Get the region to be copied from the frame buffer
    Left:=Floor(pos[0]); Top:=Floor(pos[1]);
    Width:=Size; Height:=Size;
    // ... Perhaps some region clamping here?

    // Copy the frame buffer pixels to the imposter texture
    glCopyTexSubImage2d(GL_TEXTURE_2D, 0, 0, 0,
                        Left, Top, Width, Height);
  end;

  // Reset the clear color and clear color, depth and stencil buffers
  glClearColor(BackColor[0],BackColor[1],BackColor[2],BackColor[3]);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
end;

// RegisterImposter
//
procedure TGLDynamicImposterBuilder.RegisterImposter(anImposter: TGLImposter);
begin
  if FImposterRegister.IndexOf(anImposter) = -1 then
    FImposterRegister.Add(anImposter);
end;

// UnregisterImposter
//
procedure TGLDynamicImposterBuilder.UnregisterImposter(anImposter: TGLImposter);
begin
  FImposterRegister.Remove(anImposter);
end;

// SetMinDistance
//
procedure TGLDynamicImposterBuilder.SetMinDistance(const Value : Single);
begin
  if Value<>FMinDistance then begin
    FMinDistance:=Value;
    StructureChanged;
  end;
end;

// SetEnabled
//
procedure TGLDynamicImposterBuilder.SetEnabled(const Value : Boolean);
var
  i : Integer;
begin
  if Value <> FEnabled then begin
    FEnabled:=Value;
    for i:=0 to FImposterRegister.Count-1 do begin
      if not FEnabled then
        TGLImposter(FImposterRegister[i]).FDrawImposter:=False;
      TGLImposter(FImposterRegister[i]).NotifyChange(Self);
    end;
  end;
end;
}

// ----------
// ---------- TGLImposter ----------
// ----------

// Create
//
constructor TGLImposter.Create(AOwner : TComponent);
begin
  inherited;
  FTextureHandle:=0;
  FDrawImposter:=False;
  FInvalidated:=False;
  FUseAlphaTest:=False;
  FSize:=1;
  FTexSize:=0;
  FLastTexSize:=-1;
  ObjectStyle:=ObjectStyle+[osDirectDraw];
end;

// Destroy
//
destructor TGLImposter.Destroy;
begin
{   Builder:=nil;
   if FTextureHandle<>0 then
      glDeleteTextures(1, @FTextureHandle);}
   inherited;
end;

// DoRender
//
procedure TGLImposter.DoRender(var rci : TRenderContextInfo;
  renderSelf, renderChildren : Boolean);
{var
  vx, vy : TAffineVector;
  s : Single;
  mat : TMatrix;}
begin
{  if (not (csDesigning in ComponentState))
  and FDrawImposter and (FTextureHandle<>0) then begin
    // Render the imposter sprite
    glPushAttrib(GL_ENABLE_BIT or GL_COLOR_BUFFER_BIT);
    glDisable(GL_LIGHTING);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    if AlphaTest then begin
      glEnable(GL_ALPHA_TEST);
      glAlphaFunc(GL_GEQUAL, 0.99);
    end;

    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, FTextureHandle);

    if GL_VERSION_1_2 or GL_EXT_texture_edge_clamp then begin
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    end else begin
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
    end;

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glGetFloatv(GL_MODELVIEW_MATRIX, @mat);
    glBegin(GL_QUADS);
      s:=FSize*0.5;
      vx[0]:=mat[0][0];  vy[0]:=mat[0][1];
      vx[1]:=mat[1][0];  vy[1]:=mat[1][1];
      vx[2]:=mat[2][0];  vy[2]:=mat[2][1];
      ScaleVector(vx, s/VectorLength(vx));
      ScaleVector(vy, s/VectorLength(vy));
      glTexCoord2f(1,1);  glVertex3f( vx[0]+vy[0], vx[1]+vy[1], vx[2]+vy[2]);
      glTexCoord2f(0,1);  glVertex3f(-vx[0]+vy[0],-vx[1]+vy[1],-vx[2]+vy[2]);
      glTexCoord2f(0,0);  glVertex3f(-vx[0]-vy[0],-vx[1]-vy[1],-vx[2]-vy[2]);
      glTexCoord2f(1,0);  glVertex3f( vx[0]-vy[0], vx[1]-vy[1], vx[2]-vy[2]);
    glEnd;
    glPopAttrib;
  end else begin
    Self.RenderChildren(0,Count-1,rci);
  end; }
end;
{
// SetBuilder
//
procedure TGLImposter.SetBuilder(const val : TGLDynamicImposterBuilder);
begin
  if val<>FBuilder then begin
    if Assigned(FBuilder) then
      FBuilder.UnregisterImposter(Self);
    FBuilder:=val;
    if Assigned(FBuilder) then
      FBuilder.RegisterImposter(Self);
  end;
end;

// AxisAlignedDimensionsUnscaled
//
function TGLImposter.AxisAlignedDimensionsUnscaled : TVector;
begin
   Result:=NullHMGVector;
end;

// CalcDifference
//
function TGLImposter.CalcError(NewMatrix : TMatrix) : Single;
var
   i : Integer;
   mat : TMatrix;
   err : Single;
begin
   err:=0;
   mat:=NewMatrix;
   InvertMatrix(mat);
   mat:=MatrixMultiply(FOldMatrix, mat);
   for i:=0 to 3 do mat[i][i]:=mat[i][i]-1;
   for i:=0 to 15 do err:=err+Abs(mat[i div 4][i mod 4]);
   Result:=err;
end;

// GetTextureHandle
//
function TGLImposter.GetTextureHandle: Cardinal;
begin
  if FTextureHandle = 0 then
    glGenTextures(1, @FTextureHandle);
  Result:=FTextureHandle;
end;

// Invalidate
//
procedure TGLImposter.Invalidate;
begin
  FInvalidated:=True;
end;
}
initialization

//  RegisterClasses([TGLDynamicImposterBuilder, TGLImposter]);

end.
