//
// VXScene Component Library, based on GLScene http://glscene.sourceforge.net
//
{
  GTS (GNU Triangulated Surface) vector file format implementation.
}
unit VXS.FileGTS;

interface

{$I VXScene.inc}

uses
  System.Classes,
  VXS.VectorFileObjects,
  VXS.ApplicationFileIO;

type
  { The GTS vector file (GNU Triangulated Surface library).
    It is a simple text format, with indexed vertices. The first line contains
    the number of vertices, the number of edges and the number of faces separated
    by spaces.
    Following lines contain the x/y/z coordinates of vertices, then the edges
    (two indices) and the faces (three indices).
    http://gts.sourceforge.net/ }
  TVXGTSVectorFile = class(TVXVectorFile)
  public
    class function Capabilities: TVXDataFileCapabilities; override;
    procedure LoadFromStream(aStream: TStream); override;
  end;

// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------

uses
  System.SysUtils,
  VXS.Utils;

// ------------------
// ------------------ TVXGTSVectorFile ------------------
// ------------------

class function TVXGTSVectorFile.Capabilities: TVXDataFileCapabilities;
begin
  Result := [dfcRead];
end;

procedure TVXGTSVectorFile.LoadFromStream(aStream: TStream);
var
  i, nv, ne, nf, k, ei: Integer;
  sl: TStringList;
  mesh: TVXMeshObject;
  fg: TFGVertexIndexList;
  vertIndices: array [0 .. 5] of Integer;
  pEdge, pTri, p: PChar;
begin
  sl := TStringList.Create;
  try
    sl.LoadFromStream(aStream{$IFDEF Unicode}, TEncoding.ASCII{$ENDIF});
    mesh := TVXMeshObject.CreateOwned(Owner.MeshObjects);
    mesh.Mode := momFaceGroups;
    if sl.Count > 0 then
    begin
      p := PChar(sl[0]);
      nv := ParseInteger(p);
      ne := ParseInteger(p);
      nf := ParseInteger(p);
      if (nv or nf or ne) = 0 then
        Exit;
      for i := 1 to nv do
      begin
        p := PChar(sl[i]);
        mesh.Vertices.Add(ParseFloat(p), ParseFloat(p), ParseFloat(p));
      end;
      fg := TFGVertexIndexList.CreateOwned(mesh.FaceGroups);
      for i := 1 + nv + ne to nv + ne + nf do
      begin
        pTri := PChar(sl[i]);
        for k := 0 to 2 do
        begin
          ei := ParseInteger(pTri);
          pEdge := PChar(sl[nv + ei]);
          vertIndices[k * 2 + 0] := ParseInteger(pEdge);
          vertIndices[k * 2 + 1] := ParseInteger(pEdge);
        end;
        if (vertIndices[0] = vertIndices[2]) or (vertIndices[0] = vertIndices[3])
        then
          fg.VertexIndices.Add(vertIndices[0] - 1)
        else
          fg.VertexIndices.Add(vertIndices[1] - 1);
        if (vertIndices[2] = vertIndices[4]) or (vertIndices[2] = vertIndices[5])
        then
          fg.VertexIndices.Add(vertIndices[2] - 1)
        else
          fg.VertexIndices.Add(vertIndices[3] - 1);
        if (vertIndices[4] = vertIndices[0]) or (vertIndices[4] = vertIndices[1])
        then
          fg.VertexIndices.Add(vertIndices[4] - 1)
        else
          fg.VertexIndices.Add(vertIndices[5] - 1);
      end;
      mesh.BuildNormals(fg.VertexIndices, momTriangles);
    end;
  finally
    sl.Free;
  end;
end;

// ------------------------------------------------------------------
initialization
// ------------------------------------------------------------------

RegisterVectorFileFormat('gts', 'GNU Triangulated Surface', TVXGTSVectorFile);

end.
