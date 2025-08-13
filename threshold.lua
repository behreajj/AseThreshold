---Used by HSI.
---@param r8 integer red 8 bit integer
---@param g8 integer green 8 bit integer
---@param b8 integer blue 8 bit integer
---@return integer
---@nodiscard
local function evalAverage(r8, g8, b8)
    return (r8 + g8 + b8) // 3
end

---@param r8 integer red 8 bit integer
---@param g8 integer green 8 bit integer
---@param b8 integer blue 8 bit integer
---@return integer
---@nodiscard
local function evalLum(r8, g8, b8)
    return (r8 * 30 + g8 * 59 + b8 * 11) // 100
end

---Used by HSV.
---@param r8 integer red 8 bit integer
---@param g8 integer green 8 bit integer
---@param b8 integer blue 8 bit integer
---@return integer
---@nodiscard
local function evalMax(r8, g8, b8)
    return math.max(r8, g8, b8)
end

---Used by HSL.
---@param r8 integer red 8 bit integer
---@param g8 integer green 8 bit integer
---@param b8 integer blue 8 bit integer
---@return integer
---@nodiscard
local function evalMidRange(r8, g8, b8)
    return (math.max(r8, g8, b8)
        + math.min(r8, g8, b8)) // 2
end

---@param layer Layer parent layer
---@param array Layer[] leaves array
---@return Layer[]
local function appendLeaves(layer, array)
    if layer.isEditable and layer.isVisible then
        if layer.isGroup then
            local childLayers <const> = layer.layers
            if childLayers then
                local lenChildLayers <const> = #childLayers
                local i = 0
                while i < lenChildLayers do
                    i = i + 1
                    appendLeaves(childLayers[i], array)
                end
            end
        elseif (not layer.isReference)
            and (not layer.isTilemap) then
            array[#array + 1] = layer
        end
    end
    return array
end

local dlg <const> = Dialog { title = "Threshold" }

dlg:combobox {
    id = "frameTarget",
    label = "Frames:",
    option = "ACTIVE",
    options = { "ACTIVE", "ALL", "RANGE", },
    hexpand = false,
}

dlg:newrow { always = false }

dlg:combobox {
    id = "layerTarget",
    label = "Layers:",
    option = "ACTIVE",
    options = { "ACTIVE", "ALL", "RANGE", },
    hexpand = false,
}

dlg:newrow { always = false }

dlg:color {
    id = "darkColor",
    label = "Colors:",
    color = Color { r = 32, g = 32, b = 40, a = 255 },
    focus = false,
}

dlg:color {
    id = "lightColor",
    color = Color { r = 255, g = 247, b = 213, a = 255 },
    focus = false,
}

dlg:newrow { always = false }

dlg:combobox {
    id = "evalFuncPreset",
    label = "Value:",
    option = "LUMINANCE",
    options = { "AVERAGE", "LUMINANCE", "MAX", "MID_RANGE", },
    hexpand = false,
}

dlg:newrow { always = false }

dlg:combobox {
    id = "method",
    label = "Method:",
    option = "SAUVOLA",
    options = { "GLOBAL", "PHANSALKAR", "SAUVOLA" },
    hexpand = false,
    onchange = function()
        local args <const> = dlg.data
        local method <const> = args.method --[[@as string]]

        local isGlobal <const> = method == "GLOBAL"
        local isPhansalkar <const> = method == "PHANSALKAR"
        local isSauvola <const> = method == "SAUVOLA"
        local isLocal = isPhansalkar or isSauvola

        dlg:modify { id = "globalThreshold", visible = isGlobal }
        dlg:modify { id = "step", visible = isLocal }

        dlg:modify { id = "rArgSauvola", visible = isSauvola }
        dlg:modify { id = "kArgSauvola", visible = isSauvola }

        dlg:modify { id = "rArgPhansalkar", visible = isPhansalkar }
        dlg:modify { id = "kArgPhansalkar", visible = isPhansalkar }
        dlg:modify { id = "qArgPhansalkar", visible = isPhansalkar }
        dlg:modify { id = "pArgPhansalkar", visible = isPhansalkar }
    end
}

dlg:slider {
    id = "globalThreshold",
    label = "Threshold:",
    min = 0,
    max = 255,
    value = 128,
    visible = false,
}

dlg:newrow { always = false }

dlg:slider {
    id = "step",
    label = "Step:",
    min = 1,
    max = 10,
    value = 2,
    visible = true,
}

dlg:newrow { always = false }

dlg:slider {
    id = "rArgPhansalkar",
    label = "R:",
    min = 0,
    max = 255,
    value = 128,
    visible = false,
}

dlg:newrow { always = false }

dlg:slider {
    id = "kArgPhansalkar",
    label = "K:",
    min = 20,
    max = 50,
    value = 25,
    visible = false,
}

dlg:newrow { always = false }

dlg:slider {
    id = "qArgPhansalkar",
    label = "Q:",
    min = 0,
    max = 50,
    value = 10,
    visible = false,
}

dlg:newrow { always = false }

dlg:slider {
    id = "pArgPhansalkar",
    label = "P:",
    min = 0,
    max = 50,
    value = 3,
    visible = false,
}

dlg:newrow { always = false }

dlg:slider {
    id = "rArgSauvola",
    label = "R:",
    min = 0,
    max = 255,
    value = 128,
    visible = true,
}

dlg:newrow { always = false }

dlg:slider {
    id = "kArgSauvola",
    label = "K:",
    min = 20,
    max = 50,
    value = 50,
    visible = true,
}

dlg:newrow { always = false }

dlg:check {
    id = "printElapsed",
    label = "Print:",
    text = "Elapsed",
    selected = false,
    focus = false,
    hexpand = false,
}

dlg:button {
    id = "confirmButton",
    text = "&OK",
    focus = true,
    onclick = function()
        local startTime <const> = os.clock()

        local activeSprite <const> = app.sprite
        if not activeSprite then
            app.alert {
                title = "Error",
                text = "There is no active sprite."
            }
            return
        end

        local spriteSpec <const> = activeSprite.spec
        local colorMode <const> = spriteSpec.colorMode
        if colorMode ~= ColorMode.RGB then
            app.alert {
                title = "Error",
                text = "Only RGB color mode is supported."
            }
            return
        end

        -- Cache methods to local.
        local exp <const> = math.exp
        local floor <const> = math.floor
        local sqrt <const> = math.sqrt
        local strbyte <const> = string.byte
        local strchar <const> = string.char
        local strfmt <const> = string.format
        local tconcat <const> = table.concat
        local transact <const> = app.transaction

        -- Unpack arguments.
        local args <const> = dlg.data
        local printElapsed <const> = args.printElapsed --[[@as boolean]]
        local frameTarget <const> = args.frameTarget
            or "ACTIVE" --[[@as string]]
        local layerTarget <const> = args.layerTarget
            or "ACTIVE" --[[@as string]]
        local evalFuncPreset <const> = args.evalFuncPreset
            or "LUMINANCE" --[[@as string]]
        local darkColor <const> = args.darkColor --[[@as Color]]
        local lightColor <const> = args.lightColor --[[@as Color]]
        local method <const> = args.method
            or "SAUVOLA" --[[@as string]]
        local kernelStep <const> = args.step
            or 2 --[[@as integer]]

        -- Arguments specific to the global algorithm.
        local globalThreshold <const> = args.globalThreshold
            or 128 --[[@as integer]]

        -- Arguments specific to the Sauvola algorithm.
        local rSauvola <const> = args.rArgSauvola
            or 128 --[[@as integer]]
        local kSauvola <const> = 0.01 * (args.kArgSauvola
            or 50 --[[@as integer]])

        -- Arguments specific to the Phansalkar algorithm.
        local rPhan <const> = args.rArgPhansalkar
            or 128 --[[@as integer]]
        local kPhan <const> = 0.01 * (args.kArgPhansalkar
            or 25 --[[@as integer]])
        local qPhan <const> = args.qArgPhansalkar
            or 10 --[[@as integer]]
        local pPhan <const> = 0.1 * (args.pArgPhansalkar
            or 30 --[[@as integer]])

        local isSauvola <const> = method == "SAUVOLA"
        local isPhansalkar <const> = method == "PHANSALKAR"
        local rInvSauvola <const> = rSauvola ~= 0.0
            and 1.0 / rSauvola
            or 0.0
        local rInvPhan <const> = rPhan ~= 0.0
            and 1.0 / rPhan
            or 0.0

        ---@type integer[]
        local chosenFrIdcs <const> = {}
        if frameTarget == "ALL" then
            local spriteFrames <const> = activeSprite.frames
            local lenSpriteFrames <const> = #spriteFrames
            local i = 0
            while i < lenSpriteFrames do
                i = i + 1
                chosenFrIdcs[i] = i
            end
        elseif frameTarget == "RANGE" then
            local range <const> = app.range
            if range.sprite == activeSprite then
                local rangeFrames <const> = range.frames
                local lenRangeFrames <const> = #rangeFrames
                local i = 0
                while i < lenRangeFrames do
                    i = i + 1
                    chosenFrIdcs[i] = rangeFrames[i].frameNumber
                end
            end
        else
            --Default to active frame.
            local activeFrame <const> = app.frame
            if activeFrame then
                chosenFrIdcs[1] = activeFrame.frameNumber
            else
                chosenFrIdcs[1] = 1
            end
        end

        local lenChosenFrIdcs <const> = #chosenFrIdcs
        if lenChosenFrIdcs <= 0 then
            app.alert {
                title = "Error",
                text = "No frames were selected."
            }
            return
        end

        ---@type Layer[]
        local chosenLayers <const> = {}
        if layerTarget == "ALL" then
            local spriteLayers <const> = activeSprite.layers
            local lenSpriteLayers <const> = #spriteLayers
            local i = 0
            while i < lenSpriteLayers do
                i = i + 1
                appendLeaves(spriteLayers[i], chosenLayers)
            end
        elseif layerTarget == "RANGE" then
            local range <const> = app.range
            if range.sprite == activeSprite then
                local rangeLayers <const> = range.layers
                local lenRangeLayers <const> = #rangeLayers
                local i = 0
                while i < lenRangeLayers do
                    i = i + 1
                    local rangeLayer <const> = rangeLayers[i]
                    if rangeLayer.isEditable
                        and rangeLayer.isVisible
                        and (not rangeLayer.isGroup)
                        and (not rangeLayer.isReference)
                        and (not rangeLayer.isTilemap) then
                        chosenLayers[#chosenLayers + 1] = rangeLayer
                    end
                end
            end
        else
            -- Default to active layer.
            local activeLayer <const> = app.layer
            if activeLayer then
                appendLeaves(activeLayer, chosenLayers)
            end
        end

        local lenChosenLayers <const> = #chosenLayers
        if lenChosenLayers <= 0 then
            app.alert {
                title = "Error",
                text = "No visible, unlocked image layers were chosen."
            }
            return
        end

        ---Linked cels may mean duplicate images, so only work
        ---with unique cels according to image id.
        ---@type table<integer, Cel>
        local chosenCels <const> = {}
        local lenChosenCels = 0
        local lenChosenElements <const> = lenChosenFrIdcs * lenChosenLayers
        local h = 0
        while h < lenChosenElements do
            local m <const> = h // lenChosenLayers
            local n <const> = h % lenChosenLayers
            local frIdx <const> = chosenFrIdcs[1 + m]
            local layer <const> = chosenLayers[1 + n]
            local cel <const> = layer:cel(frIdx)
            if cel then
                lenChosenCels = lenChosenCels + 1
                chosenCels[cel.image.id] = cel
            end
            h = h + 1
        end

        -- Choose evaluation function based on preset.
        local evalFunc = evalLum
        if evalFuncPreset == "HSI"
            or evalFuncPreset == "AVERAGE"
            or evalFuncPreset == "MEAN" then
            evalFunc = evalAverage
        elseif evalFuncPreset == "HSL"
            or evalFuncPreset == "MID_RANGE" then
            evalFunc = evalMidRange
        elseif evalFuncPreset == "HSV"
            or evalFuncPreset == "MAX" then
            evalFunc = evalMax
        end

        -- Unpack colors to 8 bit channels.
        local rDark <const> = darkColor.red
        local gDark <const> = darkColor.green
        local bDark <const> = darkColor.blue

        local rLight <const> = lightColor.red
        local gLight <const> = lightColor.green
        local bLight <const> = lightColor.blue

        ---@type integer[]
        local values <const> = {}
        local wKernel <const> = kernelStep * 2 + 1
        local hKernel <const> = wKernel
        local areaKernel <const> = wKernel * hKernel

        for _, cel in pairs(chosenCels) do
            local srcImg <const> = cel.image
            local srcImgSpec <const> = srcImg.spec
            local srcBytes <const> = srcImg.bytes
            local wSrc <const> = srcImgSpec.width
            local hSrc <const> = srcImgSpec.height
            local areaSrcImg <const> = wSrc * hSrc

            ---@type string[]
            local trgByteArr <const> = {}

            if isSauvola then
                local i = 0
                while i < areaSrcImg do
                    local i4 <const> = i * 4
                    local rSrc <const>,
                    gSrc <const>,
                    bSrc <const>,
                    aSrc <const> = strbyte(srcBytes, 1 + i4, 4 + i4)

                    local rTrg, gTrg, bTrg, aTrg = 0, 0, 0, 0

                    if aSrc > 0 then
                        local xSrc <const> = i % wSrc
                        local ySrc <const> = i // wSrc

                        local validCount = 0
                        local sumValue = 0

                        local j = 0
                        while j < areaKernel do
                            local xKrn <const> = j % wKernel
                            local yKrn <const> = j // wKernel
                            local xNbr <const> = xSrc + xKrn - kernelStep
                            local yNbr <const> = ySrc + yKrn - kernelStep

                            -- if xNeighbor ~= xSrc or yNeighbor ~= ySrc then
                            local rNbr, gNbr, bNbr, aNbr = 0, 0, 0, 0
                            if yNbr >= 0
                                and yNbr < hSrc
                                and xNbr >= 0
                                and xNbr < wSrc then
                                local address <const> = (yNbr * wSrc + xNbr) * 4
                                rNbr, gNbr, bNbr, aNbr = strbyte(srcBytes, 1 + address, 4 + address)
                            end

                            if aNbr > 0 then
                                local nbrValue <const> = evalFunc(rNbr, gNbr, bNbr)
                                sumValue = sumValue + nbrValue
                                validCount = validCount + 1
                                values[validCount] = nbrValue
                            end
                            -- end

                            j = j + 1
                        end

                        local meanValue <const> = validCount > 0
                            and sumValue / validCount
                            or 0.0

                        local deltaSum = 0
                        local m = 0
                        while m < validCount do
                            m = m + 1
                            local value <const> = values[m]
                            local delta <const> = value - meanValue
                            local sqDelta <const> = delta * delta
                            deltaSum = deltaSum + sqDelta
                        end

                        local stdDev <const> = validCount > 1
                            and sqrt(deltaSum / (validCount - 1))
                            or 0.0

                        local pivot <const> = meanValue * (1.0 + kSauvola * (stdDev * rInvSauvola - 1.0))
                        local srcValue <const> = evalFunc(rSrc, gSrc, bSrc)

                        aTrg = aSrc
                        if srcValue < pivot then
                            rTrg, gTrg, bTrg = rDark, gDark, bDark
                        else
                            rTrg, gTrg, bTrg = rLight, gLight, bLight
                        end
                    end

                    i = i + 1
                    trgByteArr[i] = strchar(rTrg, gTrg, bTrg, aTrg)
                end -- End Sauvola loop.
            elseif isPhansalkar then
                local i = 0
                while i < areaSrcImg do
                    local i4 <const> = i * 4
                    local rSrc <const>,
                    gSrc <const>,
                    bSrc <const>,
                    aSrc <const> = strbyte(srcBytes, 1 + i4, 4 + i4)

                    local rTrg, gTrg, bTrg, aTrg = 0, 0, 0, 0

                    if aSrc > 0 then
                        local xSrc <const> = i % wSrc
                        local ySrc <const> = i // wSrc

                        local validCount = 0
                        local sumValue = 0

                        local j = 0
                        while j < areaKernel do
                            local xKrn <const> = j % wKernel
                            local yKrn <const> = j // wKernel
                            local xNbr <const> = xSrc + xKrn - kernelStep
                            local yNbr <const> = ySrc + yKrn - kernelStep

                            -- if xNeighbor ~= xSrc or yNeighbor ~= ySrc then
                            local rNbr, gNbr, bNbr, aNbr = 0, 0, 0, 0
                            if yNbr >= 0
                                and yNbr < hSrc
                                and xNbr >= 0
                                and xNbr < wSrc then
                                local address <const> = (yNbr * wSrc + xNbr) * 4
                                rNbr, gNbr, bNbr, aNbr = strbyte(srcBytes, 1 + address, 4 + address)
                            end

                            if aNbr > 0 then
                                local nbrValue <const> = evalFunc(rNbr, gNbr, bNbr)
                                sumValue = sumValue + nbrValue
                                validCount = validCount + 1
                                values[validCount] = nbrValue
                            end
                            -- end

                            j = j + 1
                        end

                        local meanValue <const> = validCount > 0
                            and sumValue / validCount
                            or 0.0

                        local deltaSum = 0
                        local m = 0
                        while m < validCount do
                            m = m + 1
                            local value <const> = values[m]
                            local delta <const> = value - meanValue
                            local sqDelta <const> = delta * delta
                            deltaSum = deltaSum + sqDelta
                        end

                        local stdDev <const> = validCount > 1
                            and sqrt(deltaSum / (validCount - 1))
                            or 0.0

                        local ph <const> = pPhan * exp(-qPhan * meanValue)
                        local pivot <const> = floor(0.5 + meanValue * (1.0 + ph + kPhan * (stdDev * rInvPhan - 1.0)))
                        local srcValue <const> = evalFunc(rSrc, gSrc, bSrc)

                        aTrg = aSrc
                        if srcValue < pivot then
                            rTrg, gTrg, bTrg = rDark, gDark, bDark
                        else
                            rTrg, gTrg, bTrg = rLight, gLight, bLight
                        end
                    end

                    i = i + 1
                    trgByteArr[i] = strchar(rTrg, gTrg, bTrg, aTrg)
                end -- End Phansalkar loop.
            else
                -- Default to global.
                local i = 0
                while i < areaSrcImg do
                    local i4 <const> = i * 4
                    local rSrc <const>,
                    gSrc <const>,
                    bSrc <const>,
                    aSrc <const> = strbyte(srcBytes, 1 + i4, 4 + i4)

                    local rTrg, gTrg, bTrg, aTrg = 0, 0, 0, 0

                    if aSrc > 0 then
                        aTrg = aSrc
                        local srcValue <const> = evalFunc(rSrc, gSrc, bSrc)
                        if srcValue < globalThreshold then
                            rTrg, gTrg, bTrg = rDark, gDark, bDark
                        else
                            rTrg, gTrg, bTrg = rLight, gLight, bLight
                        end
                    end

                    i = i + 1
                    trgByteArr[i] = strchar(rTrg, gTrg, bTrg, aTrg)
                end -- End global loop.
            end     -- End method block.

            local trgImg <const> = Image(srcImgSpec)
            trgImg.bytes = tconcat(trgByteArr)
            transact(strfmt(
                "Threshold %03d on \"%s\"",
                cel.frame.frameNumber, cel.layer.name), function()
                cel.image = trgImg
            end)
        end -- End chosen cels loop.

        app.refresh()

        -- Show elapsed information.
        if printElapsed then
            local endTime <const> = os.clock()
            local elapsedTime <const> = endTime - startTime
            app.alert {
                title = "Time",
                text = {
                    string.format("Start: %.4f", startTime),
                    string.format("End: %.4f", endTime),
                    string.format("Elapsed: %.4f", elapsedTime),
                }
            }
        end
    end
}

dlg:button { id = "cancelButton", text = "&CANCEL", focus = false, }

dlg:show { wait = false }