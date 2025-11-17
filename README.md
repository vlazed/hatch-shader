# Hatching Shader <!-- omit from toc -->

Add hatching to your GMod scene

## Table of Contents <!-- omit from toc -->

- [Description](#description)
  - [Features](#features)
  - [Requirements](#requirements)
  - [Rational](#rational)
  - [Remarks](#remarks)
- [Disclaimer](#disclaimer)
- [Pull Requests](#pull-requests)
- [Credits](#credits)

## Description

|![Preview](/media/hatch-preview.gif)|![Preview](/media/hatch-world-preview.png)|
|--|--|
|Hatching shader applied to Kleiner under harsh lighting. Hatch scale: 7.93; Hatch angle: 0; Hatch intensity: 6.00|Hatching shader applied to the world. UV world scale: 0.03125; Hatch color: (171, 290, 255, 255)|

This adds a hatching shader. You can find this addon in `Post Process Tab > Shaders > Hatching (vlazed)`

### Features

- **Screenspace hatching**: Hatches are applied on the frame
- **Change color, scale, angle, and intensity of hatching**: Customize your hatches to fit your scene
- **Custom tonal art map support**: Author your own tonal art maps and use them to hatch the world your way

> [!WARNING]
> This shader currently writes model uvs to the rendertarget `_rt_UV`. This can cause crashes with high poly models.

> [!NOTE]
> Due to the nature of `screenspace_general`, this shader uses `$softwareskin 1` and `$translucent 1` for models. Thus, hatching may render strangely with models, especially those with facial flexing.

### Requirements

- [GShader Library](https://steamcommunity.com/sharedfiles/filedetails/?id=3542644649) for _rt_NormalsTangents and _rt_WorldPos buffers. Both are critical for world UVs

### Rational

The existing texturize shaders allow one to mimic a sketching style. However, texturize is applied to the screen. It does not respect the shape of the subject in terms of shading. The hatching shader uses a UV buffer to "wrap" the pencil sketching effect around the model.

### Remarks

This shader is adapted from the following tutorial:

- https://kylehalladay.com/blog/tutorial/2017/02/21/Pencil-Sketch-Effect.html

## Disclaimer

## Pull Requests

When making a pull request, make sure to confine to the style seen throughout. Try to add types for new functions or data structures. I used the default [StyLua](https://github.com/JohnnyMorganz/StyLua) formatting style.

## Credits

- Kyle Halladay: [Pencil Sketch effect](https://kylehalladay.com/blog/tutorial/2017/02/21/Pencil-Sketch-Effect.html)
