# Hatching Shader <!-- omit from toc -->

Add hatching to your GMod scene

## Table of Contents <!-- omit from toc -->

- [Description](#description)
  - [Features](#features)
  - [Rational](#rational)
  - [Remarks](#remarks)
- [Disclaimer](#disclaimer)
- [Pull Requests](#pull-requests)
- [Credits](#credits)

## Description

|![Preview](/media/hatch-preview.gif)|
|--|
|Hatching shader applied to Kleiner under harsh lighting. Hatch scale: 7.93; Hatch angle: 0; Hatch intensity: 6.00|

This adds a hatching shader. You can find this addon in `Post Process Tab > Shaders > Hatching (vlazed)`

### Features

- **Screenspace hatching**
- **Change scale and angle of hatching**
- **Custom tonal art map support**

> [!WARNING]
> This shader currently writes model uvs to the rendertarget `_rt_UV`. This can cause crashes with high poly models.

### Rational

TODO

### Remarks

This shader is adapted from the following tutorial:

- https://kylehalladay.com/blog/tutorial/2017/02/21/Pencil-Sketch-Effect.html

## Disclaimer

## Pull Requests

When making a pull request, make sure to confine to the style seen throughout. Try to add types for new functions or data structures. I used the default [StyLua](https://github.com/JohnnyMorganz/StyLua) formatting style.

## Credits

- Kyle Halladay: [Pencil Sketch effect](https://kylehalladay.com/blog/tutorial/2017/02/21/Pencil-Sketch-Effect.html)
