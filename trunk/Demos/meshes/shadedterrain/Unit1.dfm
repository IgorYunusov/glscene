object Form1: TForm1
  Left = 187
  Top = 116
  Width = 611
  Height = 434
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GLSceneViewer1: TGLSceneViewer
    Left = 0
    Top = 33
    Width = 603
    Height = 372
    Camera = GLCamera1
    BeforeRender = GLSceneViewer1BeforeRender
    Buffer.FogEnvironment.FogColor.Color = {0000803F0000803F0000803F0000803F}
    Buffer.FogEnvironment.FogStart = 200
    Buffer.FogEnvironment.FogEnd = 650
    Buffer.FogEnvironment.FogDistance = fdEyeRadial
    Buffer.BackgroundColor = clGray
    Buffer.FogEnable = True
    Buffer.Lighting = False
    Align = alClient
    OnMouseDown = GLSceneViewer1MouseDown
    OnMouseMove = GLSceneViewer1MouseMove
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 603
    Height = 33
    Align = alTop
    BevelOuter = bvLowered
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 8
      Width = 113
      Height = 13
      Caption = 'Bumpmap Sub-sampling'
    end
    object LASubFactor: TLabel
      Left = 320
      Top = 8
      Width = 19
      Height = 13
      Caption = 'Sub'
    end
    object TBSubSampling: TTrackBar
      Left = 136
      Top = 0
      Width = 177
      Height = 29
      Max = 3
      Orientation = trHorizontal
      PageSize = 1
      Frequency = 1
      Position = 1
      SelEnd = 0
      SelStart = 0
      TabOrder = 0
      TabStop = False
      ThumbLength = 10
      TickMarks = tmBoth
      TickStyle = tsAuto
      OnChange = TBSubSamplingChange
    end
  end
  object GLBitmapHDS1: TGLBitmapHDS
    MaxPoolSize = 0
    Left = 56
    Top = 56
  end
  object GLScene1: TGLScene
    ObjectsSorting = osNone
    Left = 56
    Top = 96
    object SkyDome1: TGLSkyDome
      Direction.Coordinates = {000000000000803F2EBD3BB300000000}
      Up.Coordinates = {000000002EBD3BB3000080BF00000000}
      Bands = <
        item
          StartAngle = -5
          StartColor.Color = {0000803F0000803F0000803F0000803F}
          StopAngle = 25
          Slices = 9
        end
        item
          StartAngle = 25
          StopAngle = 90
          StopColor.Color = {938C0C3E938C0C3E938E0E3F0000803F}
          Slices = 9
          Stacks = 4
        end>
      Stars = <>
      Options = [sdoTwinkle]
      object SPSun: TGLSprite
        Material.FrontProperties.Ambient.Color = {0000000000000000000000000000803F}
        Material.FrontProperties.Diffuse.Color = {0000000000000000000000000000803F}
        Material.BlendingMode = bmAdditive
        Material.MaterialOptions = [moIgnoreFog]
        Material.Texture.TextureMode = tmReplace
        Material.Texture.TextureFormat = tfLuminance
        Material.Texture.Compression = tcNone
        Material.Texture.Disabled = False
        Position.Coordinates = {00000C430000C842000096420000803F}
        Width = 60
        Height = 60
        NoZWrite = True
        MirrorU = False
        MirrorV = False
      end
    end
    object DummyCube1: TGLDummyCube
      Position.Coordinates = {0000000000000041000000000000803F}
      CubeSize = 1
      object GLCamera1: TGLCamera
        DepthOfView = 650
        FocalLength = 50
        NearPlaneBias = 0.100000001490116
        TargetObject = DummyCube1
        Position.Coordinates = {0000A040000020410000C8410000803F}
        Direction.Coordinates = {0000803F000000000000000000000000}
        Left = 264
        Top = 160
      end
    end
    object TerrainRenderer1: TGLTerrainRenderer
      Material.MaterialLibrary = GLMaterialLibrary1
      Material.LibMaterialName = 'ground'
      Direction.Coordinates = {000000000000803F0000000000000000}
      Scale.Coordinates = {00008040000080400000803E00000000}
      Up.Coordinates = {00000000000000000000803F00000000}
      HeightDataSource = GLBumpmapHDS1
      TileSize = 128
      TilesPerTexture = 1
      CLODPrecision = 30
    end
    object GLLensFlare: TGLLensFlare
      Size = 100
      Seed = 978
      Position.Coordinates = {9A620252C9B28B51B743BAD10000803F}
      Visible = False
      object GLDummyCube1: TGLDummyCube
        CubeSize = 100
        VisibleAtRunTime = True
      end
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 56
    Top = 136
  end
  object GLCadencer1: TGLCadencer
    Scene = GLScene1
    OnProgress = GLCadencer1Progress
    Left = 16
    Top = 56
  end
  object GLMaterialLibrary1: TGLMaterialLibrary
    Materials = <
      item
        Name = 'ground'
        Material.FrontProperties.Ambient.Color = {0000000000000000000000000000803F}
        Material.FrontProperties.Diffuse.Color = {0000000000000000000000000000803F}
        Material.FrontProperties.Emission.Color = {9A99993E9A99993E9A99993E0000803F}
        Material.Texture.TextureMode = tmReplace
        Material.Texture.Compression = tcStandard
        Material.Texture.MappingTCoordinates.Coordinates = {000000000000803F0000000000000000}
        Material.Texture.Disabled = False
        Tag = 0
        Texture2Name = 'details'
      end
      item
        Name = 'details'
        Material.Texture.TextureMode = tmModulate
        Material.Texture.TextureFormat = tfLuminance
        Material.Texture.Compression = tcStandard
        Material.Texture.MappingTCoordinates.Coordinates = {000000000000803F0000000000000000}
        Material.Texture.Disabled = False
        Tag = 0
        TextureScale.Coordinates = {00000042000000420000004200000000}
      end>
    Left = 16
    Top = 96
  end
  object GLTexCombineShader1: TGLTexCombineShader
    Combiners.Strings = (
      'Tex0:=Dot3(Tex0, Col);'
      'Tex1:=Tex0*Tex1;')
    DesignTimeEnabled = False
    Left = 96
    Top = 96
  end
  object GLBumpmapHDS1: TGLBumpmapHDS
    ElevationHDS = GLBitmapHDS1
    BumpmapLibrary = GLMaterialLibrary1
    OnNewTilePrepared = GLBumpmapHDS1NewTilePrepared
    BumpScale = 0.100000001490116
    MaxPoolSize = 0
    Left = 96
    Top = 56
  end
end
