object Form1: TForm1
  Left = 170
  Top = 57
  Width = 482
  Height = 493
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object GLSceneViewer: TGLSceneViewer
    Left = 0
    Top = 0
    Width = 474
    Height = 464
    Camera = GLCamera
    Buffer.BackgroundColor = clBlack
    FieldOfView = 155.675598144531
    Align = alClient
  end
  object GLScene: TGLScene
    Left = 16
    Top = 8
    object DCFire1: TGLDummyCube
      Position.Coordinates = {000040C000000000000000000000803F}
      CubeSize = 1
      EffectsData = {
        0202061254474C536F7572636550465845666665637402010608466C616D6550
        4658050000000000000080FF3F0206020008020008020008050000000000CDCC
        CCFC3F050000000000CDCCCCFB3F0500000000000AD7A3F83F02000200090500
        000000000000000000080200020002010608536D6F6B65504658050000000000
        000080FF3F0206020008020008020008050000000000CDCCCCFC3F0500000000
        00CDCCCCFB3F0500000000000AD7A3F83F020002000905000000000000000000
        00080200}
    end
    object DCFire2: TGLDummyCube
      CubeSize = 1
      EffectsData = {
        0202061254474C536F7572636550465845666665637402010608466C616D6550
        4658050000000000000080FF3F0206020008020008020008050000000000CDCC
        CCFC3F050000000000CDCCCCFB3F0500000000000AD7A3F83F02000200090500
        000000000000000000080200020002010608536D6F6B65504658050000000000
        000080FF3F0206020008020008020008050000000000CDCCCCFC3F0500000000
        00CDCCCCFB3F0500000000000AD7A3F83F020002000905000000000000000000
        00080200}
    end
    object DCFire3: TGLDummyCube
      Position.Coordinates = {0000404000000000000000000000803F}
      CubeSize = 1
      EffectsData = {
        0202061254474C536F7572636550465845666665637402010608466C616D6550
        4658050000000000000080FF3F0206020008020008020008050000000000CDCC
        CCFC3F050000000000CDCCCCFB3F0500000000000AD7A3F83F02000200090500
        000000000000000000080200020002010608536D6F6B65504658050000000000
        000080FF3F0206020008020008020008050000000000CDCCCCFC3F0500000000
        00CDCCCCFB3F0500000000000AD7A3F83F020002000905000000000000000000
        00080200}
    end
    object DCFire4: TGLDummyCube
      Position.Coordinates = {0000000000000000000040400000803F}
      CubeSize = 1
      EffectsData = {
        0202061254474C536F7572636550465845666665637402010608466C616D6550
        4658050000000000000080FF3F0206020008020008020008050000000000CDCC
        CCFC3F050000000000CDCCCCFB3F0500000000000AD7A3F83F02000200090500
        000000000000000000080200020002010608536D6F6B65504658050000000000
        000080FF3F0206020008020008020008050000000000CDCCCCFC3F0500000000
        00CDCCCCFB3F0500000000000AD7A3F83F020002000905000000000000000000
        00080200}
    end
    object DCFire5: TGLDummyCube
      Position.Coordinates = {0000000000000000000040C00000803F}
      CubeSize = 1
      EffectsData = {
        0202061254474C536F7572636550465845666665637402010608466C616D6550
        4658050000000000000080FF3F0206020008020008020008050000000000CDCC
        CCFC3F050000000000CDCCCCFB3F0500000000000AD7A3F83F02000200090500
        000000000000000000080200020002010608536D6F6B65504658050000000000
        000080FF3F0206020008020008020008050000000000CDCCCCFC3F0500000000
        00CDCCCCFB3F0500000000000AD7A3F83F020002000905000000000000000000
        00080200}
    end
    object ParticleFXRenderer: TGLParticleFXRenderer
      BlendingMode = bmTransparency
    end
    object DCTarget: TGLDummyCube
      Position.Coordinates = {0000000000000040000000000000803F}
      CubeSize = 1
    end
    object GLCamera: TGLCamera
      DepthOfView = 100
      FocalLength = 50
      TargetObject = DCTarget
      Position.Coordinates = {00004040000040400000A0400000803F}
    end
  end
  object SmokePFX: TGLPerlinPFXManager
    Cadencer = GLCadencer
    Renderer = ParticleFXRenderer
    Acceleration.Coordinates = {000000000000803F0000000000000000}
    Friction = 1
    BlendingMode = bmTransparency
    Smoothness = 1
    Brightness = 1
    Gamma = 1
    ParticleSize = 0.5
    ColorInner.Color = {0000803F0000803F0000803F00000000}
    ColorOuter.Color = {0000803F0000803F0000803F00000000}
    LifeColors = <
      item
        ColorInner.Color = {0000803F0000803F0000803F00000000}
        ColorOuter.Color = {0000803F0000803F0000803F00000000}
        LifeTime = 0.75
        SizeScale = 1
      end
      item
        ColorInner.Color = {0000803F0000803F0000803F9A99993E}
        ColorOuter.Color = {0000803F0000803F0000803F00000000}
        LifeTime = 3
        SizeScale = 2
      end
      item
        ColorInner.Color = {0000803F0000803F0000803F00000000}
        ColorOuter.Color = {0000803F0000803F0000803F00000000}
        LifeTime = 5
        SizeScale = 3
      end>
    Left = 56
    Top = 8
  end
  object FlamePFX: TGLCustomSpritePFXManager
    Cadencer = GLCadencer
    Renderer = ParticleFXRenderer
    Acceleration.Coordinates = {000000000000803F0000000000000000}
    Friction = 1
    ShareSprites = SmokePFX
    ParticleSize = 0.200000002980232
    ColorInner.Color = {0000803F0000803F000000000000003F}
    ColorOuter.Color = {0000803F0000803F0000000000000000}
    LifeColors = <
      item
        ColorInner.Color = {0000803F0000803F0000000000000000}
        ColorOuter.Color = {0000803F000000000000000000000000}
        LifeTime = 2
        SizeScale = 1
      end>
    Left = 56
    Top = 48
  end
  object GLCadencer: TGLCadencer
    Scene = GLScene
    OnProgress = GLCadencerProgress
    Left = 16
    Top = 48
  end
  object Timer: TTimer
    OnTimer = TimerTimer
    Left = 104
    Top = 8
  end
end
