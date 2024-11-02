local doFirstPersonCorrect = true -- this costs render instructions for the host, may cause lag in larger models

local outlineTexture = textures:newTexture("outlineTexture",1,1)
outlineTexture:setPixel(0,0,vec(1,1,1))

local parts = {}
local matrixUpdateParts = {}

function setToonShader(part,outlineSize,outlineColor,outlinePushback,glowingOutlines,doOutline,doOutlineShading,doModelShading)
  if not outlineSize  then outlineSize = 0.5 end
  if not outlineColor then outlineColor = vec(1,1,1) end
  if not outlinePushback then outlinePushback = 0 end
  if glowingOutlines == nil then glowingOutlines = false end
  if doOutline == nil then doOutline = true end
  if doOutlineShading == nil then doOutlineShading = false end
  if doModelShading == nil then doModelShading = false end
  table.insert(parts,part)
  if part:getType() == "CUBE" or part:getType() == "MESH" then
    if doOutline then
      local outlineName = part:getName().."Outline"
      part:getParent():addChild(part:copy(outlineName))
      local outline = part:getParent()[outlineName]
      if outlinePushback ~= 0 then
        table.insert(matrixUpdateParts,{part = outline, pushBack = outlinePushback})
      end
      outline:setPrimaryRenderType("CUTOUT_CULL")
      local pivot = outline:getPivot()
      local rot =outline:getRot()
      outline:setMatrix(matrices.mat4() * (1 + 0.1 * outlinePushback))
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
        for key,vertex in pairs(texture) do
          local pos = vertex:getPos()
          local vertexID = (key - 1) % 4
          if vertexID < 2 then
            vertexID = math.abs(vertexID - 1)
            local nextPart = texture[key + vertexID*2 + 1]
            vertex:setPos(nextPart:getPos())
            nextPart:setPos(pos)
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

local wasLastFirstPerson = false
if host:isHost() then
  function events.render(delta,context)
    if context == "RENDER" then
      for _,v in pairs(matrixUpdateParts) do
        v.part:setMatrix(matrices.mat4() * (1 + 0.1 * v.pushBack))
      end
    else
      for _,v in pairs(matrixUpdateParts) do
        v.part:setMatrix(matrices.mat4())
      end
    end
    if doFirstPersonCorrect then
      if context == "FIRST_PERSON" then
        local isLookingDown
        if player:getRot().x > 37.5 then
          isLookingDown = true
        else
          isLookingDown = false
        end
        for _,part in pairs(parts) do
          for _,texture in pairs(part:getAllVertices()) do
            for _,vertex in pairs(texture) do
              if isLookingDown then
                vertex:setNormal(vec(1,1,0))
              else
                vertex:setNormal(vec(1,-1,0))
              end
              wasLastFirstPerson = true
            end
          end
        end
      elseif wasLastFirstPerson then
        for _,part in pairs(parts) do
          for _,texture in pairs(part:getAllVertices()) do
            for _,vertex in pairs(texture) do
              vertex:setNormal(vec(0,1,0))
              wasLastFirstPerson = false
            end
          end
        end
      end
    end
  end
end