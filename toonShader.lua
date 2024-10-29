local outlineTexture = textures:newTexture("outlineTexture",1,1)
outlineTexture:setPixel(0,0,vec(1,1,1))

function setToonShader(part,outlineSize,outlineColor,outlinePushback,glowingOutlines,doOutline,doOutlineShading,doModelShading)
  if not outlineSize  then outlineSize = 0.5 end
  if not outlineColor then outlineColor = vec(1,1,1) end
  if not outlinePushback then outlinePushback = 0 end
  if glowingOutlines == nil then glowingOutlines = false end
  if doOutline == nil then doOutline = true end
  if doOutlineShading == nil then doOutlineShading = false end
  if doModelShading == nil then doModelShading = false end
  if part:getType() == "CUBE" or part:getType() == "MESH" then
    if doOutline then
      local outlineName = part:getName().."Outline"
      part:getParent():addChild(part:copy(outlineName))
      local outline = part:getParent()[outlineName]
      outline:setPrimaryRenderType("CUTOUT_CULL")
      outline:setMatrix(matrices.mat4():scale(vec(-1,-1,-1)):rotate(vec(180,180,0)) * (1 + 0.1 * outlinePushback))
      outline:setColor(outlineColor)
      outline:setPrimaryTexture("CUSTOM",outlineTexture)
      if glowingOutlines then outline:setLight(15) end
      for _,texture in pairs(outline:getAllVertices()) do
        local vertexIndex = {}
        for _,vertex in pairs(texture) do
          local pos = vertex:getPos()
          local ID = tostring(pos)
          local normal = vertex:getNormal()
          if not vertexIndex[ID] then
            vertexIndex[ID] = normal
          else
            vertexIndex[ID] = vertexIndex[ID] + normal
          end
        end
        for _,vertex in pairs(texture) do
          local pos = vertex:getPos()
          local ID = tostring(pos)
          vertex:setPos(pos + vertexIndex[ID]:normalized() * outlineSize)
          if not doOutlineShading then
            vertex:setNormal(vec(0,1,0))
          end
        end
      end
    end
    if not doModelShading then
      for _,texture in pairs(part:getAllVertices()) do
        for _,vertex in pairs(texture) do
          vertex:setNormal(vec(0,1,0))
        end
      end
    end
  end
  for _,child in pairs(part:getChildren()) do
    setToonShader(child,outlineSize,outlineColor,outlinePushback,glowingOutlines,doOutline,doOutlineShading,doModelShading)
  end
end