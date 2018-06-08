//
// VXScene Component Library, based on GLScene http://glscene.sourceforge.net 
//
{
	Ghoul2 (GLM/GLA) file format loading structures 
	Also referred to as MDX (MDXM/MDXA) format in C source. 
}
unit uFileGL2;

interface

uses
  System.Classes,
  System.SysUtils,
  VXS.VectorTypes,
  VXS.VectorGeometry;

type
  TVXMHeader = record
    fileID           : array[0..3] of char;
    version          : integer;
    strFile,
    animName         : array[0..63] of char;
    animIndex,
    numBones,
    numLODs,
    ofsLODs,
    numSurfaces,
    ofsSurfHierarchy,
    ofsEnd           : integer;
  end;

  TVXMSurfaceHeirachyOffsets = array of integer;

  TVXMSurfaceHeirachy = record
    name         : array[0..63] of Char;
    flags        : LongWord;
    shader       : array[0..63] of Char;
    shaderIndex,
    parentIndex,
    numChildren  : integer;
    childIndices : array of integer;
  end;

  TVXMSurfaceHeader = record
    ident,
    thisSurfaceIndex,
    ofsHeader,
    numVerts,
    ofsVerts,
    numTriangles,
    ofsTriangles,
    numBoneReferences,
    ofsBoneReferences,
    ofsEnd            : integer;
  end;

  TVXMTriangle = record
    indices : array[0..2] of integer;
  end;

  TVXMVertex = record
    normal,
    vertex                     : TVector3f;
    uiNumWeightsAndBoneIndices : Cardinal; // packed int
    BoneWeightings             : array[0..3] of Byte;
  end;

  TVXMSurface = record
    SurfaceHeader : TVXMSurfaceHeader;
    Triangles      : array of TVXMTriangle;
    Vertices       : array of TVXMVertex;
    TexCoords      : array of TVector2f;
    BoneReferences : array of Integer;
  end;

  TVXMLODInfo = record
    ofsEnd : integer;
  end;

  TVXMLODSurfaceOffsets = array of integer;

  TVXMLODs = record
    LODInfo           : TVXMLODInfo;
    LODSurfaceOffsets : TVXMLODSurfaceOffsets;
    Surfaces          : array of TVXMSurface;
  end;

  TVXAHeader = record
    fileID     : array[0..3] of char;
    version    : integer;
    Name       : array[0..63] of char;
    fScale     : single;
    numFrames,
    ofsFrames,
    numBones,
    ofsCompBonePool,
    ofsSkel,
    ofsEnd     : integer;
  end;

  TVXABone = array[0..2] of TVector4f;
  TVXACompQuatBone = array[0..6] of Word; {14 bytes}

  TVXASkeletonOffsets = array of integer;

  TVXASkeleton = record
    name           : array[0..63] of char;
    flags          : LongWord;
    parent         : Integer;
    BasePoseMat,
    BasePoseMatInv : TVXABone;
    numChildren    : Integer;
    children       : array of Integer;
  end;

  // Ghoul2 Model structure
  TFileGLM = class
    public
      ModelHeader            : TVXMHeader;
      SurfaceHeirachyOffsets : TVXMSurfaceHeirachyOffsets;
      SurfaceHeirachy        : array of TVXMSurfaceHeirachy;
      LODs                   : array of TVXMLODs;
      procedure LoadFromStream(aStream : TStream);
  end;

  // Ghoul2 Animation structure
  TFileGLA = class
    public
      AnimHeader      : TVXAHeader;
      SkeletonOffsets : TVXASkeletonOffsets;
      Skeleton        : array of TVXASkeleton;
      BoneIndices     : array of Integer;
      CompBonePool    : array of TVXACompQuatBone;
      function GetCompressedMatrix(Frame,Bone : Integer):TVXACompQuatBone;
      function GetUnCompressedMatrix(Frame,Bone : Integer):TMatrix;
      procedure LoadFromStream(aStream : TStream);
  end;

function G2_GetVertWeights(vert:TVXMVertex):Integer;
function G2_GetVertBoneIndex(vert:TVXMVertex; iWeightNum:Integer):Integer;
function G2_GetVertBoneWeight(vert:TVXMVertex; iWeightNum:Cardinal; 
  var fTotalWeight:Single; const iNumWeights:Cardinal):single;

procedure MC_UnCompressQuat(var mat : TMatrix; const comp : TVXACompQuatBone);

// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------

// ------------------
// ------------------ Misc routines ------------------
// ------------------

// Adapted from mdx_format.h
// static inline int G2_GetVertWeights( const mdxmVertex_t *pVert )
// static inline int G2_GetVertBoneIndex( const mdxmVertex_t *pVert, const int iWeightNum)
// static inline float G2_GetVertBoneWeight( const mdxmVertex_t *pVert, const int iWeightNum, float &fTotalWeight, int iNumWeights )

function G2_GetVertWeights(vert:TVXMVertex):Integer;
begin
  // Get number of bones per vertex (0..3)+1 = (1..4)
  result:=(vert.uiNumWeightsAndBoneIndices shr 30)+1;
end;

function G2_GetVertBoneIndex(vert:TVXMVertex; iWeightNum:Integer):Integer;
begin
  // Extract the bone reference array index, a 5-bit integer
  result:=(vert.uiNumWeightsAndBoneIndices shr (5*iWeightNum)) and 31;
end;

function G2_GetVertBoneWeight(vert:TVXMVertex; iWeightNum:Cardinal;
  var fTotalWeight:Single; const iNumWeights:Cardinal):single;
var
  fBoneWeight : Single;
  iTemp       : Cardinal;
begin
  if (iWeightNum = iNumWeights-1) then begin
    // No need to calculate final weight value, return the
    // weight left over out of 1
    fBoneWeight:=1-fTotalWeight;
  end else begin
    // Get the initial 8-bit bone weight
    iTemp:=vert.BoneWeightings[iWeightNum];
    // Get the 2-bit overflow and 'or' it to the front of the
    // weight to get 10-bit integer weight (0..1023)
    iTemp:=iTemp or ((vert.uiNumWeightsAndBoneIndices shr (12+(iWeightNum*2))) and $300);
    // Convert to floating point weight (0..1)
    fBoneWeight:=iTemp/1023;
    // Accumulate total weight
    fTotalWeight:=fTotalWeight+fBoneWeight;
  end;
  Result:=fBoneWeight;
end;

// Adapted from matcomp.c
// void MC_UnCompressQuat(float mat[3][4],const unsigned char * comp)

procedure MC_UnCompressQuat(var mat : TMatrix; const comp : TVXACompQuatBone);
begin
  mat:=QuaternionToMatrix(QuaternionMake([comp[1]-32726,comp[2]-32726,comp[3]-32726],comp[0]-32726));
  mat.W:=VectorMake(comp[4]/64-512,comp[5]/64-512,comp[6]/64-512,1);
end;


// ------------------
// ------------------ TFileGLM ------------------
// ------------------

procedure TFileGLM.LoadFromStream(aStream: TStream);
var
  idstr   : array[0..3] of char;
  i,j     : integer;
  ofs,
  LODofs  : int64;
begin
  aStream.Read(idstr,sizeof(idstr));
  aStream.Position:=0;

  if not (idstr='2LGM') then begin
    raise Exception.Create(Format('Unknown or incorrect identity tag: [%s]',[idstr]));
    exit;
  end;

  aStream.Read(ModelHeader,SizeOf(ModelHeader));

  if ModelHeader.version<>6 then
    raise Exception.Create(Format('Only GLM (MDXM) version 6 is supported. File is version %d.',[ModelHeader.version]));

  SetLength(SurfaceHeirachyOffsets,ModelHeader.numSurfaces);
  aStream.Read(SurfaceHeirachyOffsets[0],sizeof(Integer)*ModelHeader.numSurfaces);

  SetLength(SurfaceHeirachy,ModelHeader.numSurfaces);
  for i:=0 to ModelHeader.numSurfaces-1 do
  with SurfaceHeirachy[i] do begin
    aStream.Read(name,Length(name));
    aStream.Read(flags,sizeof(LongWord));
    aStream.Read(shader,Length(shader));
    aStream.Read(shaderindex,sizeof(Integer));
    aStream.Read(parentindex,sizeof(Integer));
    aStream.Read(numChildren,sizeof(Integer));
    if numChildren>0 then begin
      SetLength(childIndices,numChildren);
      aStream.Read(childIndices[0],numChildren*sizeof(Integer));
    end else SetLength(childIndices,0);
  end;

  SetLength(LODs,ModelHeader.numLODs);
  for i:=0 to ModelHeader.numLODs-1 do
  with LODs[i] do begin
    LODofs:=aStream.Position;
    aStream.Read(LODInfo,sizeof(LODInfo));
    SetLength(LODSurfaceOffsets,ModelHeader.numSurfaces);
    aStream.Read(LODSurfaceOffsets[0],sizeof(integer)*ModelHeader.numSurfaces);
    SetLength(Surfaces,ModelHeader.numSurfaces);
    for j:=0 to ModelHeader.numSurfaces-1 do
    with Surfaces[j] do begin
      ofs:=aStream.Position;
      aStream.Read(SurfaceHeader,SizeOf(TVXMSurfaceHeader));
      SetLength(Triangles,SurfaceHeader.numTriangles);
      SetLength(Vertices,SurfaceHeader.numVerts);
      SetLength(TexCoords,SurfaceHeader.numVerts);
      SetLength(BoneReferences,SurfaceHeader.numBoneReferences);
      aStream.Position:=ofs+SurfaceHeader.ofsTriangles;
      aStream.Read(Triangles[0],SurfaceHeader.numTriangles*SizeOf(TVXMTriangle));
      aStream.Position:=ofs+SurfaceHeader.ofsVerts;
      aStream.Read(Vertices[0],SurfaceHeader.numVerts*SizeOf(TVXMVertex));
      aStream.Read(TexCoords[0],SurfaceHeader.numVerts*SizeOf(TVector2f));
      aStream.Position:=ofs+SurfaceHeader.ofsBoneReferences;
      aStream.Read(BoneReferences[0],SurfaceHeader.numBoneReferences*SizeOf(Integer));
      aStream.Position:=ofs+SurfaceHeader.ofsEnd;
    end;
    aStream.Position:=LODofs+LODInfo.ofsEnd;
  end;
end;


// ------------------
// ------------------ TFileGLA ------------------
// ------------------

function TFileGLA.GetCompressedMatrix(Frame, Bone: Integer): TVXACompQuatBone;
begin
  Result:=CompBonePool[BoneIndices[Frame*AnimHeader.numBones+Bone]];
end;

// GetUnCompressedMatrix
//
function TFileGLA.GetUnCompressedMatrix(Frame, Bone: Integer): TMatrix;
begin
  MC_UnCompressQuat(Result,CompBonePool[BoneIndices[Frame*AnimHeader.numBones+Bone]]);
end;

procedure TFileGLA.LoadFromStream(aStream: TStream);
var
  idstr  : array[0..3] of char;
  i,temp : integer;
  buf    : array of array[0..2] of Byte;
begin
  aStream.Read(idstr,sizeof(idstr));
  aStream.Position:=0;

  if not (idstr='2LGA') then begin
    raise Exception.Create(Format('Unknown or incorrect identity tag: [%s]',[idstr]));
    exit;
  end;

  aStream.Read(AnimHeader,SizeOf(AnimHeader));

  if AnimHeader.version<>6 then
    raise Exception.Create(Format('Only GLA (MDXA) version 6 is supported. File is version %d.',[AnimHeader.version]));

  SetLength(SkeletonOffsets,AnimHeader.numBones);
  aStream.Read(SkeletonOffsets[0],sizeof(Integer)*AnimHeader.numBones);

  SetLength(Skeleton,AnimHeader.numBones);
  for i:=0 to AnimHeader.numBones-1 do
  with Skeleton[i] do begin
    aStream.Read(name,Length(name));
    aStream.Read(flags,sizeof(LongWord));
    aStream.Read(Parent,SizeOf(Integer));
    aStream.Read(basePoseMat,sizeof(TVXABone));
    aStream.Read(basePoseMatInv,sizeof(TVXABone));
    aStream.Read(numChildren,sizeof(Integer));
    if numChildren>0 then begin
      SetLength(children,numChildren);
      aStream.Read(children[0],numChildren*sizeof(Integer));
    end else SetLength(children,0);
  end;

  aStream.Position:=AnimHeader.ofsFrames;
  SetLength(BoneIndices,AnimHeader.numFrames*AnimHeader.numBones);
  SetLength(buf,AnimHeader.numFrames*AnimHeader.numBones*3);
  aStream.Read(buf[0],AnimHeader.numFrames*AnimHeader.numBones*3);
  for i:=0 to AnimHeader.numFrames*AnimHeader.numBones-1 do
    BoneIndices[i]:=(buf[i][2] shl 16) or (buf[i][1] shl 8) or buf[i][0];
  SetLength(buf,0);

  aStream.Position:=AnimHeader.ofsCompBonePool;
  temp:=AnimHeader.ofsEnd-AnimHeader.ofsCompBonePool;
  SetLength(CompBonePool,temp div SizeOf(TVXACompQuatBone));
  aStream.Read(CompBonePool[0],temp);
end;

end.
