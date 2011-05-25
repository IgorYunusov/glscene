//
// This unit is part of the GLScene Project, http://glscene.org
//
{: GLSDrawTechnique<p>

   <b>History : </b><font size=-1><ul>
    <li>25/05/11 - Yar - Added instancing 
    <li>18/05/11 - Yar - Added axes drawing
    <li>17/04/11 - Yar - Creation
 </ul></font>
}

unit GLSDrawTechnique;

interface

{$I GLScene.inc}

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  Classes,
  SysUtils,
  BaseClasses,
  GLCrossPlatform,
  GLPipelineTransformation,
  GLContext,
  GLState,
  GLRenderContextInfo,
  OpenGLTokens,
  GLSMesh,
  GLMaterial;

const
  VBO_STATIC_POOL_SIZE: Cardinal = 16 * 1024 * 1024;

type

  PDrawBatch = ^TDrawBatch;
  TDrawBatch = record
    Mesh: TMeshAtom;
    InstancesChain: TInstancesChain;
    Material: TGLAbstractLibMaterial;
    Transformation: PTransformationRec;
    ShowAxes: Boolean;
    ShowAABB: Boolean;
    Changed: Boolean;
    Order: Integer;
  end;

  PPoolSector = ^TPoolSector;
  TPoolSector = record
    Mesh: TMeshAtom;
    Offset: PtrUInt;
    Size: Cardinal;
  end;

  TPoolMapType = (pmtArray, pmtElement);

  TPoolMap = class(TList)
  private
    FType: TPoolMapType;
    function GetSector(Index: Integer): PPoolSector;
    procedure PutSector(Index: Integer; Item: PPoolSector);
  public
    constructor Create(AType: TPoolMapType);
    function AddSector(const AItem: TPoolSector): Integer;
    procedure InsertSector(Index: Integer; const AItem: TPoolSector);
    procedure DeleteSector(Index: Integer);
    procedure Clear; override;
    property Sectors[Index: Integer]: PPoolSector read GetSector write PutSector;
  end;

  // TGLAbstractDrawTechnique
  //
  TGLAbstractDrawTechnique = class(TObject)
  protected
    { Protected Declarations }
    function GetAABBMaterial: TGLAbstractLibMaterial;
    procedure DoBeforeAABBDrawing(var ARci: TRenderContextInfo); virtual; abstract;
    procedure DoAfterAABBDrawing(var ARci: TRenderContextInfo); virtual; abstract;
    procedure ApplyInstance(var ARci: TRenderContextInfo;
      const AInstance: TInstancesChain; const AID: Integer); virtual; abstract;
  public
    { Public Declarations }
    procedure DrawBatch(
      var ARci: TRenderContextInfo;
      const ABatch: TDrawBatch); virtual; abstract;
    procedure DrawAABB(
      var ARci: TRenderContextInfo;
      const ABatch: TDrawBatch); virtual; abstract;
  end;

  TGLAbstractDrawTechniqueClass = class of TGLAbstractDrawTechnique;

  // TGLDrawTechniqueOGL1
  //
  { : Fixed function pipeline draw technique. }
  TGLDrawTechniqueOGL1 = class(TGLAbstractDrawTechnique)
  protected
    { Protected Declarations }
    procedure DoBeforeAABBDrawing(var ARci: TRenderContextInfo); override;
    procedure DoAfterAABBDrawing(var ARci: TRenderContextInfo); override;
    procedure ApplyInstance(var ARci: TRenderContextInfo;
      const AInstance: TInstancesChain; const AID: Integer); override;
  public
    { Public Declarations }
    procedure DrawBatch(
      var ARci: TRenderContextInfo;
      const ABatch: TDrawBatch); override;
    procedure DrawAABB(
      var ARci: TRenderContextInfo;
      const ABatch: TDrawBatch); override;
  end;

  // TGLDrawTechniqueOGL2
  //
  { : Programable pipeline draw technique. }
  TGLDrawTechniqueOGL2 = class(TGLAbstractDrawTechnique)
  protected
    { Protected Declarations }
    FDrawAsElement: Boolean;
    FIndexType: TGLEnum;
    FIndexSize: Byte;

    FArrayHandle: TGLVBOArrayBufferHandle;
    FElementHandle: TGLVBOElementArrayHandle;
    FArrayBufferMap: TPoolMap;
    FElementBufferMap: TPoolMap;

    procedure AllocateBuffers;
    procedure PlacedInBuffer(AMesh: TMeshAtom);
    function BindStateHandle(
      const AStates: TGLStateCache;
      const AMesh: TMeshAtom): Boolean;

    procedure DoBeforeAABBDrawing(var ARci: TRenderContextInfo); override;
    procedure DoAfterAABBDrawing(var ARci: TRenderContextInfo); override;
    procedure ApplyInstance(var ARci: TRenderContextInfo;
      const AInstance: TInstancesChain; const AID: Integer); override;
  public
    { Public Declarations }
    constructor Create; virtual;
    destructor Destroy; override;

    procedure DrawBatch(
      var ARci: TRenderContextInfo;
      const ABatch: TDrawBatch); override;
    procedure DrawAABB(
      var ARci: TRenderContextInfo;
      const ABatch: TDrawBatch); override;
  end;

  TGLDrawTechniqueOGL3 = class(TGLDrawTechniqueOGL2)
  protected
    { Protected Declarations }
    FCommonVAO: TGLVertexArrayHandle;
    procedure DoBeforeAABBDrawing(var ARci: TRenderContextInfo); override;
    procedure DoAfterAABBDrawing(var ARci: TRenderContextInfo); override;
//    procedure ApplyInstance(var ARci: TRenderContextInfo;
//      const AInstance: TInstancesChain; const AID: Integer); override;
  public
    { Public Declarations }
    constructor Create; override;
    destructor Destroy; override;

    procedure DrawBatch(
      var ARci: TRenderContextInfo;
      const ABatch: TDrawBatch); override;
  end;

  TGLDrawTechniqueOGL4 = class(TGLDrawTechniqueOGL3)
  public
    { Public Declarations }
    procedure DrawBatch(
      var ARci: TRenderContextInfo;
      const ABatch: TDrawBatch); override;
  end;

  TDrawOrder = record
    Order: Integer;
    Index: Integer;
  end;
  TDrawOrderArray = array of TDrawOrder;

  // TGLRenderManager
  //
  TGLRenderManager = class(TGLUpdateAbleObject)
  protected
    FBatchList: TList;
    FDrawOrderArray: TDrawOrderArray;
    FAxesBatch: TDrawBatch;
    function GetDrawTechnique: TGLAbstractDrawTechnique; virtual;
  public
    { Public Declarations }
    constructor Create(AOwner: TPersistent); override;
    destructor Destroy; override;
    procedure RegisterBatch(var ABatch: TDrawBatch);
    procedure UnRegisterBatch(var ABatch: TDrawBatch);
    procedure DrawOrderedAll(var ARci: TRenderContextInfo);

    property DrawTechnique: TGLAbstractDrawTechnique read GetDrawTechnique;
  end;

function GetOrCreateDummyCubeMaterial: TGLAbstractLibMaterial;
procedure AxesBuildMesh(AMesh: TMeshAtom; AnAxisLen: Single);

implementation

uses
  GLMaterialEx,
  GLColor,
  GLStrings,
  VectorGeometry,
  VectorTypes,
  VectorLists,
  GLSLParameter,
  GLSLog;

const
  cPrimitiveType: array[mpTRIANGLES..mpPATCHES] of GLenum = (GL_TRIANGLES,
    GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN, GL_POINTS, GL_LINES, GL_LINE_LOOP,
    GL_LINE_STRIP, GL_LINES_ADJACENCY, GL_LINE_STRIP_ADJACENCY,
    GL_TRIANGLES_ADJACENCY, GL_TRIANGLE_STRIP_ADJACENCY, GL_PATCHES);

const
  cAdjacencyPrimitives = [mpTRIANGLES_ADJACENCY, mpTRIANGLE_STRIP_ADJACENCY];

const
  cAABBIndices: array[0..23] of TGLUShort =
    (
    0, 1, 1, 2, 2, 3, 3, 0,
    4, 5, 5, 6, 6, 7, 7, 4,
    0, 4, 1, 5, 2, 6, 3, 7
    );

type
  TFriendlyMesh = class(TMeshAtom);
  TFriendlyInstancesChain = class(TInstancesChain);

var
  vDrawTechniques: array[0..3] of TGLAbstractDrawTechnique;

function GetOrCreateDummyCubeMaterial: TGLAbstractLibMaterial;
const
  cDummyCubeMaterialName = 'GLScene_DummyCube_Material';
begin
  Result :=
    GetInternalMaterialLibrary.Materials.GetLibMaterialByName(cDummyCubeMaterialName);
  if Result = nil then
  begin
    Result := GetInternalMaterialLibrary.Materials.Add;
    with TGLLibMaterialEx(Result) do
    begin
      Name := cDummyCubeMaterialName;
      FixedFunction.BlendingMode := bmTransparency;
      FixedFunction.MaterialOptions := [moNoLighting];
      FixedFunction.LineProperties.Enabled := True;
      FixedFunction.LineProperties.StippleFactor := 1;
      FixedFunction.LineProperties.Smooth := True;
    end;
  end;
end;

procedure AxesBuildMesh(AMesh: TMeshAtom; AnAxisLen: Single);
begin
  with AMesh do
  begin
    Lock;
    try
      Clear;
      DeclareAttribute(attrPosition, GLSLType3f);
      DeclareAttribute(attrColor, GLSLType3f);

      BeginAssembly(mpLINES);

      Attribute3f(attrColor, 0.5, 0.0, 0.0);
      Attribute3f(attrPosition, NullVector);
      EmitVertex;
      Attribute3f(attrPosition, -AnAxisLen, 0, 0);
      EmitVertex;

      Attribute3f(attrColor, 1.0, 0.0, 0.0);
      Attribute3f(attrPosition, NullVector);
      EmitVertex;
      Attribute3f(attrPosition, AnAxisLen, 0, 0);
      EmitVertex;

      Attribute3f(attrColor, 0.0, 0.5, 0.0);
      Attribute3f(attrPosition, NullVector);
      EmitVertex;
      Attribute3f(attrPosition, 0, -AnAxisLen, 0);
      EmitVertex;

      Attribute3f(attrColor, 0.0, 1.0, 0.0);
      Attribute3f(attrPosition, NullVector);
      EmitVertex;
      Attribute3f(attrPosition, 0, AnAxisLen, 0);
      EmitVertex;

      Attribute3f(attrColor, 0.0, 0.0, 0.5);
      Attribute3f(attrPosition, NullVector);
      EmitVertex;
      Attribute3f(attrPosition, 0, 0, -AnAxisLen);
      EmitVertex;

      Attribute3f(attrColor, 0.0, 0.0, 1.0);
      Attribute3f(attrPosition, NullVector);
      EmitVertex;
      Attribute3f(attrPosition, 0, 0, AnAxisLen);
      EmitVertex;
      EndAssembly;
    finally
      UnLock;
    end;
  end;
end;

procedure ReleaseDrawTechniques;
var
  I: Integer;
begin
  for I := 0 to High(vDrawTechniques) do
    FreeAndNil(vDrawTechniques[I]);
end;

procedure RoundTo(var Value: Cardinal; Step: Cardinal);
{$IFDEF GLS_INLINE} inline;
{$ENDIF}
var
  L: Cardinal;
begin
  L := Value mod Step;
  if L > 0 then
    Inc(Value, Step - L);
end;

{$IFDEF GLS_REGION}{$REGION 'TGLAbstractDrawTechnique'}{$ENDIF}

function TGLAbstractDrawTechnique.GetAABBMaterial: TGLAbstractLibMaterial;
const
  cAABBMaterialName = 'GLScene_AABB_Material';
  cAABBVertexShader120 =
    '#version 120'#10#13 +
    'attribute vec3 Position;'#10#13 +
    'uniform mat4 ModelViewProjectionMatrix;'#10#13 +
    'void main() { gl_Position = ModelViewProjectionMatrix * vec4(Position,1.0); }';
  cAABBFragmentShader120 =
    '#version 120'#10#13 +
    'void main() { gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0); }'#10#13;
  cAABBVertexShader330 =
    '#version 330'#10#13 +
    'in vec3 Position;'#10#13 +
    'uniform mat4 ModelViewProjectionMatrix;'#10#13 +
    'void main() { gl_Position = ModelViewProjectionMatrix * vec4(Position,1.0); }';
  cAABBFragmentShader330 =
    '#version 330'#10#13 +
    'out vec4 FragColor;'#10#13 +
    'void main() { FragColor = vec4(1.0, 0.0, 0.0, 1.0); }'#10#13;
var
  LShader: TGLShaderEx;
begin
  Result := GetInternalMaterialLibrary.Materials.GetLibMaterialByName(cAABBMaterialName);
  if Result = nil then
  begin
    Result := GetInternalMaterialLibrary.Materials.Add;
    with TGLLibMaterialEx(Result) do
    begin
      Name := cAABBMaterialName;
      // FFP
      FixedFunction.MaterialOptions := [moNoLighting];
      FixedFunction.FrontProperties.Diffuse.DirectColor := clrRed;
      FixedFunction.LineProperties.Enabled := True;
      // GLSL 120
      LShader := GetInternalMaterialLibrary.AddShader(cInternalShader);
      LShader.ShaderType := shtVertex;
      LShader.Source.Add(cAABBVertexShader120);
      ShaderModel3.LibVertexShaderName := LShader.Name;
      LShader := GetInternalMaterialLibrary.AddShader(cInternalShader);
      LShader.ShaderType := shtFragment;
      LShader.Source.Add(cAABBFragmentShader120);
      ShaderModel3.LibFragmentShaderName := LShader.Name;
      ShaderModel3.Enabled := True;
      ShaderModel3.DoOnPrepare(CurrentGLContext);
      if ShaderModel3.IsValid then
        ShaderModel3.Uniforms['ModelViewProjectionMatrix'].AutoSetMethod := cafWorldViewProjectionMatrix;
      // GLSL 330
      LShader := GetInternalMaterialLibrary.AddShader(cInternalShader);
      LShader.ShaderType := shtVertex;
      LShader.Source.Add(cAABBVertexShader330);
      ShaderModel4.LibVertexShaderName := LShader.Name;
      LShader := GetInternalMaterialLibrary.AddShader(cInternalShader);
      LShader.ShaderType := shtFragment;
      LShader.Source.Add(cAABBFragmentShader330);
      ShaderModel4.LibFragmentShaderName := LShader.Name;
      ShaderModel4.Enabled := True;
      ShaderModel4.DoOnPrepare(CurrentGLContext);
      if ShaderModel4.IsValid then
        ShaderModel4.Uniforms['ModelViewProjectionMatrix'].AutoSetMethod := cafWorldViewProjectionMatrix;
    end;
  end;
end;

{$IFDEF GLS_REGION}{$ENDREGION}{$ENDIF}

{$IFDEF GLS_REGION}{$REGION 'TGLDrawTechniqueOGL1'}{$ENDIF}

// ------------------
// ------------------ TGLDrawTechniqueOGL1 ------------------
// ------------------

procedure TGLDrawTechniqueOGL1.ApplyInstance(var ARci: TRenderContextInfo;
  const AInstance: TInstancesChain; const AID: Integer);
var
  A: TAttribLocation;
  T: TGLEnum;
  LLink: TFriendlyInstancesChain;
  I: Integer;
begin
  LLink := TFriendlyInstancesChain(AInstance);

  with GL do
  begin
    // Texture coordinates
    if ARB_multisample then
    begin
      T := 7;
      for A := attrTexCoord7 downto attrTexCoord0 do
      begin
        if LLink.FAttributes[A] then
        begin
          ClientActiveTexture(GL_TEXTURE0 + T);
          DisableClientState(GL_TEXTURE_COORD_ARRAY);
          I := AID;
          if LLink.FAttributeDivisor[A] > 1 then
            I := I div LLink.FAttributeDivisor[A];
          case LLink.FType[A] of
            GLSLType1F: MultiTexCoord1f(GL_TEXTURE0 + T, PSingle(@LLink.FAttributeArrays[A].List[I])^);
            GLSLType2F: MultiTexCoord2fv(GL_TEXTURE0 + T, @LLink.FAttributeArrays[A].List[2 * I]);
            GLSLType3F: MultiTexCoord3fv(GL_TEXTURE0 + T, @LLink.FAttributeArrays[A].List[3 * I]);
            GLSLType4F: MultiTexCoord4fv(GL_TEXTURE0 + T, @LLink.FAttributeArrays[A].List[4 * I]);
            GLSLType1I: MultiTexCoord1i(GL_TEXTURE0 + T, PInteger(@LLink.FAttributeArrays[A].List[I])^);
            GLSLType2I: MultiTexCoord2iv(GL_TEXTURE0 + T, @LLink.FAttributeArrays[A].List[2 * I]);
            GLSLType3I: MultiTexCoord3iv(GL_TEXTURE0 + T, @LLink.FAttributeArrays[A].List[3 * I]);
            GLSLType4I: MultiTexCoord4iv(GL_TEXTURE0 + T, @LLink.FAttributeArrays[A].List[4 * I]);
          end;
        end;
        Dec(T);
      end;
    end
    else
    begin
      // Only one texture unit avaible
      if LLink.FAttributes[attrTexCoord0] then
      begin
        DisableClientState(GL_TEXTURE_COORD_ARRAY);
        I := AID;
        if LLink.FAttributeDivisor[attrTexCoord0] > 1 then
          I := I div LLink.FAttributeDivisor[attrTexCoord0];
        case LLink.FType[attrTexCoord0] of
          GLSLType1F: TexCoord1f(PSingle(@LLink.FAttributeArrays[attrTexCoord0].List[I])^);
          GLSLType2F: TexCoord2fv(@LLink.FAttributeArrays[attrTexCoord0].List[2 * I]);
          GLSLType3F: TexCoord3fv(@LLink.FAttributeArrays[attrTexCoord0].List[3 * I]);
          GLSLType4F: TexCoord4fv(@LLink.FAttributeArrays[attrTexCoord0].List[4 * I]);
          GLSLType1I: TexCoord1i(PInteger(@LLink.FAttributeArrays[attrTexCoord0].List[I])^);
          GLSLType2I: TexCoord2iv(@LLink.FAttributeArrays[attrTexCoord0].List[2 * I]);
          GLSLType3I: TexCoord3iv(@LLink.FAttributeArrays[attrTexCoord0].List[3 * I]);
          GLSLType4I: TexCoord4iv(@LLink.FAttributeArrays[attrTexCoord0].List[4 * I]);
        end;
      end;
    end;
    // Colors
    if LLink.FAttributes[attrColor] then
    begin
      DisableClientState(GL_COLOR_ARRAY);
      I := AID;
      if LLink.FAttributeDivisor[attrColor] > 1 then
        I := I div LLink.FAttributeDivisor[attrColor];
      case LLink.FType[attrColor] of
        GLSLType3F: Color3fv(@LLink.FAttributeArrays[attrColor].List[3 * I]);
        GLSLType4F: Color4fv(@LLink.FAttributeArrays[attrColor].List[4 * I]);
        GLSLType3I: Color3iv(@LLink.FAttributeArrays[attrColor].List[3 * I]);
        GLSLType4I: Color4iv(@LLink.FAttributeArrays[attrColor].List[4 * I]);
      end;
    end;
    // Normals
    if LLink.FAttributes[attrNormal] then
    begin
      DisableClientState(GL_NORMAL_ARRAY);
      I := AID;
      if LLink.FAttributeDivisor[attrNormal] > 1 then
        I := I div LLink.FAttributeDivisor[attrNormal];
      case LLink.FType[attrColor] of
        GLSLType3F: Normal3fv(@LLink.FAttributeArrays[attrNormal].List[3 * I]);
        GLSLType3I: Normal3iv(@LLink.FAttributeArrays[attrNormal].List[3 * I]);
      end;
    end;
    // Positions
    if LLink.FAttributes[attrPosition] then
    begin
      DisableClientState(GL_VERTEX_ARRAY);
      I := AID;
      if LLink.FAttributeDivisor[attrPosition] > 1 then
        I := I div LLink.FAttributeDivisor[attrPosition];
      case LLink.FType[attrPosition] of
        GLSLType2F: Vertex2fv(@LLink.FAttributeArrays[attrPosition].List[2 * I]);
        GLSLType3F: Vertex3fv(@LLink.FAttributeArrays[attrPosition].List[3 * I]);
        GLSLType4F: Vertex4fv(@LLink.FAttributeArrays[attrPosition].List[4 * I]);
        GLSLType2I: Vertex2iv(@LLink.FAttributeArrays[attrPosition].List[2 * I]);
        GLSLType3I: Vertex3iv(@LLink.FAttributeArrays[attrPosition].List[3 * I]);
        GLSLType4I: Vertex4iv(@LLink.FAttributeArrays[attrPosition].List[4 * I]);
      end;
    end;
  end;

  if LLink.FTransformationEnabled then
    ARci.PipelineTransformation.StackTop := PTransformationRec(LLink.FTransformations[AID])^;
end;

procedure TGLDrawTechniqueOGL1.DoAfterAABBDrawing(var ARci: TRenderContextInfo);
begin
  GetAABBMaterial.UnApply(ARci);
end;

procedure TGLDrawTechniqueOGL1.DoBeforeAABBDrawing(var ARci: TRenderContextInfo);
begin
  GetAABBMaterial.Apply(ARci);
end;

procedure TGLDrawTechniqueOGL1.DrawAABB(var ARci: TRenderContextInfo;
  const ABatch: TDrawBatch);
var
  LMesh: TFriendlyMesh;
  LPositions: array[0..7] of TVector3f;
begin
  with GL do
  begin
    LMesh := TFriendlyMesh(ABatch.Mesh);
    with LMesh.AABB do
    begin
      LPositions[2] := max;
      LPositions[4] := min;
    end;
    LPositions[0] := Vector3fMake(LPositions[4][0], LPositions[2][1], LPositions[4][2]);
    LPositions[1] := Vector3fMake(LPositions[4][0], LPositions[2][1], LPositions[2][2]);
    LPositions[3] := Vector3fMake(LPositions[2][0], LPositions[2][1], LPositions[4][2]);
    LPositions[5] := Vector3fMake(LPositions[4][0], LPositions[4][1], LPositions[2][2]);
    LPositions[6] := Vector3fMake(LPositions[2][0], LPositions[4][1], LPositions[2][2]);
    LPositions[7] := Vector3fMake(LPositions[2][0], LPositions[4][1], LPositions[4][2]);

    ARci.PipelineTransformation.Push(ABatch.Transformation);
    try
      EnableClientState(GL_VERTEX_ARRAY);
      VertexPointer(3, GL_FLOAT, 0, @LPositions[0]);
      DrawElements(GL_LINES, 24, GL_UNSIGNED_SHORT, @cAABBIndices);
      DisableClientState(GL_VERTEX_ARRAY);
    finally
      ARci.PipelineTransformation.Pop;
    end;
  end;
end;

procedure TGLDrawTechniqueOGL1.DrawBatch(
  var ARci: TRenderContextInfo; const ABatch: TDrawBatch);
var
  LMesh: TFriendlyMesh;
  LInstanceChain: TInstancesChain;
  LInstanceID: Integer;
  A: TAttribLocation;
  T: TGLEnum;
  glPrimitive: TGLEnum;
begin
  with GL do
  begin
    LMesh := TFriendlyMesh(ABatch.Mesh);
    LMesh.FDLO.AllocateHandle;
    if LMesh.FRevisionNum <> LMesh.FBufferRevision then
    begin
      LMesh.FDLO.NotifyChangesOfData;
      LMesh.FBufferRevision := LMesh.FRevisionNum;
    end;

    if Assigned(ABatch.InstancesChain) and ABatch.InstancesChain.IsValid then
    begin
      LInstanceChain := ABatch.InstancesChain;
      LInstanceID := LInstanceChain.InstanceCount;
    end
    else
    begin
      LInstanceChain := nil;
      LInstanceID := 1;
    end;

    // Upload geometry
    if LMesh.FDLO.IsDataNeedUpdate then
    begin
      LMesh.FDLO.NewList(GL_COMPILE);
      // Texture coordinates
      if ARB_multisample then
      begin
        T := 7;
        for A := attrTexCoord7 downto attrTexCoord0 do
        begin
          ClientActiveTexture(GL_TEXTURE0 + T);
          if LMesh.FAttributes[A] then
          begin
            EnableClientState(GL_TEXTURE_COORD_ARRAY);
            TexCoordPointer(
              GLSLTypeComponentCount(LMesh.FType[A]),
              GLSLTypeEnum(LMesh.FType[A]),
              0, LMesh.FAttributeArrays[A].List);
          end
          else
            DisableClientState(GL_TEXTURE_COORD_ARRAY);
          Dec(T);
        end;
      end
      else
      begin
        // Only one texture unit avaible
        if LMesh.FAttributes[attrTexCoord0] then
        begin
          EnableClientState(GL_TEXTURE_COORD_ARRAY);
          TexCoordPointer(
            GLSLTypeComponentCount(LMesh.FType[attrTexCoord0]),
            GLSLTypeEnum(LMesh.FType[attrTexCoord0]),
            0, LMesh.FAttributeArrays[attrTexCoord0].List);
        end
        else
          DisableClientState(GL_TEXTURE_COORD_ARRAY);
      end;
      // Colors
      if LMesh.FAttributes[attrColor] then
      begin
        EnableClientState(GL_COLOR_ARRAY);
        ColorPointer(
          GLSLTypeComponentCount(LMesh.FType[attrColor]),
          GLSLTypeEnum(LMesh.FType[attrColor]),
          0, LMesh.FAttributeArrays[attrColor].List);
      end
      else
        DisableClientState(GL_COLOR_ARRAY);
      // Normals
      if LMesh.FAttributes[attrNormal]
        and (GLSLTypeComponentCount(LMesh.FType[attrNormal]) = 3) then
      begin
        EnableClientState(GL_NORMAL_ARRAY);
        NormalPointer(
          GLSLTypeEnum(LMesh.FType[attrNormal]),
          0, LMesh.FAttributeArrays[attrNormal].List);
      end
      else
        DisableClientState(GL_NORMAL_ARRAY);
      // Positions
      if LMesh.FAttributes[attrPosition] then
      begin
        EnableClientState(GL_VERTEX_ARRAY);
        VertexPointer(
          GLSLTypeComponentCount(LMesh.FType[attrPosition]),
          GLSLTypeEnum(LMesh.FType[attrPosition]),
          0, LMesh.FAttributeArrays[attrPosition].List);
      end
      else
        DisableClientState(GL_VERTEX_ARRAY);
      // Draw
      glPrimitive := cPrimitiveType[LMesh.FPrimitive];
      if LMesh.FHasIndices then
      begin
        DrawElements(
          glPrimitive,
          LMesh.FElements.Count,
          GL_UNSIGNED_INT,
          LMesh.FElements.List);
      end
      else
      begin
        DrawArrays(glPrimitive, 0, LMesh.FVertexCount);
      end;

      LMesh.FDLO.EndList;
      LMesh.FDLO.NotifyDataUpdated;
    end;

    ARci.PipelineTransformation.Push(ABatch.Transformation);
    try
      if Assigned(ABatch.Material) then
        ABatch.Material.Apply(ARci);
      repeat

        repeat
          Dec(LInstanceID);
          if Assigned(LInstanceChain) then
            ApplyInstance(ARci, LInstanceChain, LInstanceID);

          LMesh.FDLO.CallList;

        until LInstanceID <= 0;

        if not Assigned(ABatch.Material) then
          break;
      until not ABatch.Material.UnApply(ARci);
    finally
      ARci.PipelineTransformation.Pop;
    end;

  end;
end;

{$IFDEF GLS_REGION}{$ENDREGION 'TGLDrawTechniqueFFP'}{$ENDIF}

{$IFDEF GLS_REGION}{$REGION 'TPoolMap'}{$ENDIF}

function TPoolMap.AddSector(const AItem: TPoolSector): Integer;
var
  Ptr: PPoolSector;
begin
  New(Ptr);
  Ptr^ := AItem;
  Result := Add(Ptr);
end;

procedure TPoolMap.Clear;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    if Get(I) <> nil then
      Dispose(PPoolSector(Get(I)));
  inherited;
end;

constructor TPoolMap.Create(AType: TPoolMapType);
begin
  inherited Create;
  FType := AType;
end;

procedure TPoolMap.DeleteSector(Index: Integer);
var
  Ptr: PPoolSector;
  I: Integer;
begin
  Ptr := Get(Index);
  if Assigned(Ptr) then
    Dispose(Ptr);
  Delete(Index);
  if FType = pmtArray then
  begin
    for I := Index to Count - 1 do
    begin
      Ptr := Get(I);
      if Assigned(Ptr) and Assigned(Ptr^.Mesh) then
        TFriendlyMesh(Ptr^.Mesh).FArraySectorIndex := I;
    end;
  end
  else
  begin
    for I := Index to Count - 1 do
    begin
      Ptr := Get(I);
      if Assigned(Ptr) and Assigned(Ptr^.Mesh) then
        TFriendlyMesh(Ptr^.Mesh).FElementSectorIndex := I;
    end;
  end;
end;

function TPoolMap.GetSector(Index: Integer): PPoolSector;
begin
  Result := Get(Index);
end;

procedure TPoolMap.InsertSector(Index: Integer; const AItem: TPoolSector);
var
  Ptr: PPoolSector;
  I: Integer;
begin
  New(Ptr);
  Ptr^ := AItem;
  Insert(Index, Ptr);
  if FType = pmtArray then
  begin
    for I := Index to Count - 1 do
    begin
      Ptr := Get(I);
      if Assigned(Ptr) and Assigned(Ptr^.Mesh) then
        TFriendlyMesh(Ptr^.Mesh).FArraySectorIndex := I;
    end;
  end
  else
  begin
    for I := Index to Count - 1 do
    begin
      Ptr := Get(I);
      if Assigned(Ptr) and Assigned(Ptr^.Mesh) then
        TFriendlyMesh(Ptr^.Mesh).FElementSectorIndex := I;
    end;
  end;
end;

procedure TPoolMap.PutSector(Index: Integer; Item: PPoolSector);
begin
  Put(Index, Item);
end;

{$IFDEF GLS_REGION}{$ENDREGION 'TPoolMap'}{$ENDIF}

{$IFDEF GLS_REGION}{$REGION 'TGLDrawTechniqueOGL2'}{$ENDIF}

// ------------------
// ------------------ TGLDrawTechniqueOGL2 ------------------
// ------------------

constructor TGLDrawTechniqueOGL2.Create;
begin
  if Self = nil then
    exit;
  if Assigned(Self.FArrayHandle) then
    exit;
  FArrayHandle := TGLVBOArrayBufferHandle.Create;
  FArrayBufferMap := TPoolMap.Create(pmtArray);
  FElementHandle := TGLVBOElementArrayHandle.Create;
  FElementBufferMap := TPoolMap.Create(pmtElement);
end;

destructor TGLDrawTechniqueOGL2.Destroy;
begin
  FArrayHandle.Destroy;
  FElementHandle.Destroy;
  FArrayBufferMap.Destroy;
  FElementBufferMap.Destroy;
end;

procedure TGLDrawTechniqueOGL2.DoAfterAABBDrawing(var ARci: TRenderContextInfo);
begin
  GetAABBMaterial.UnApply(ARci);
end;

procedure TGLDrawTechniqueOGL2.DoBeforeAABBDrawing(
  var ARci: TRenderContextInfo);
begin
  ARci.GLStates.ArrayBufferBinding := 0;
  ARci.GLStates.ElementBufferBinding := 0;
  GetAABBMaterial.Apply(ARci);
end;

procedure TGLDrawTechniqueOGL2.AllocateBuffers;
var
  VBOFreeMem: TVector4ui;
  VBOPool: Cardinal;
  ArraySector: TPoolSector;
  ElementSector: TPoolSector;
  BufferType: TGLEnum;
begin
  FArrayHandle.AllocateHandle;
  FElementHandle.AllocateHandle;
  if FArrayHandle.IsDataNeedUpdate or FElementHandle.IsDataNeedUpdate then
    with GL do
    begin
      if (FArrayBufferMap.Count > 0) or (FElementBufferMap.Count > 0) then
      begin
        GLSLogger.LogDebug('Reset static buffers pool');
        FArrayBufferMap.Clear;
        FElementBufferMap.Clear;
      end;

      ArraySector.Offset := 0;
      ArraySector.Size := 0;
      ArraySector.Mesh := nil;
      ElementSector.Offset := 0;
      ElementSector.Size := 0;
      ElementSector.Mesh := nil;

      if IsDesignTime then
      begin
        VBOPool := VBO_STATIC_POOL_SIZE;
      end
      else if ATI_meminfo then
      begin
        GetIntegerv(GL_VBO_FREE_MEMORY_ATI, @VBOFreeMem[0]);
        GLSLogger.LogInfo(Format('Free graphic memory avaible - %dM',
          [VBOFreeMem[1] div 1024]));
        VBOPool := VBOFreeMem[1] * 1024 div 4;
        VBOPool := MinInteger(VBOPool, 8 * VBO_STATIC_POOL_SIZE);
      end
      else if NVX_gpu_memory_info then
      begin
        GetIntegerv(GL_GPU_MEMORY_INFO_TOTAL_AVAILABLE_MEMORY_NVX,
          @VBOFreeMem[1]);
        GLSLogger.LogInfo(Format('Free graphic memory avaible - %dM',
          [VBOFreeMem[1] div 1024]));
        VBOPool := VBOFreeMem[1] * 1024 div 4;
        VBOPool := MinInteger(VBOPool, 8 * VBO_STATIC_POOL_SIZE);
      end
      else
      begin
        VBOPool := VBO_STATIC_POOL_SIZE;
        GLSLogger.LogInfo(
          'Can''t get info about graphic memory. Allocate pool size of 16M');
      end;
      ArraySector.Size := 3 * VBOPool div 4;
      ElementSector.Size := VBOPool - ArraySector.Size;

      if IsDesignTime then
        BufferType := GL_DYNAMIC_DRAW
      else
        BufferType := GL_STATIC_DRAW;

      ArraySector.Size := ArraySector.Size * 2;
      ElementSector.Size := ElementSector.Size * 2;
      repeat
        GL.ClearError;
        ArraySector.Size := ArraySector.Size div 2;
        ElementSector.Size := ElementSector.Size div 2;
        FArrayHandle.BindBufferData(nil, ArraySector.Size, BufferType);
        FElementHandle.BindBufferData(nil, ElementSector.Size, BufferType);
        Finish;
      until GL.GetError = GL_NO_ERROR;

      FArrayHandle.NotifyDataUpdated;
      FElementHandle.NotifyDataUpdated;

      FArrayBufferMap.AddSector(ArraySector);
      FElementBufferMap.AddSector(ElementSector);

      GLSLogger.LogInfo(Format('Allocated static vertex buffer pool - %dM',
        [ArraySector.Size div $100000]));
      GLSLogger.LogInfo(Format('Allocated static element buffer pool - %dM',
        [ElementSector.Size div $100000]));
    end;
end;

procedure TGLDrawTechniqueOGL2.PlacedInBuffer(AMesh: TMeshAtom);
var
  A: TAttribLocation;
  I, J: Integer;
  LDataSize: array[TAttribLocation] of Cardinal;
  RequestSize, Size, Offset, maxIndexValue, ElementsSize: Cardinal;
  ElementBufferSource: Pointer;
  LMesh: TFriendlyMesh;
  ArraySector: TPoolSector;
  ElementSector: TPoolSector;
  pSector: PPoolSector;
  BD: T4ByteData;
begin
  LMesh := TFriendlyMesh(AMesh);
  // Calculate size of array
  RequestSize := 0;
  for a := High(TAttribLocation) downto Low(TAttribLocation) do
    if LMesh.FAttributes[a] then
    begin
      LDataSize[a] := LMesh.FAttributeArrays[a].Count * SizeOf(T4ByteData);
      Inc(RequestSize, LDataSize[a]);
    end
    else
      LDataSize[a] := 0;

  // Check for empty mesh
  if RequestSize = 0 then
  begin
    LMesh.FValid := False;
    exit;
  end;

  if IsDesignTime then
  begin
    if Cardinal(FArrayHandle.BufferSize) < RequestSize then
    begin
      LMesh.FValid := False;
      exit;
    end;
    Offset := 0;
  end
  else
  begin
    // choose place in pool to upload data
    J := LMesh.FArraySectorIndex;
    if J > -1 then
    begin
      // Sector overflow
      pSector := FArrayBufferMap.Sectors[J];
      if pSector.Size < RequestSize then
      begin
        // Lool into next sector, it may be free
        Size := pSector^.Size;
        I := J + 1;
        while (I < FArrayBufferMap.Count) do
        begin
          if FArrayBufferMap.Sectors[I].Mesh = nil then
            Size := Size + FArrayBufferMap.Sectors[I].Size
          else
            break;
          if Size >= RequestSize then
            break;
          Inc(I);
        end;

        if Size >= RequestSize then
        begin
          // Merge sectors
          pSector := FArrayBufferMap.Sectors[J];
          pSector.Size := Size;
          for I := J + 1 to I do
            FArrayBufferMap.DeleteSector(J + 1);
        end
        else
        begin
          // Free sector
          pSector := FArrayBufferMap.Sectors[J];
          pSector.Mesh := nil;
          LMesh.FArraySectorIndex := -1;
          J := -1;
        end;
      end;
    end;

    if J < 0 then
    begin
      // Find free sector
      Size := FArrayHandle.BufferSize;
      for I := 0 to FArrayBufferMap.Count - 1 do
        if (FArrayBufferMap.Sectors[I].Mesh = nil) and
          (FArrayBufferMap.Sectors[I].Size >= RequestSize) and
          (FArrayBufferMap.Sectors[I].Size <= Size) then
        begin
          J := I;
          Size := FArrayBufferMap.Sectors[I].Size;
        end;

      // Check overflow
      if J < 0 then
      begin
        // TODO: defragmentation
        GLSLogger.LogError('Static vertex array pool is full');
        LMesh.FValid := False;
        Abort;
      end;

      // Extract the residue
      if (FArrayBufferMap.Sectors[J].Size - RequestSize) > 0 then
      begin
        ArraySector.Offset := FArrayBufferMap.Sectors[J].Offset + RequestSize;
        ArraySector.Size := FArrayBufferMap.Sectors[J].Size - RequestSize;
        ArraySector.Mesh := nil;
        if J < FArrayBufferMap.Count - 1 then
          FArrayBufferMap.InsertSector(J, ArraySector)
        else
          FArrayBufferMap.AddSector(ArraySector);
      end;

      // Set new parameters
      LMesh.FArraySectorIndex := J;
      pSector := FArrayBufferMap.Sectors[J];
      pSector.Size := RequestSize;
      pSector.Mesh := LMesh;
    end;

    Offset := FArrayBufferMap.Sectors[J].Offset;
  end;

  // upload each attribute array one after another
  FArrayHandle.Bind;

  for A := Low(TAttribLocation) to High(TAttribLocation) do
    if LMesh.FAttributes[a] then
    begin
      FArrayHandle.BufferSubData(Offset, LDataSize[a],
        LMesh.FAttributeArrays[a].List);
      Inc(Offset, LDataSize[a]);
    end;

  if LMesh.FHasIndices then
  begin
    LMesh.Lock;
    try
      if LMesh.FTrianglesElements.Revision <> LMesh.FElements.Revision then
        LMesh.MakeTriangleElements;
      //      if LMesh.FAdjacencyElements.Revision <> LMesh.FElements.Revision then
      //        LMesh.MakeAdjacencyElements;
    finally
      LMesh.UnLock;
    end;
    maxIndexValue := LMesh.FAttributeArrays[attrPosition].Count div
      GLSLTypeComponentCount(LMesh.FType[attrPosition]);
    // Adjust index type according it's number
    if (maxIndexValue + 1 < $10000)
      and not IsDesignTime then
    begin
      LMesh.FRestartIndex := $FFFF;
      ElementsSize := LMesh.FElements.Count * SizeOf(TGLushort);
      RoundTo(ElementsSize, 4);
      GetMem(ElementBufferSource, ElementsSize);
      for I := LMesh.FElements.Count - 1 downto 0 do
      begin
        BD := LMesh.FElements[I];
        PWordVector(ElementBufferSource)[I] := BD.Word.Value[0];
      end;
    end
    else
    begin
      LMesh.FRestartIndex := $FFFFFFFF;
      ElementsSize := LMesh.FElements.Count * SizeOf(TGLuint);
      ElementBufferSource := nil;
    end;
    RequestSize := ElementsSize;
    Inc(RequestSize, LMesh.FTrianglesElements.Count * SizeOf(TGLuint));
    Inc(RequestSize, LMesh.FAdjacencyElements.Count * SizeOf(TGLuint));

    if IsDesignTime then
    begin
      if Cardinal(FElementHandle.BufferSize) < RequestSize then
      begin
        LMesh.FValid := False;
        exit;
      end;
      Offset := 0;
    end
    else
    begin
      // choose place in pool to upload data
      J := LMesh.FElementSectorIndex;
      if J > -1 then
      begin
        // Sector overflow
        if FElementBufferMap.Sectors[J].Size < RequestSize then
        begin
          // Look into next sector, it may be free
          Size := FElementBufferMap.Sectors[J].Size;
          I := J + 1;
          while (I < FElementBufferMap.Count) do
          begin
            if FElementBufferMap.Sectors[I].Mesh = nil then
              Size := Size + FElementBufferMap.Sectors[I].Size
            else
              break;
            if Size >= RequestSize then
              break;
            Inc(I);
          end;

          if Size >= RequestSize then
          begin
            // Merge sectors
            pSector := FElementBufferMap.Sectors[J];
            pSector.Size := Size;
            for I := J + 1 to I do
              FElementBufferMap.Delete(J + 1);
          end
          else
          begin
            // Free sector
            pSector := FElementBufferMap.Sectors[J];
            pSector.Mesh := nil;
            LMesh.FElementSectorIndex := -1;
            J := -1;
          end;
        end;
      end;

      if J < 0 then
      begin
        // Find free sector
        Size := FElementHandle.BufferSize;
        for I := 0 to FElementBufferMap.Count - 1 do
          if (FElementBufferMap.Sectors[I].Mesh = nil) and
            (FElementBufferMap.Sectors[I].Size >= RequestSize) and
            (FElementBufferMap.Sectors[I].Size <= Size) then
          begin
            J := I;
            Size := FElementBufferMap.Sectors[I].Size;
          end;

        // Check overflow
        if J < 0 then
        begin
          // TODO: defragmentation
          GLSLogger.LogError('Static vertex array pool is full');
          Abort;
        end;

        // Extract the residue
        if (FElementBufferMap.Sectors[J].Size - RequestSize) > 0 then
        begin
          ElementSector.Offset := FElementBufferMap.Sectors[J].Offset + RequestSize;
          ElementSector.Size := FElementBufferMap.Sectors[J].Size - RequestSize;
          ElementSector.Mesh := nil;
          if J < FElementBufferMap.Count - 1 then
            FElementBufferMap.InsertSector(J, ElementSector)
          else
            FElementBufferMap.AddSector(ElementSector);
        end;

        // Set new parameters
        LMesh.FElementSectorIndex := J;
        pSector := FElementBufferMap.Sectors[J];
        pSector.Size := RequestSize;
        pSector.Mesh := LMesh;
      end;

      Offset := FElementBufferMap.Sectors[J].Offset;
    end;

    // upload element array
    FElementHandle.Bind;
    if Assigned(ElementBufferSource) then
    begin
      FElementHandle.BufferSubData(Offset, ElementsSize,
        ElementBufferSource);
      FreeMem(ElementBufferSource);
    end
    else
    begin
      FElementHandle.BufferSubData(Offset, ElementsSize,
        LMesh.FElements.List);
    end;

    if LMesh.FTrianglesElements.Count > 0 then
    begin
      // Pure triangle elements
      Inc(Offset, ElementsSize);
      FElementHandle.BufferSubData(Offset, LMesh.FTrianglesElements.DataSize,
        LMesh.FTrianglesElements.List);
      if LMesh.FAdjacencyElements.Count > 0 then
      begin
        // Adjacency elements
        Inc(Offset, LMesh.FTrianglesElements.DataSize);
        FElementHandle.BufferSubData(Offset, LMesh.FAdjacencyElements.DataSize,
          LMesh.FAdjacencyElements.List);
      end;
    end;
  end;
end;

procedure TGLDrawTechniqueOGL2.ApplyInstance(var ARci: TRenderContextInfo; const AInstance: TInstancesChain; const AID: Integer);
var
  LProgram: TGLint;
  A: TAttribLocation;
  T: TGLEnum;
  LLink: TFriendlyInstancesChain;
  I: Integer;
  L: TGLuint;
begin
  LLink := TFriendlyInstancesChain(AInstance);

  with GL do
  begin
    LProgram := ARci.GLStates.CurrentProgram;

    if LProgram > 0 then
    begin
      // Setup generic attributes
      for A := High(TAttribLocation) downto Low(TAttribLocation) do
      begin
        L := Ord(A);
        if LLink.FAttributes[A] then
        begin
          DisableVertexAttribArray(L);
          I := AID;
          if LLink.FAttributeDivisor[A] > 1 then
            I := I div LLink.FAttributeDivisor[A];
          case LLink.FType[A] of
            GLSLType1F:
              VertexAttrib1fv(L, @LLink.FAttributeArrays[A].List[I]);
            GLSLType2F:
              VertexAttrib2fv(L, @LLink.FAttributeArrays[A].List[2*I]);
            GLSLType3F:
              VertexAttrib3fv(L, @LLink.FAttributeArrays[A].List[3*I]);
            GLSLType4F:
              VertexAttrib4fv(L, @LLink.FAttributeArrays[A].List[4*I]);
            GLSLTypeMat2F:
              begin
                VertexAttrib2fv(L, @LLink.FAttributeArrays[A].List[4*I]);
                VertexAttrib2fv(L+1, @LLink.FAttributeArrays[A].List[4*I+2]);
              end;
            GLSLTypeMat3F:
              begin
                VertexAttrib3fv(L, @LLink.FAttributeArrays[A].List[9*I]);
                VertexAttrib3fv(L+1, @LLink.FAttributeArrays[A].List[9*I+3]);
                VertexAttrib3fv(L+2, @LLink.FAttributeArrays[A].List[9*I+6]);
              end;
            GLSLTypeMat4F:
              begin
                VertexAttrib4fv(L, @LLink.FAttributeArrays[A].List[16*I]);
                VertexAttrib4fv(L+1, @LLink.FAttributeArrays[A].List[16*I+4]);
                VertexAttrib4fv(L+2, @LLink.FAttributeArrays[A].List[16*I+8]);
                VertexAttrib4fv(L+3, @LLink.FAttributeArrays[A].List[16*I+12]);
              end;
            GLSLType1I:
              VertexAttribI1iv(L, @LLink.FAttributeArrays[A].List[I]);
            GLSLType2I:
              VertexAttribI2iv(L, @LLink.FAttributeArrays[A].List[2*I]);
            GLSLType3I:
              VertexAttribI3iv(L, @LLink.FAttributeArrays[A].List[3*I]);
            GLSLType4I:
              VertexAttribI4iv(L, @LLink.FAttributeArrays[A].List[4*I]);
            GLSLType1UI:
              VertexAttribI1uiv(L, @LLink.FAttributeArrays[A].List[I]);
            GLSLType2UI:
              VertexAttribI2uiv(L, @LLink.FAttributeArrays[A].List[2*I]);
            GLSLType3UI:
              VertexAttribI3uiv(L, @LLink.FAttributeArrays[A].List[3*I]);
            GLSLType4UI:
              VertexAttribI4uiv(L, @LLink.FAttributeArrays[A].List[4*I]);
          else
            Assert(false, glsErrorEx + glsUnknownType);
          end;
        end;
      end;
    end
    else
    begin
      // Texture coordinates
      T := 8;
      for A := attrTexCoord7 downto attrTexCoord0 do
      begin
        Dec(T);
        if LLink.FAttributes[A] then
        begin
          ClientActiveTexture(GL_TEXTURE0 + T);
          DisableClientState(GL_TEXTURE_COORD_ARRAY);
          I := AID;
          if LLink.FAttributeDivisor[A] > 1 then
            I := I div LLink.FAttributeDivisor[A];
          case LLink.FType[A] of
            GLSLType1F: MultiTexCoord1f(GL_TEXTURE0 + T, PSingle(@LLink.FAttributeArrays[A].List[I])^);
            GLSLType2F: MultiTexCoord2fv(GL_TEXTURE0 + T, @LLink.FAttributeArrays[A].List[2 * I]);
            GLSLType3F: MultiTexCoord3fv(GL_TEXTURE0 + T, @LLink.FAttributeArrays[A].List[3 * I]);
            GLSLType4F: MultiTexCoord4fv(GL_TEXTURE0 + T, @LLink.FAttributeArrays[A].List[4 * I]);
            GLSLType1I: MultiTexCoord1i(GL_TEXTURE0 + T, PInteger(@LLink.FAttributeArrays[A].List[I])^);
            GLSLType2I: MultiTexCoord2iv(GL_TEXTURE0 + T, @LLink.FAttributeArrays[A].List[2 * I]);
            GLSLType3I: MultiTexCoord3iv(GL_TEXTURE0 + T, @LLink.FAttributeArrays[A].List[3 * I]);
            GLSLType4I: MultiTexCoord4iv(GL_TEXTURE0 + T, @LLink.FAttributeArrays[A].List[4 * I]);
          end;
        end
        else if LLink.FAttributes[attrTexCoord0] then
        begin
          // Make first texture coordinates same for other, need for multitexturing
          // No sure is this usable for anyone
          ClientActiveTexture(GL_TEXTURE0 + T);
          DisableClientState(GL_TEXTURE_COORD_ARRAY);
          I := AID;
          if LLink.FAttributeDivisor[attrTexCoord0] > 1 then
            I := I div LLink.FAttributeDivisor[attrTexCoord0];
          case LLink.FType[A] of
            GLSLType1F: MultiTexCoord1f(GL_TEXTURE0 + T, PSingle(@LLink.FAttributeArrays[attrTexCoord0].List[I])^);
            GLSLType2F: MultiTexCoord2fv(GL_TEXTURE0 + T, @LLink.FAttributeArrays[attrTexCoord0].List[2 * I]);
            GLSLType3F: MultiTexCoord3fv(GL_TEXTURE0 + T, @LLink.FAttributeArrays[attrTexCoord0].List[3 * I]);
            GLSLType4F: MultiTexCoord4fv(GL_TEXTURE0 + T, @LLink.FAttributeArrays[attrTexCoord0].List[4 * I]);
            GLSLType1I: MultiTexCoord1i(GL_TEXTURE0 + T, PInteger(@LLink.FAttributeArrays[attrTexCoord0].List[I])^);
            GLSLType2I: MultiTexCoord2iv(GL_TEXTURE0 + T, @LLink.FAttributeArrays[attrTexCoord0].List[2 * I]);
            GLSLType3I: MultiTexCoord3iv(GL_TEXTURE0 + T, @LLink.FAttributeArrays[attrTexCoord0].List[3 * I]);
            GLSLType4I: MultiTexCoord4iv(GL_TEXTURE0 + T, @LLink.FAttributeArrays[attrTexCoord0].List[4 * I]);
          end;
        end;
      end;
      // Colors
      if LLink.FAttributes[attrColor] then
      begin
        DisableClientState(GL_COLOR_ARRAY);
        I := AID;
        if LLink.FAttributeDivisor[attrColor] > 1 then
          I := I div LLink.FAttributeDivisor[attrColor];
        case LLink.FType[attrColor] of
          GLSLType3F: Color3fv(@LLink.FAttributeArrays[attrColor].List[3 * I]);
          GLSLType4F: Color4fv(@LLink.FAttributeArrays[attrColor].List[4 * I]);
          GLSLType3I: Color3iv(@LLink.FAttributeArrays[attrColor].List[3 * I]);
          GLSLType4I: Color4iv(@LLink.FAttributeArrays[attrColor].List[4 * I]);
        end;
      end;
      // Normals
      if LLink.FAttributes[attrNormal] then
      begin
        DisableClientState(GL_NORMAL_ARRAY);
        I := AID;
        if LLink.FAttributeDivisor[attrNormal] > 1 then
          I := I div LLink.FAttributeDivisor[attrNormal];
        case LLink.FType[attrColor] of
          GLSLType3F: Normal3fv(@LLink.FAttributeArrays[attrNormal].List[3 * I]);
          GLSLType3I: Normal3iv(@LLink.FAttributeArrays[attrNormal].List[3 * I]);
        end;
      end;
      // Positions
      if LLink.FAttributes[attrPosition] then
      begin
        DisableClientState(GL_VERTEX_ARRAY);
        I := AID;
        if LLink.FAttributeDivisor[attrPosition] > 1 then
          I := I div LLink.FAttributeDivisor[attrPosition];
        case LLink.FType[attrPosition] of
          GLSLType2F: Vertex2fv(@LLink.FAttributeArrays[attrPosition].List[2 * I]);
          GLSLType3F: Vertex3fv(@LLink.FAttributeArrays[attrPosition].List[3 * I]);
          GLSLType4F: Vertex4fv(@LLink.FAttributeArrays[attrPosition].List[4 * I]);
          GLSLType2I: Vertex2iv(@LLink.FAttributeArrays[attrPosition].List[2 * I]);
          GLSLType3I: Vertex3iv(@LLink.FAttributeArrays[attrPosition].List[3 * I]);
          GLSLType4I: Vertex4iv(@LLink.FAttributeArrays[attrPosition].List[4 * I]);
        end;
      end;
    end;
  end;

  if LLink.FTransformationEnabled then
    ARci.PipelineTransformation.StackTop := PTransformationRec(LLink.FTransformations[AID])^;
end;

function TGLDrawTechniqueOGL2.BindStateHandle(const AStates: TGLStateCache;
  const AMesh: TMeshAtom): Boolean;
var
  LMesh: TFriendlyMesh;
  LProgram: TGLuint;
  LVAO: TGLVertexArrayHandle;

  A: TAttribLocation;
  L, T: TGLUint;
  Offsets: array[TAttribLocation] of Pointer;
  Offset: PtrUInt;
begin
  Result := False;
  LMesh := TFriendlyMesh(AMesh);
  LProgram := CurrentGLContext.GLStates.CurrentProgram;

  if LProgram > 0 then
    LVAO := LMesh.FVAO_Generic
  else if AStates.ForwardContext then
    exit
  else
    LVAO := LMesh.FVAO_BuildIn;

  if LVAO.IsSupported then
    LVAO.AllocateHandle;
  if LVAO.IsDataNeedUpdate then
    with GL do
    begin
      // Uniting all states and buffers in one vertex array object
      LVAO.Bind;

      // Need to direct bind array buffer for correctly VertexAttribPointer set up
      if AStates.ArrayBufferBinding = FArrayHandle.Handle then
        GL.BindBuffer(GL_ARRAY_BUFFER, AStates.ArrayBufferBinding)
      else
        FArrayHandle.Bind;
      FElementHandle.Bind;

      if IsDesignTime then
        Offset := 0
      else
        Offset := FArrayBufferMap.Sectors[LMesh.FArraySectorIndex].Offset;
      for A := Low(TAttribLocation) to High(TAttribLocation) do
      begin
        Offsets[A] := Pointer(Offset);
        if LMesh.FAttributes[A] then
          Inc(Offset, LMesh.FAttributeArrays[A].Count * SizeOf(T4ByteData));
      end;

      if LProgram > 0 then
      begin
        // Setup attribute arrays pointer
        for A := High(TAttribLocation) downto Low(TAttribLocation) do
        begin
          L := Ord(A);
          if LMesh.FAttributes[A] then
          begin
            EnableVertexAttribArray(L);
            case LMesh.FType[A] of
              GLSLType1F:
                VertexAttribPointer(L, 1, GL_FLOAT, false, 0, Offsets[A]);
              GLSLType2F:
                VertexAttribPointer(L, 2, GL_FLOAT, false, 0, Offsets[A]);
              GLSLType3F:
                VertexAttribPointer(L, 3, GL_FLOAT, false, 0, Offsets[A]);
              GLSLType4F:
                VertexAttribPointer(L, 4, GL_FLOAT, false, 0, Offsets[A]);
              GLSLTypeMat2F:
                VertexAttribPointer(L, 4, GL_FLOAT, false, 0, Offsets[A]);
              GLSLTypeMat3F:
                VertexAttribPointer(L, 9, GL_FLOAT, false, 0, Offsets[A]);
              GLSLTypeMat4F:
                VertexAttribPointer(L, 16, GL_FLOAT, false, 0, Offsets[A]);
              GLSLType1I:
                VertexAttribIPointer(L, 1, GL_INT, 0, Offsets[A]);
              GLSLType2I:
                VertexAttribIPointer(L, 2, GL_INT, 0, Offsets[A]);
              GLSLType3I:
                VertexAttribIPointer(L, 3, GL_INT, 0, Offsets[A]);
              GLSLType4I:
                VertexAttribIPointer(L, 4, GL_UNSIGNED_INT, 0, Offsets[A]);
              GLSLType1UI:
                VertexAttribIPointer(L, 1, GL_UNSIGNED_INT, 0, Offsets[A]);
              GLSLType2UI:
                VertexAttribIPointer(L, 2, GL_UNSIGNED_INT, 0, Offsets[A]);
              GLSLType3UI:
                VertexAttribIPointer(L, 3, GL_UNSIGNED_INT, 0, Offsets[A]);
              GLSLType4UI:
                VertexAttribIPointer(L, 4, GL_UNSIGNED_INT, 0, Offsets[A]);
            else
              Assert(false, glsErrorEx + glsUnknownType);
            end;
          end
          else
            DisableVertexAttribArray(L);
        end;
      end // of Generic attributes
      else
        // Build-in attributes
      begin
        T := 8;
        for A := attrTexCoord7 downto attrTexCoord0 do
        begin
          Dec(T);
          ClientActiveTexture(GL_TEXTURE0 + T);
          if LMesh.FAttributes[A] then
          begin
            EnableClientState(GL_TEXTURE_COORD_ARRAY);
            TexCoordPointer(
              GLSLTypeComponentCount(LMesh.FType[A]),
              GLSLTypeEnum(LMesh.FType[A]),
              0, Offsets[A]);
          end
          else if LMesh.FAttributes[attrTexCoord0] then
          begin
            // Make first texture coordinates same for other, need for multitexturing
            EnableClientState(GL_TEXTURE_COORD_ARRAY);
            TexCoordPointer(
              GLSLTypeComponentCount(LMesh.FType[attrTexCoord0]),
              GLSLTypeEnum(LMesh.FType[attrTexCoord0]),
              0, Offsets[attrTexCoord0]);
          end
          else
            DisableClientState(GL_TEXTURE_COORD_ARRAY);
        end;
        // Colors
        if LMesh.FAttributes[attrColor] then
        begin
          EnableClientState(GL_COLOR_ARRAY);
          ColorPointer(
            GLSLTypeComponentCount(LMesh.FType[attrColor]),
            GLSLTypeEnum(LMesh.FType[attrColor]),
            0, Offsets[attrColor]);
        end
        else
          DisableClientState(GL_COLOR_ARRAY);
        // Normals
        if LMesh.FAttributes[attrNormal]
          and (GLSLTypeComponentCount(LMesh.FType[attrNormal]) = 3) then
        begin
          EnableClientState(GL_NORMAL_ARRAY);
          NormalPointer(
            GLSLTypeEnum(LMesh.FType[attrNormal]),
            0, Offsets[attrNormal]);
        end
        else
          DisableClientState(GL_NORMAL_ARRAY);
        // Positions
        if LMesh.FAttributes[attrPosition] then
        begin
          EnableClientState(GL_VERTEX_ARRAY);
          VertexPointer(
            GLSLTypeComponentCount(LMesh.FType[attrPosition]),
            GLSLTypeEnum(LMesh.FType[attrPosition]),
            0, Offsets[attrPosition]);
        end
        else
          DisableClientState(GL_VERTEX_ARRAY);
      end;

      LVAO.NotifyDataUpdated;
    end
  else
    LVAO.Bind;

  with AStates do
  begin
    EnablePrimitiveRestart := LMesh.FHasIndices;
    PrimitiveRestartIndex := LMesh.FRestartIndex;
  end;

  Result := True;
end;

procedure TGLDrawTechniqueOGL2.DrawAABB(var ARci: TRenderContextInfo;
  const ABatch: TDrawBatch);
var
  LMesh: TFriendlyMesh;
  LPositions: array[0..7] of TVector3f;
begin
  with GL do
  begin
    LMesh := TFriendlyMesh(ABatch.Mesh);
    with LMesh.AABB do
    begin
      LPositions[2] := max;
      LPositions[4] := min;
    end;
    LPositions[0] := Vector3fMake(LPositions[4][0], LPositions[2][1], LPositions[4][2]);
    LPositions[1] := Vector3fMake(LPositions[4][0], LPositions[2][1], LPositions[2][2]);
    LPositions[3] := Vector3fMake(LPositions[2][0], LPositions[2][1], LPositions[4][2]);
    LPositions[5] := Vector3fMake(LPositions[4][0], LPositions[4][1], LPositions[2][2]);
    LPositions[6] := Vector3fMake(LPositions[2][0], LPositions[4][1], LPositions[2][2]);
    LPositions[7] := Vector3fMake(LPositions[2][0], LPositions[4][1], LPositions[4][2]);

    ARci.PipelineTransformation.Push(ABatch.Transformation);
    try
      if ARci.GLStates.CurrentProgram = 0 then
      begin
        EnableClientState(GL_VERTEX_ARRAY);
        VertexPointer(3, GL_FLOAT, 0, @LPositions[0]);
        DrawElements(GL_LINES, 24, GL_UNSIGNED_SHORT, @cAABBIndices[0]);
        DisableClientState(GL_VERTEX_ARRAY);
      end
      else
      begin
        EnableVertexAttribArray(Ord(attrPosition));
        VertexAttribPointer(Ord(attrPosition), 3, GL_FLOAT, false, 0, @LPositions[0]);
        DrawElements(GL_LINES, 24, GL_UNSIGNED_SHORT, @cAABBIndices[0]);
        DisableVertexAttribArray(Ord(attrPosition));
      end;
    finally
      ARci.PipelineTransformation.Pop;
    end;
  end;
end;

procedure TGLDrawTechniqueOGL2.DrawBatch(
  var ARci: TRenderContextInfo; const ABatch: TDrawBatch);
var
  LMesh: TFriendlyMesh;
  LInstanceChain: TInstancesChain;
  LInstanceID: Integer;
  glPrimitive: TGLEnum;
  glType: TGLEnum;
  LOffset: Pointer;
begin
  AllocateBuffers;

  LMesh := TFriendlyMesh(ABatch.Mesh);
  if LMesh.FRevisionNum <> LMesh.FBufferRevision then
  begin
    PlacedInBuffer(LMesh);
    LMesh.FBufferRevision := LMesh.FRevisionNum;
  end;

  LMesh := TFriendlyMesh(ABatch.Mesh);
  if LMesh.FRevisionNum <> LMesh.FBufferRevision then
  begin
    PlacedInBuffer(LMesh);
    LMesh.FBufferRevision := LMesh.FRevisionNum;
  end;

  if Assigned(ABatch.InstancesChain) and ABatch.InstancesChain.IsValid then
  begin
    LInstanceChain := ABatch.InstancesChain;
    LInstanceID := LInstanceChain.InstanceCount;
  end
  else
  begin
    LInstanceChain := nil;
    LInstanceID := 1;
  end;

  ARci.PipelineTransformation.Push(ABatch.Transformation);
  with GL do
    try
      glPrimitive := cPrimitiveType[LMesh.FPrimitive];
      if LMesh.FRestartIndex > $FFFF then
        glType := GL_UNSIGNED_INT
      else
        glType := GL_UNSIGNED_SHORT;

      if IsDesignTime or not LMesh.FHasIndices then
        LOffset := nil
      else
        LOffset := Pointer(FElementBufferMap.Sectors[LMesh.FElementSectorIndex].Offset);

      if Assigned(ABatch.Material) then
        ABatch.Material.Apply(ARci);

      if BindStateHandle(ARci.GLStates, LMesh) then
        repeat

          repeat
            Dec(LInstanceID);
            if Assigned(LInstanceChain) then
              ApplyInstance(ARci, LInstanceChain, LInstanceID);

            if LMesh.FHasIndices then
              DrawElements(
                glPrimitive,
                LMesh.FElements.Count,
                glType,
                LOffset)
            else
              DrawArrays(glPrimitive, 0, LMesh.FVertexCount);
          until LInstanceID <= 0;

          if not Assigned(ABatch.Material) then
            break;
        until not ABatch.Material.UnApply(ARci);
    finally
      ARci.PipelineTransformation.Pop;
      ARci.GLStates.VertexArrayBinding := 0;
    end;
end;

{$IFDEF GLS_REGION}{$ENDREGION 'TGLDrawTechniqueOGL2'}{$ENDIF}

{$IFDEF GLS_REGION}{$REGION 'TGLDrawTechniqueOGL3'}{$ENDIF}

constructor TGLDrawTechniqueOGL3.Create;
begin
  inherited;
  FCommonVAO := TGLVertexArrayHandle.Create;
end;

destructor TGLDrawTechniqueOGL3.Destroy;
begin
  FCommonVAO.Destroy;
  inherited;
end;

procedure TGLDrawTechniqueOGL3.DoAfterAABBDrawing(var ARci: TRenderContextInfo);
begin
  GetAABBMaterial.UnApply(ARci);
  if ARci.GLStates.ForwardContext then
    FCommonVAO.UnBind;
end;

procedure TGLDrawTechniqueOGL3.DoBeforeAABBDrawing(
  var ARci: TRenderContextInfo);
begin
  if ARci.GLStates.ForwardContext then
  begin
    FCommonVAO.AllocateHandle;
    FCommonVAO.Bind;
  end;
  ARci.GLStates.ArrayBufferBinding := 0;
  ARci.GLStates.ElementBufferBinding := 0;
  GetAABBMaterial.Apply(ARci);
end;

procedure TGLDrawTechniqueOGL3.DrawBatch(
  var ARci: TRenderContextInfo; const ABatch: TDrawBatch);
var
  LMesh: TFriendlyMesh;
  LInstanceChain: TInstancesChain;
  glPrimitive: TGLEnum;
  glType: TGLEnum;
  LShift: PtrUInt;
  LOffset: Pointer;
  LCount, LInstanceID: Integer;
  storeRci: TRenderContextInfo;
begin
  AllocateBuffers;

  LMesh := TFriendlyMesh(ABatch.Mesh);
  if LMesh.FRevisionNum <> LMesh.FBufferRevision then
  begin
    PlacedInBuffer(LMesh);
    LMesh.FBufferRevision := LMesh.FRevisionNum;
  end;

  if Assigned(ABatch.InstancesChain) and ABatch.InstancesChain.IsValid then
  begin
    LInstanceChain := ABatch.InstancesChain;
    LInstanceID := LInstanceChain.InstanceCount;
  end
  else
  begin
    LInstanceChain := nil;
    LInstanceID := 1;
  end;

  ARci.PipelineTransformation.Push(ABatch.Transformation);
  with GL do
    try
      storeRci := ARci;
      if Assigned(ABatch.Material) then
        ABatch.Material.Apply(ARci);

      if BindStateHandle(ARci.GLStates, LMesh) then
      begin
        if LMesh.FRestartIndex > $FFFF then
          glType := GL_UNSIGNED_INT
        else
          glType := GL_UNSIGNED_SHORT;
        LShift := 0;
        LCount := LMesh.FElements.Count;

        repeat
          // Primitive selection
          glPrimitive := cPrimitiveType[LMesh.FPrimitive];
          if (ARci.primitiveMask = cAdjacencyPrimitives)
            and not (LMesh.FPrimitive in cAdjacencyPrimitives) then
          begin
            glPrimitive := GL_TRIANGLES_ADJACENCY;
            if LMesh.FHasIndices and (LMesh.FAdjacencyElements.Count > 0) then
            begin
              LShift := LCount;
              LCount := LMesh.FAdjacencyElements.Count;
              if glType = GL_UNSIGNED_SHORT then
              begin
                LShift := LShift * SizeOf(TGLushort);
                RoundTo(LShift, 4);
                glType := GL_UNSIGNED_INT;
              end
              else
                LShift := LShift * SizeOf(TGLuint);
              LShift := LShift + Cardinal(LMesh.FTrianglesElements.Count * SizeOf(TGLuint));
            end
            else
              continue;
          end
          else if not (LMesh.FPrimitive in ARci.primitiveMask) then
            continue;

          if IsDesignTime or not LMesh.FHasIndices then
            LOffset := Pointer(LShift)
          else
            LOffset := Pointer(LShift + FElementBufferMap.Sectors[LMesh.FElementSectorIndex].Offset);

          repeat
            Dec(LInstanceID);
            if Assigned(LInstanceChain) then
              ApplyInstance(ARci, LInstanceChain, LInstanceID);

            if LMesh.FHasIndices then
              DrawElements(
                glPrimitive,
                LCount,
                glType,
                LOffset)
            else
              DrawArrays(glPrimitive, 0, LMesh.FVertexCount);

          until LInstanceID <= 0;

          if not Assigned(ABatch.Material) then
            break;
        until not ABatch.Material.UnApply(ARci);
      end;
    finally
      ARci := storeRci;
      ARci.PipelineTransformation.Pop;
      ARci.GLStates.VertexArrayBinding := 0;
    end;
end;

{$IFDEF GLS_REGION}{$ENDREGION 'TGLDrawTechniqueOGL3'}{$ENDIF}

{$IFDEF GLS_REGION}{$REGION 'TGLDrawTechniqueOGL4'}{$ENDIF}

procedure TGLDrawTechniqueOGL4.DrawBatch(
  var ARci: TRenderContextInfo; const ABatch: TDrawBatch);
var
  LMesh: TFriendlyMesh;
  LInstanceChain: TInstancesChain;
  glPrimitive: TGLEnum;
  glType: TGLEnum;
  LShift: PtrUInt;
  LOffset: Pointer;
  LCount, LInstanceID: Integer;
  storeRci: TRenderContextInfo;
begin
  AllocateBuffers;

  LMesh := TFriendlyMesh(ABatch.Mesh);
  if LMesh.FRevisionNum <> LMesh.FBufferRevision then
  begin
    PlacedInBuffer(LMesh);
    LMesh.FBufferRevision := LMesh.FRevisionNum;
  end;

  if Assigned(ABatch.InstancesChain) and ABatch.InstancesChain.IsValid then
  begin
    LInstanceChain := ABatch.InstancesChain;
    LInstanceID := LInstanceChain.InstanceCount;
  end
  else
  begin
    LInstanceChain := nil;
    LInstanceID := 1;
  end;

  ARci.PipelineTransformation.Push(ABatch.Transformation);
  with GL do
    try
      storeRci := ARci;
      if Assigned(ABatch.Material) then
        ABatch.Material.Apply(ARci);

      if BindStateHandle(ARci.GLStates, LMesh) then
      begin

        if LMesh.FRestartIndex > $FFFF then
          glType := GL_UNSIGNED_INT
        else
          glType := GL_UNSIGNED_SHORT;
        LShift := 0;
        LCount := LMesh.FElements.Count;

        repeat
          // Primitive selection
          glPrimitive := cPrimitiveType[LMesh.FPrimitive];
          if ARci.primitiveMask = [mpPATCHES] then
          begin
            glPrimitive := GL_PATCHES;
            if LMesh.FHasIndices and (LMesh.FTrianglesElements.Count > 0) then
            begin
              // Replace triangles to patches
              PatchParameteri(GL_PATCH_VERTICES, 3);
              LShift := LCount;
              LCount := LMesh.FTrianglesElements.Count;
              if glType = GL_UNSIGNED_SHORT then
              begin
                LShift := LShift * SizeOf(TGLushort);
                RoundTo(LShift, 4);
                glType := GL_UNSIGNED_INT;
              end
              else
                LShift := LShift * SizeOf(TGLuint);
            end
            else if LMesh.FPrimitive <> mpPATCHES then
              continue;
          end
          else if (ARci.primitiveMask = cAdjacencyPrimitives)
            and not (LMesh.FPrimitive in cAdjacencyPrimitives) then
          begin
            glPrimitive := GL_TRIANGLES_ADJACENCY;
            if LMesh.FHasIndices and (LMesh.FAdjacencyElements.Count > 0) then
            begin
              LShift := LCount;
              LCount := LMesh.FAdjacencyElements.Count;
              if glType = GL_UNSIGNED_SHORT then
              begin
                LShift := LShift * SizeOf(TGLushort);
                RoundTo(LShift, 4);
                glType := GL_UNSIGNED_INT;
              end
              else
                LShift := LShift * SizeOf(TGLuint);
              LShift := LShift + Cardinal(LMesh.FTrianglesElements.Count * SizeOf(TGLuint));
            end
            else
              continue;
          end
          else if not (LMesh.FPrimitive in ARci.primitiveMask) then
            continue;

          if IsDesignTime or not LMesh.FHasIndices then
            LOffset := Pointer(LShift)
          else
            LOffset := Pointer(LShift + FElementBufferMap.Sectors[LMesh.FElementSectorIndex].Offset);

          repeat
            Dec(LInstanceID);
            if Assigned(LInstanceChain) then
              ApplyInstance(ARci, LInstanceChain, LInstanceID);

            if LMesh.FHasIndices then
              DrawElements(
                glPrimitive,
                LCount,
                glType,
                LOffset)
            else
              DrawArrays(glPrimitive, 0, LMesh.FVertexCount);

          until LInstanceID <= 0;

          if not Assigned(ABatch.Material) then
            break;
        until not ABatch.Material.UnApply(ARci);
      end;
    finally
      ARci := storeRci;
      ARci.PipelineTransformation.Pop;
      ARci.GLStates.VertexArrayBinding := 0;
    end;
end;

{$IFDEF GLS_REGION}{$ENDREGION 'TGLDrawTechniqueOGL2'}{$ENDIF}

{$IFDEF GLS_REGION}{$REGION 'TGLRenderManager'}{$ENDIF}

procedure TGLRenderManager.RegisterBatch(var ABatch: TDrawBatch);
var
  pBatch: PDrawBatch;
begin
  ABatch.Order := -1;
  pBatch := @ABatch;
  if FBatchList.IndexOf(pBatch) < 0 then
  begin
    FBatchList.Add(pBatch);
  end;
end;

procedure TGLRenderManager.UnRegisterBatch(var ABatch: TDrawBatch);
var
  pBatch: PDrawBatch;
begin
  pBatch := @ABatch;
  FBatchList.Remove(pBatch);
end;

constructor TGLRenderManager.Create(AOwner: TPersistent);
begin
  inherited;
  FBatchList := TList.Create;
  FAxesBatch.Mesh := TMeshAtom.Create;
  AxesBuildMesh(FAxesBatch.Mesh, 1000);
end;

destructor TGLRenderManager.Destroy;
begin
  FBatchList.Destroy;
  FAxesBatch.Mesh.Destroy;
  inherited;
end;

procedure BatchSort(var sortList: TDrawOrderArray; left, right: Integer);
var
  I, J: Integer;
  p, t: Integer;
begin
  repeat
    I := left;
    J := right;
    p := sortList[(left + right) shr 1].Order;
    repeat
      while sortList[I].Order < p do
        Inc(I);
      while sortList[J].Order > p do
        Dec(J);
      if I <= J then
      begin
        t := sortList[I].Order;
        sortList[I].Order := sortList[J].Order;
        sortList[J].Order := t;
        t := sortList[I].Index;
        sortList[I].Index := sortList[J].Index;
        sortList[J].Index := t;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if left < J then
      BatchSort(sortList, left, J);
    left := I;
  until I >= right;
end;

procedure TGLRenderManager.DrawOrderedAll(var ARci: TRenderContextInfo);
var
  pBatch: PDrawBatch;
  LDrawTech: TGLAbstractDrawTechnique;
  I, C: Integer;
  LFirst: Boolean;
begin
  ARci.PipelineTransformation.LoadMatricesEnabled := not ARci.GLStates.ForwardContext;
  LDrawTech := GetDrawTechnique;

  if Length(FDrawOrderArray) < FBatchList.Count then
    SetLength(FDrawOrderArray, FBatchList.Count);

  C := 0;
  for I := 0 to FBatchList.Count - 1 do
  begin
    pBatch := FBatchList[I];
    if not Assigned(pBatch^.Mesh) or not pBatch^.Mesh.IsValid then
      pBatch^.Order := -1;
    if pBatch^.Order > -1 then
    begin
      FDrawOrderArray[C].Order := pBatch^.Order;
      FDrawOrderArray[C].Index := I;
      Inc(C);
    end;
  end;

  if C > 0 then
  begin
    BatchSort(FDrawOrderArray, 0, C - 1);

    for I := 0 to C - 1 do
    begin
      pBatch := FBatchList[FDrawOrderArray[I].Index];
      LDrawTech.DrawBatch(ARci, pBatch^);
    end;

    // Draw AABB
    LFirst := True;
    try
      for I := 0 to C - 1 do
      begin
        pBatch := FBatchList[FDrawOrderArray[I].Index];
        if pBatch^.ShowAABB then
        begin
          if LFirst then
          begin
            LDrawTech.DoBeforeAABBDrawing(ARci);
            LFirst := False;
          end;
          LDrawTech.DrawAABB(ARci, pBatch^);
        end;
        // Reset order
        pBatch^.Order := -1;
      end;
    finally
      if not LFirst then
        LDrawTech.DoAfterAABBDrawing(ARci);
    end;

    // Draw Axes
    LFirst := True;
    try
      for I := 0 to C - 1 do
      begin
        pBatch := FBatchList[FDrawOrderArray[I].Index];
        FAxesBatch.Transformation := pBatch^.Transformation;
        if pBatch^.ShowAxes then
        begin
          if LFirst then
          begin
            GetOrCreateDummyCubeMaterial.Apply(ARci);
            LFirst := False;
          end;
          LDrawTech.DrawBatch(ARci, FAxesBatch);
        end;
      end;
    finally
      if not LFirst then
        GetOrCreateDummyCubeMaterial.UnApply(ARci);
    end;
  end;
end;

function TGLRenderManager.GetDrawTechnique: TGLAbstractDrawTechnique;
begin
  if GL.VERSION_4_1 then
  begin
    if vDrawTechniques[3] = nil then
      vDrawTechniques[3] := TGLDrawTechniqueOGL4.Create;
    Result := vDrawTechniques[3];
  end
  else if GL.VERSION_3_3 then
  begin
    if vDrawTechniques[2] = nil then
      vDrawTechniques[2] := TGLDrawTechniqueOGL3.Create;
    Result := vDrawTechniques[2];
  end
  else if GL.VERSION_2_1 then
  begin
    if vDrawTechniques[1] = nil then
      vDrawTechniques[1] := TGLDrawTechniqueOGL2.Create;
    Result := vDrawTechniques[1];
  end
  else
  begin
    if vDrawTechniques[0] = nil then
      vDrawTechniques[0] := TGLDrawTechniqueOGL1.Create;
    Result := vDrawTechniques[0];
  end;
end;

{$IFDEF GLS_REGION}{$ENDREGION 'TGLRenderManager'}{$ENDIF}

initialization

finalization

  ReleaseDrawTechniques;

end.

