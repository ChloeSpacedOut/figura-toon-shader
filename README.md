# Toon Shader
A script that accurately re-creates cartoon shaders you can apply to your avatar. Outlines are based on the lighting normals, so it works accurately for meshes. This isn't technically shaders.

## Setup
First, add `toonShader.lua` to your avatar. Once you have, require it with `require("toonShader")`, or add it to your autoscripts in avatar.json.

## Usage
With this done, setup is complete. You can run `setToonShader()` to apply the toon shader to your model part. The function is:

`setToonShader(part,outlineSize,outlineColor,outlinePushback,glowingOutlines,doOutline,doOutlineShading,doModelShading)`

Where:
- `part` is the model part you'll be changing
- `outlineSize` is the size of the cartoon outline, in blockbench cubes
- `outlineColor` is a vec3 containing the color of your outline in RGB
- `outlinePushback` is how far the outline should render behind your avatar
- `glowingOutlines` is a bool for if the outlines should glow
- `doOutline` is a bool for if the outline should be generated
- `doOutlineShading` is a bool for if minecraft shading should be applied to the outline
- `doModelShading` is a bool for if minecraft shading should be applied to the chosen model parts

For example:
```lua
setToonShader(models.model.root.ToonHat,0.5,vec(0,0,0),false,true,false,false)
```
The function will also accept `nil` values, and resort to default if you leave them empty (except for the model).
For example:
```lua
setToonShader(models.model.root.ToonHat,nil,vec(0,0,0))
```

## Notes
This function is destructive. Once it has run, it can't be undone unless you reload, as it changes the lighting normals of your model's vertices. 

For the host, render calculations will be done to make `outlinePushback` not buggy in the paper doll and menus. This is pretty cheap, and will only run when needed.

Calculations will also be done to fix the lighting for first person arms using toon shading. This can be expensive for more complex models. You can toggle this by changing the value of `doFirstPersonCorrect` at the top of `toonShader.lua`. It's set to true by default.

The outline may clip into the ground. To fix this, you may need to move your model upwards. Clipping from `outlinePushback` may be unavoidable.
