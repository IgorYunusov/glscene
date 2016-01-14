//
// GLScene on Vulkan, http://glscene.sourceforge.net 
//
{
   Doom3 MD5 mesh and animation vector file format implementation. 
}
unit GLS.FileMD5;

interface

uses
  System.Classes, System.SysUtils, GLS.VectorFileObjects, GLS.Utils, 
  GLS.ApplicationFileIO, GLS.VectorTypes, GLS.VectorGeometry, GLS.VectorLists;

type

  TVKMD5VectorFile = class (TVKVectorFile)
    private
      FMD5String,
      FTempString,
      FBoneNames : TStringList;
      FCurrentPos : Integer;
      FBasePose : TVKSkeletonFrame;
      FFramePositions : TAffineVectorList;
      FFrameQuaternions : TQuaternionList;
      FJointFlags : TIntegerList;
      FNumFrames,
      FFirstFrame,
      FFrameRate,
      FNumJoints : Integer;

      function ReadLine : String;

    public
      class function Capabilities : TVKDataFileCapabilities; override;
      procedure LoadFromStream(aStream : TStream); override;
  end;

var
  vMD5TextureExtensions : TStringList;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

// -----------
// ----------- TVKMD5VectorFile -----------
// -----------

// ReadLine
//
function TVKMD5VectorFile.ReadLine : String;
begin
  Result:='';
  if not Assigned(FMD5String) then exit;
  if FCurrentPos>=FMD5String.Count then exit;
  repeat
    Result:=FMD5String[FCurrentPos];
    Result:=StringReplace(Result, '(', '', [rfReplaceAll]);
    Result:=StringReplace(Result, ')', '', [rfReplaceAll]);
    Result:=Trim(Result);
    Inc(FCurrentPos);
  until (Result <> '') or (FCurrentPos>=FMD5String.Count);
end;

// Capabilities
//
class function TVKMD5VectorFile.Capabilities : TVKDataFileCapabilities;
begin
  Result:=[dfcRead];
end;

// LoadFromStream
//
procedure TVKMD5VectorFile.LoadFromStream(aStream : TStream);

  procedure AllocateMaterial(var shader : String);
  {const
    cTexType : array[0..2] of String = ('_local', '_d', '_s');
  var
    shader_nopath, temp : String;
    libmat : TVKLibMaterial;
    i, j : Integer;//}
  begin
    {if Assigned(Owner.MaterialLibrary) then begin
      shader:=StringReplace(shader,'/','\',[rfReplaceAll]);
      if not DirectoryExists(ExtractFilePath(shader)) then
        shader:=ExtractFileName(shader);
      if not Assigned(Owner.MaterialLibrary.Materials.GetLibMaterialByName(shader)) then begin
        libmat:=Owner.MaterialLibrary.Materials.Add;
        libmat.Name:=shader;
        for i:=0 to High(cTexType) do begin
          temp:=ChangeFileExt(shader, '')+cTexType[i];
          for j:=0 to vMD5TextureExtensions.Count-1 do begin
            if FileExists(temp+vMD5TextureExtensions[j]) then begin
              with libmat.Material.TextureEx.Add do begin
                Texture.Image.LoadFromFile(temp+vMD5TextureExtensions[j]);
                Texture.Enabled:=True;
              end;
              Break;
            end;
          end;
        end;
      end;
    end else//}
      shader:='';
  end;

  function QuaternionMakeFromImag(ix, iy, iz : Single) : TQuaternion;
  var
    rr : Single;
  begin
    with Result do begin
      ImagPart.V[0]:=ix;
      ImagPart.V[1]:=iy;
      ImagPart.V[2]:=iz;
      rr:=1-(ix*ix)-(iy*iy)-(iz*iz);
      if rr<0 then RealPart:=0
      else RealPart:=sqrt(rr);
    end;
  end;

  procedure ReadBone(BoneNum : Integer; BoneString : String);
  var
    bonename : String;
    pos : TAffineVector;
    quat : TQuaternion;
    mat, rmat : TMatrix;
    ParentBoneID : Integer;
    bone, parentbone : TVKSkeletonBone;
  begin
    FTempString.CommaText:=BoneString;

    bonename:=FTempString[0];
    ParentBoneID:=StrToInt(FTempString[1]);

    pos.V[0]:=GLS.Utils.StrToFloatDef(FTempString[2]);
    pos.V[1]:=GLS.Utils.StrToFloatDef(FTempString[4]);
    pos.V[2]:=GLS.Utils.StrToFloatDef(FTempString[3]);

    quat:=QuaternionMakeFromImag(GLS.Utils.StrToFloatDef(FTempString[5]),
                                 GLS.Utils.StrToFloatDef(FTempString[7]),
                                 GLS.Utils.StrToFloatDef(FTempString[6]));

    FFramePositions.Add(pos);
    FFrameQuaternions.Add(quat);

    if bonename<>'' then begin
      FBoneNames.Add(bonename);
      if ParentBoneID = -1 then
        bone:=TVKSkeletonBone.CreateOwned(Owner.Skeleton.RootBones)
      else begin
        parentBone:=Owner.Skeleton.RootBones.BoneByID(ParentBoneID);
        bone:=TVKSkeletonBone.CreateOwned(parentBone);

        mat:=QuaternionToMatrix(quat);
        mat.V[3]:=PointMake(pos);
        rmat:=QuaternionToMatrix(FFrameQuaternions[ParentBoneID]);
        rmat.V[3]:=PointMake(FFramePositions[ParentBoneID]);
        InvertMatrix(rmat);
        mat:=MatrixMultiply(mat, rmat);

        pos:=AffineVectorMake(mat.V[3]);
        quat:=QuaternionFromMatrix(mat);
      end;
      with bone do begin
        BoneID:=BoneNum;
        Name:=bonename;
      end;
    end;

    FBasePose.Position[BoneNum]:=pos;
    FBasePose.Quaternion[BoneNum]:=quat;
  end;

  procedure ReadJoints;
  var
    temp : String;
    i : Integer;
  begin
    i:=0;
    repeat
      temp:=ReadLine;
      if temp<>'}' then begin
        ReadBone(i, temp);
        Inc(i);
      end;
    until temp = '}';
    Owner.Skeleton.CurrentFrame.Assign(FBasePose);
    Owner.Skeleton.CurrentFrame.FlushLocalMatrixList;
    Owner.Skeleton.RootBones.PrepareGlobalMatrices;
  end;

  procedure ReadMesh;
  var
    temp, shader : String;
    mesh : TVKSkeletonMeshObject;
    fg : TFGVertexIndexList;
    vnum, wnum,
    numverts, numweights : Integer;
    VertexWeightID,
    VertexWeightCount,
    VertexBoneRef : TIntegerList;
    VertexWeight : TSingleList;
    VertexWeighted : TAffineVectorList;
    blendedVert, transformedVert : TAffineVector;
    i,j,k : Integer;
    mat : TMatrix;
  begin
    VertexWeightID:=TIntegerList.Create;
    VertexWeightCount:=TIntegerList.Create;
    VertexBoneRef:=TIntegerList.Create;
    VertexWeight:=TSingleList.Create;
    VertexWeighted:=TAffineVectorList.Create;

    numverts:=0;

    mesh:=TVKSkeletonMeshObject.CreateOwned(Owner.MeshObjects);
    fg:=TFGVertexIndexList.CreateOwned(mesh.FaceGroups);
    mesh.Mode:=momFaceGroups;
    fg.Mode:=fgmmTriangles;
    repeat
      temp:=ReadLine;
      FTempString.CommaText:=temp;
      if FTempString.Count>1 then begin
        temp:=LowerCase(FTempString[0]);
        if temp = 'shader' then begin
          shader:=FTempString[1];
          AllocateMaterial(shader);
          fg.MaterialName:=shader;
        end else if temp = 'numverts' then begin
          numverts:=StrToInt(FTempString[1]);
          mesh.TexCoords.Count:=numverts;
          VertexWeightID.Count:=numverts;
          VertexWeightCount.Count:=numverts;
        end else if temp = 'vert' then begin
          if FTempString.Count>=6 then begin
            vnum:=StrToInt(FTempString[1]);
            mesh.TexCoords[vnum]:=AffineVectorMake(
              GLS.Utils.StrToFloatDef(FTempString[2]),
              1-GLS.Utils.StrToFloatDef(FTempString[3]),
              0);
            VertexWeightID[vnum]:=StrToInt(FTempString[4]);
            VertexWeightCount[vnum]:=StrToInt(FTempString[5]);
            if VertexWeightCount[vnum]>mesh.BonesPerVertex then
               mesh.BonesPerVertex:=VertexWeightCount[vnum];
          end;
        end else if temp = 'numtris' then begin
          fg.VertexIndices.Capacity:=StrToInt(FTempString[1])*3;
        end else if temp = 'tri' then begin
          if FTempString.Count>=5 then begin
            fg.VertexIndices.Add(StrToInt(FTempString[2]));
            fg.VertexIndices.Add(StrToInt(FTempString[3]));
            fg.VertexIndices.Add(StrToInt(FTempString[4]));
          end;
        end else if temp = 'numweights' then begin
          numweights:=StrToInt(FTempString[1]);
          VertexBoneRef.Count:=numweights;
          VertexWeight.Count:=numweights;
          VertexWeighted.Count:=numweights;
        end else if temp = 'weight' then begin
          if FTempString.Count>=7 then begin
            wnum:=StrToInt(FTempString[1]);
            VertexBoneRef[wnum]:=StrToInt(FTempString[2]);
            VertexWeight[wnum]:=GLS.Utils.StrToFloatDef(FTempString[3]);
            VertexWeighted[wnum]:=AffineVectorMake(
              GLS.Utils.StrToFloatDef(FTempString[4]),
              GLS.Utils.StrToFloatDef(FTempString[6]),
              GLS.Utils.StrToFloatDef(FTempString[5]));
          end;
        end;
      end;
    until temp = '}';

    mesh.Vertices.Count:=numverts;
    mesh.VerticeBoneWeightCount:=numverts;
    for i:=0 to numverts-1 do begin
      blendedVert:=NullVector;
      for j:=0 to mesh.BonesPerVertex-1 do begin
        if j<VertexWeightCount[i] then begin
          k:=VertexWeightID[i]+j;
          mesh.VerticesBonesWeights^[i]^[j].BoneID:=VertexBoneRef[k];
          mesh.VerticesBonesWeights^[i]^[j].Weight:=VertexWeight[k];
          mat:=Owner.Skeleton.RootBones.BoneByID(VertexBoneRef[k]).GlobalMatrix;
          transformedVert:=VectorTransform(VertexWeighted[k], mat);
          AddVector(blendedVert, VectorScale(transformedVert, VertexWeight[k]));
        end else begin
          mesh.VerticesBonesWeights^[i]^[j].BoneID:=0;
          mesh.VerticesBonesWeights^[i]^[j].Weight:=0;
        end;
      end;
      mesh.Vertices[i]:=blendedVert;
    end;

    mesh.BuildNormals(fg.VertexIndices, momTriangles);

    VertexWeightID.Free;
    VertexWeightCount.Free;
    VertexBoneRef.Free;
    VertexWeight.Free;
    VertexWeighted.Free;
  end;

  procedure ReadHierarchy;
  var
    temp : String;
    bone : TVKSkeletonBone;
  begin
    if not Assigned(FJointFlags) then begin
      FJointFlags:=TIntegerList.Create;
      Assert(Owner.Skeleton.Frames.Count>0, 'The md5mesh file must be loaded before md5anim files!');
      FJointFlags.Count:=Owner.Skeleton.Frames[0].Position.Count;
    end;
    repeat
      temp:=ReadLine;
      FTempString.CommaText:=temp;
      if FTempString.Count>=3 then begin
        bone:=Owner.Skeleton.BoneByName(FTempString[0]);
        if Assigned(bone) then
          FJointFlags[bone.BoneID]:=StrToInt(FTempString[2]);
      end;
    until temp = '}';
  end;

  procedure ReadBaseFrame;
  var
    temp : String;
    pos : TAffineVector;
    quat : TQuaternion;
  begin
    FFramePositions.Clear;
    FFrameQuaternions.Clear;
    repeat
      temp:=ReadLine;
      FTempString.CommaText:=temp;
      if FTempString.Count>=6 then begin
        pos:=AffineVectorMake(
          GLS.Utils.StrToFloatDef(FTempString[0]),
          GLS.Utils.StrToFloatDef(FTempString[1]),
          GLS.Utils.StrToFloatDef(FTempString[2]));
        quat:=QuaternionMakeFromImag(
          GLS.Utils.StrToFloatDef(FTempString[3]),
          GLS.Utils.StrToFloatDef(FTempString[4]),
          GLS.Utils.StrToFloatDef(FTempString[5]));
        FFramePositions.Add(pos);
        FFrameQuaternions.Add(quat);
      end;
    until temp = '}';
  end;

  procedure ReadFrame(framenum : Integer);
  var
    temp : String;
    i,j : Integer;
    frame : TVKSkeletonFrame;
    pos : TAffineVector;
    quat : TQuaternion;
  begin
    frame:=Owner.Skeleton.Frames[FFirstFrame+framenum];
    frame.TransformMode:=sftQuaternion;
    frame.Position.Count:=FNumJoints;
    frame.Quaternion.Count:=FNumJoints;
    for i:=0 to FJointFlags.Count-1 do begin
      pos:=FFramePositions[i];
      quat:=FFrameQuaternions[i];

      if FJointFlags[i] > 0 then begin
        temp:=ReadLine;
        FTempString.CommaText:=temp;
        j:=0;

        if FJointFlags[i] and 1 > 0 then begin
          pos.V[0]:=GLS.Utils.StrToFloatDef(FTempString[j]);
          Inc(j);
        end;
        if FJointFlags[i] and 2 > 0 then begin
          pos.V[1]:=GLS.Utils.StrToFloatDef(FTempString[j]);
          Inc(j);
        end;
        if FJointFlags[i] and 4 > 0 then begin
          pos.V[2]:=GLS.Utils.StrToFloatDef(FTempString[j]);
          Inc(j);
        end;

        if FJointFlags[i] and 8 > 0 then begin
          quat.ImagPart.V[0]:=GLS.Utils.StrToFloatDef(FTempString[j]);
          Inc(j);
        end;
        if FJointFlags[i] and 16 > 0 then begin
          quat.ImagPart.V[1]:=GLS.Utils.StrToFloatDef(FTempString[j]);
          Inc(j);
        end;
        if FJointFlags[i] and 32 > 0 then
          quat.ImagPart.V[2]:=GLS.Utils.StrToFloatDef(FTempString[j]);
      end;

      pos:=AffineVectorMake(pos.V[0], pos.V[2], pos.V[1]);
      quat:=QuaternionMakeFromImag(quat.ImagPart.V[0], quat.ImagPart.V[2], quat.ImagPart.V[1]);

      frame.Position[i]:=pos;
      frame.Quaternion[i]:=quat;
    end;
  end;

  procedure InitializeMeshes;
  var
    i : Integer;
  begin
    for i:=0 to Owner.MeshObjects.Count-1 do
      TVKSkeletonMeshObject(Owner.MeshObjects[i]).PrepareBoneMatrixInvertedMeshes;
  end;

var
  str,temp : String;
  nummeshes,
  md5Version,
  meshid, i : Integer;
begin
  FCurrentPos:=0;
  FMD5String:=TStringList.Create;
  FTempString:=TStringList.Create;
  FBoneNames:=TStringList.Create;

  meshid:=0;
  nummeshes:=0;
  md5Version:=0;

  try
    FMD5String.LoadFromStream(aStream);

    // Version checking
    str:=ReadLine;
    FTempString.CommaText:=str;
    if FTempString.Count>=2 then
      if LowerCase(FTempString[0]) = 'md5version' then
        md5Version:=StrToInt(FTempString[1]);
    Assert(md5Version = 10, 'Invalid or missing md5Version number.');

    repeat
      str:=ReadLine;
      FTempString.CommaText:=str;
      if FTempString.Count>1 then begin
        temp:=LowerCase(FTempString[0]);
        if (temp = 'numjoints') then begin
          FNumJoints:=StrToInt(FTempString[1]);
          FFramePositions:=TAffineVectorList.Create;
          FFrameQuaternions:=TQuaternionList.Create;
          if Owner.Skeleton.Frames.Count = 0 then begin
            FBasePose:=TVKSkeletonFrame.CreateOwned(Owner.Skeleton.Frames);
            FBasePose.Position.Count:=FNumJoints;
            FBasePose.TransformMode:=sftQuaternion;
            FBasePose.Quaternion.Count:=FNumJoints;
          end else
            FBasePose:=Owner.Skeleton.Frames[0];
        end else if (temp = 'joints') then begin
          ReadJoints;
          if Owner is TVKActor then
            TVKActor(Owner).Reference:=aarSkeleton;
        end else if (temp = 'nummeshes') then begin
          nummeshes:=StrToInt(FTempString[1]);
        end else if (temp = 'mesh') then begin
          if meshid<nummeshes then begin
            ReadMesh;
            if meshid = numMeshes - 1 then
              InitializeMeshes;
            Inc(meshid);
          end else begin
            repeat
              str:=ReadLine;
            until str = '}';
          end;
        end else if (temp = 'hierarchy') then begin
          ReadHierarchy;
        end else if (temp = 'numframes') then begin
          FNumFrames:=StrToInt(FTempString[1]);
          if FNumFrames>0 then begin
            FFirstFrame:=Owner.Skeleton.Frames.Count;
            for i:=1 to FNumFrames do
              TVKSkeletonFrame.CreateOwned(Owner.Skeleton.Frames);
            if Owner is TVKActor then begin
              with TVKActor(Owner).Animations.Add do begin
                Name:=ChangeFileExt(ExtractFileName(ResourceName), '');
                Reference:=aarSkeleton;
                StartFrame:=FFirstFrame;
                EndFrame:=FFirstFrame+FNumFrames-1;
              end;
            end;
          end;
        end else if (temp = 'framerate') then begin
          FFrameRate:=StrToInt(FTempString[1]);
        end else if (temp = 'baseframe') then begin
          ReadBaseFrame;
        end else if (temp = 'frame') then begin
          ReadFrame(StrToInt(FTempString[1]));
        end;
      end;
    until str = '';

  finally
    if Assigned(FFramePositions) then
      FreeAndNil(FFramePositions);
    if Assigned(FFrameQuaternions) then
      FreeAndNil(FFrameQuaternions);
    if Assigned(FJointFlags) then
      FreeAndNil(FJointFlags);
    FBoneNames.Free;
    FTempString.Free;
    FMD5String.Free;
  end;
end;


// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
initialization
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

  RegisterVectorFileFormat('md5mesh', 'Doom3 mesh files', TVKMD5VectorFile);
  RegisterVectorFileFormat('md5anim', 'Doom3 animation files', TVKMD5VectorFile);

  vMD5TextureExtensions:=TStringList.Create;
  with vMD5TextureExtensions do begin
    Add('.bmp');
    Add('.dds');
    Add('.jpg');
    Add('.tga');
  end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
finalization
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

  vMD5TextureExtensions.Free;

end.

