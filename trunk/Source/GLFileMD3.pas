//
// This unit is part of the GLScene Project, http://glscene.org
//
{
  GLFileMD3 - Code for loading animated MD3 files into GLScene
              FreeForms and Actors.

  History :
    <li>10/11/12 - PW - Added CPP compatibility: changed vector arrays to records
    <li>02/08/04 - LR, YHC - BCB corrections: use record instead array
    <li>21/08/03 - EG - Fixed GetNormalFromMD3Normal (lat/lon were inverted)
    <li>28/02/03 - SG - Creation
}
unit GLFileMD3;

interface

uses
  Classes, SysUtils, GLVectorFileObjects, GLMaterial, ApplicationFileIO,
  VectorGeometry, FileMD3;

type

  TGLMD3VectorFile = class (TVectorFile)
    public
      class function Capabilities : TDataFileCapabilities; override;
      procedure LoadFromStream(aStream : TStream); override;
  end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

// ------------------
// ------------------ TGLMD3VectorFile ------------------
// ------------------

// Capabilities
//
class function TGLMD3VectorFile.Capabilities : TDataFileCapabilities;
begin
  Result:=[dfcRead];
end;

// LoadFromStream
//
procedure TGLMD3VectorFile.LoadFromStream(aStream : TStream);
var
  i,j,k,
  numVerts,
  numtris     : Integer;
  MD3File     : TFileMD3;
  mesh        : TMorphableMeshObject;
  faceGroup   : TFGIndexTexCoordList;
  morphTarget : TMeshMorphTarget;

  function GetNormalFromMD3Normal(n : array of Byte) : TAffineVector;
  var
    lat,lng : single;
  begin
    // The MD3 normal is a latitude/longitude value that needs
    // to be calculated into cartesian space.
    lat:=(n[1])*(2*pi)/255; lng:=(n[0])*(2*pi)/255;
    result.V[0]:=cos(lat)*sin(lng);
    result.V[1]:=sin(lat)*sin(lng);
    result.V[2]:=cos(lng);
  end;

  procedure AllocateMaterial(meshname:string);
  var
    LibMat : TGLLibMaterial;
  begin
    // If a material library is assigned to the actor/freeform the
    // mesh name will be added as a material.
    if Assigned(Owner.MaterialLibrary) then with Owner.MaterialLibrary do begin
      if Assigned(Materials.GetLibMaterialByName(meshname)) then exit;
      LibMat:=Materials.Add;
      LibMat.name:=meshname;
      LibMat.Material.Texture.Disabled:=False;
    end;
  end;

begin
  MD3File:=TFileMD3.Create;
  MD3File.LoadFromStream(aStream);
  try
    for i:=0 to MD3File.ModelHeader.numMeshes-1 do begin
      mesh:=TMorphableMeshObject.CreateOwned(Owner.MeshObjects);
      mesh.Name:=trim(string(MD3File.MeshData[i].MeshHeader.strName));
      with mesh, MD3File do begin
        Mode:=momFaceGroups;
        faceGroup:=TFGIndexTexCoordList.CreateOwned(FaceGroups);
        with faceGroup do begin
          AllocateMaterial(mesh.Name);
          MaterialName:=mesh.Name;
          numTris:=MeshData[i].MeshHeader.numTriangles;
          VertexIndices.Capacity:=numTris*3;
          TexCoords.Capacity:=numTris*3;
          // Get the vertex indices and texture coordinates
          for j:=0 to MeshData[i].MeshHeader.numTriangles-1 do begin
            with MeshData[i].Triangles[j] do begin
              Add(vertexIndices.V[0],
                  MeshData[i].TexCoords[vertexIndices.V[0]].textureCoord.V[0],
                  1-MeshData[i].TexCoords[vertexIndices.V[0]].textureCoord.V[1]);
              Add(vertexIndices.V[2],
                  MeshData[i].TexCoords[vertexIndices.V[2]].textureCoord.V[0],
                  1-MeshData[i].TexCoords[vertexIndices.V[2]].textureCoord.V[1]);
              Add(vertexIndices.V[1],
                  MeshData[i].TexCoords[vertexIndices.V[1]].textureCoord.V[0],
                  1-MeshData[i].TexCoords[vertexIndices.V[1]].textureCoord.V[1]);
            end;
          end;
        end;

        // Get the mesh data for each morph frame
        for j:=0 to ModelHeader.numFrames-1 do begin
          morphTarget:=TMeshMorphTarget.CreateOwned(MorphTargets);
          morphTarget.Name:=Trim(string(MeshData[i].MeshHeader.strName))+'['+IntToStr(j)+']';
          numVerts:=MeshData[i].MeshHeader.numVertices;
          morphTarget.Vertices.Capacity:=numVerts;
          for k:=numVerts*j to numVerts*(j+1)-1 do begin
            morphTarget.Vertices.Add(
              MeshData[i].Vertices[k].Vertex.V[0]/64,
              MeshData[i].Vertices[k].Vertex.V[1]/64,
              MeshData[i].Vertices[k].Vertex.V[2]/64);
            morphTarget.Normals.Add(
              GetNormalFromMD3Normal(MeshData[i].Vertices[k].normal.V));
          end;
        end;
      end;
      if mesh.MorphTargets.Count>0 then
        mesh.MorphTo(0);
    end;
  finally
    MD3File.Free;
  end;
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
initialization
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

   RegisterVectorFileFormat('md3', 'MD3 files', TGLMD3VectorFile);

end.