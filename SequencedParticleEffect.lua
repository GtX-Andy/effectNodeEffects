--[[
Copyright (C) GtX (Andy), 2022

Author: GtX | Andy
Date: 14.02.2022
Revision: FS22-02

Contact:
https://forum.giants-software.com
https://github.com/GtX-Andy

Important:
Free for use in mods (FS22 Only) - no permission needed.
No modifications may be made to this script, including conversion to other game versions without written permission from GtX | Andy
Copying or removing any part of this code for external use without written permission from GtX | Andy is prohibited.

Frei verwendbar (Nur LS22) - keine erlaubnis nötig
Ohne schriftliche Genehmigung von GtX | Andy dürfen keine Änderungen an diesem Skript vorgenommen werden, einschließlich der Konvertierung in andere Spielversionen
Das Kopieren oder Entfernen irgendeines Teils dieses Codes zur externen Verwendung ohne schriftliche Genehmigung von GtX | Andy ist verboten.
]]

SequencedParticleEffect = {}

local modName = g_currentModName or ""
local modDirectory = g_currentModDirectory or ""

local customClassName = modName .. ".SequencedParticleEffect"
local SequencedParticleEffect_mt = Class(SequencedParticleEffect, ParticleEffect)

function SequencedParticleEffect.new(customMt)
    local self = ParticleEffect.new(customMt or SequencedParticleEffect_mt)

    self.sequenceOnTime = 0
    self.sequenceOffTime = 0

    self.useSequenceTimes = false
    self.currentSequenceTime = 0

    self.effectEnabled = false
    self.isCustomEffect = false

    return self
end

function SequencedParticleEffect:loadEffectAttributes(xmlFile, key, node, i3dNode, i3dMapping)
    if not SequencedParticleEffect:superClass().loadEffectAttributes(self, xmlFile, key, node, i3dNode, i3dMapping) then
        return false
    end

    self.sequenceOnTime = (Effect.getValue(xmlFile, key, node, "sequenceOnTime", 0) or 0) * 1000
    self.sequenceOffTime = (Effect.getValue(xmlFile, key, node, "sequenceOffTime", 0) or 0) * 1000

    self.useSequenceTimes = self.sequenceOnTime > 0 and self.sequenceOffTime > 0

    -- Allow direct I3D particle effect loading, superClass handles delete
    local filename = Effect.getValue(xmlFile, key, node, "file")

    if filename ~= nil then
        local baseDirectory = modDirectory

        if self.baseDirectory ~= nil and self.baseDirectory ~= "" then
            baseDirectory = self.baseDirectory
        end

        filename = Utils.getFilename(filename, baseDirectory)

        local callOnCreate = Utils.getNoNil(Effect.getValue(xmlFile, key, node, "callOnCreate"), false)
        local i3dRootNode, failedReason = loadI3DFile(filename, true, callOnCreate, false)

        if i3dRootNode ~= nil and i3dRootNode ~= 0 then
            local rootNode = i3dRootNode

            local particleNode = Effect.getValue(xmlFile, key, node, "particleNode", nil, i3dRootNode, nil)

            if particleNode ~= nil then
                rootNode = particleNode
            else
                rootNode = getChildAt(i3dRootNode, 0)
            end

            link(self.node, rootNode)

            local particleSystem = {
                useEmitterVisibility = Utils.getNoNil(Effect.getValue(xmlFile, key, node, "useEmitterVisibility"), false),
                forceFullLifespan = Utils.getNoNil(Effect.getValue(xmlFile, key, node, "forceFullLifespan"), false),
                isValid = false
            }

            ParticleUtil.loadParticleSystemFromNode(rootNode, particleSystem, false, self.worldSpace, particleSystem.forceFullLifespan, filename)

            if particleSystem.isValid then
                ParticleUtil.setParticleStartStopTime(particleSystem, self.startTime, self.stopTime)

                if self.lifespan ~= nil then
                    ParticleUtil.setParticleLifespan(particleSystem, self.lifespan * 1000)
                    particleSystem.originalLifespan = self.lifespan * 1000
                end

                if self.spriteScale ~= 1 then
                    local originalSpriteScaleX = ParticleUtil.getParticleSystemSpriteScaleX(particleSystem)
                    ParticleUtil.setParticleSystemSpriteScaleX(particleSystem, originalSpriteScaleX * self.spriteScale)

                    local originalSpriteScaleY = ParticleUtil.getParticleSystemSpriteScaleY(particleSystem)
                    ParticleUtil.setParticleSystemSpriteScaleY(particleSystem, originalSpriteScaleY * self.spriteScale)
                end

                if self.spriteGainScale ~= 1 then
                    local originalSpriteGainScaleX = ParticleUtil.getParticleSystemSpriteScaleXGain(particleSystem)
                    ParticleUtil.setParticleSystemSpriteScaleXGain(particleSystem, originalSpriteGainScaleX * self.spriteGainScale)

                    local originalSpriteGainScaleY = ParticleUtil.getParticleSystemSpriteScaleYGain(particleSystem)
                    ParticleUtil.setParticleSystemSpriteScaleYGain(particleSystem, originalSpriteGainScaleY * self.spriteGainScale)
                end

                self.emitterShape = particleSystem.emitterShape
                self.particleSystem = particleSystem

                self.isCustomEffect = true
            end

            if rootNode ~= i3dRootNode then
                delete(i3dRootNode)
            end
        elseif failedReason == LoadI3DFailedReason.FILE_NOT_FOUND or failedReason == LoadI3DFailedReason.UNKNOWN then
            Logging.error("[%s.SequencedParticleEffect] Failed to load particle effect I3D with filename '%s'", modName, filename)
        end
    else
        local defaultFillType = Effect.getValue(xmlFile, key, node, "defaultFillType")

        if defaultFillType ~= nil then
            self.defaultFillType = g_fillTypeManager:getFillTypeIndexByName(defaultFillType)
            self.dynamicFillType = Effect.getValue(xmlFile, key, node, "dynamicFillType", true)

            if not self.dynamicFillType then
                self:setFillType(self.defaultFillType)
            end
        end
    end

    return true
end

function SequencedParticleEffect:update(dt)
    if self.effectEnabled and self.useSequenceTimes then
        self.currentSequenceTime = self.currentSequenceTime - dt

        if self.currentSequenceTime <= 0 then
            if self.isActive then
                SequencedParticleEffect:superClass().stop(self)
                self.currentSequenceTime = self.sequenceOffTime
            else
                SequencedParticleEffect:superClass().start(self)
                self.currentSequenceTime = self.sequenceOnTime
            end
        end
    end

    if self.isActive then
        SequencedParticleEffect:superClass().update(self, dt)
    end
end

function SequencedParticleEffect:isRunning()
    if self.effectEnabled and self.useSequenceTimes then
        return true
    end

    return self.isActive
end

function SequencedParticleEffect:start()
    self.effectEnabled = true
    self.currentSequenceTime = self.sequenceOnTime

    return SequencedParticleEffect:superClass().start(self)
end

function SequencedParticleEffect:stop()
    self.effectEnabled = false
    self.currentSequenceTime = self.sequenceOffTime

    return SequencedParticleEffect:superClass().stop(self)
end

function SequencedParticleEffect:reset()
    if self.isCustomEffect then
        ParticleUtil.resetNumOfEmittedParticles(self.particleSystem)
    end

    ParticleUtil.setEmittingState(self.particleSystem, false)

    self.realStopTime = math.huge
    self.isActive = false

    self.effectEnabled = false
    self.currentSequenceTime = self.sequenceOffTime
end

function SequencedParticleEffect:setFillType(fillType)
    if self.isCustomEffect then
        self.currentFillType = FillType.UNKNOWN

        return true
    end

    return SequencedParticleEffect:superClass().setFillType(self, fillType)
end

function SequencedParticleEffect.registerEffectXMLPaths(schema, basePath)
    ParticleEffect.registerEffectXMLPaths(schema, basePath .. ".effectNode(?)")

    schema:register(XMLValueType.STRING, basePath .. ".effectNode(?)#file", "(SequencedParticleEffect) Particle file name. Used to load directly from i3d.")
    schema:register(XMLValueType.BOOL, basePath .. ".effectNode(?)#callOnCreate", "(SequencedParticleEffect) Call onCreate that is part of file when loading", false)
    schema:register(XMLValueType.STRING, basePath .. ".effectNode(?)#particleNode", "(SequencedParticleEffect) Particle node in loaded file")
    schema:register(XMLValueType.BOOL, basePath .. ".effectNode(?)#forceFullLifespan", "(SequencedParticleEffect) Force full lifespan", false)
    schema:register(XMLValueType.BOOL, basePath .. ".effectNode(?)#useEmitterVisibility", "(SequencedParticleEffect) Use emitter visibility to show / hide particles", false)

    schema:register(XMLValueType.FLOAT, basePath .. ".effectNode(?)#sequenceOnTime", "(SequencedParticleEffect) When used with 'sequenceOffTime' this is the time the effect is active for in sequence (sec.)", 0)
    schema:register(XMLValueType.FLOAT, basePath .. ".effectNode(?)#sequenceOffTime", "(SequencedParticleEffect) When used with 'sequenceOnTime' this is the time the effect is inactive for in sequence (sec.)", 0)

    schema:register(XMLValueType.STRING, basePath .. "#defaultFillType", "(SequencedParticleEffect) Default fill type name, not available when using '#file'")
    schema:register(XMLValueType.BOOL, basePath .. "#dynamicFillType", "(SequencedParticleEffect) Dynamic fill type, not available when using '#file'", false)
end

-- There is no way to add custom effect nodes to registration without manually doing this, here is a work around.
-- Other modders are free to use the below code as part of their own Effect scripts but please do not modify as it must support all mod scripts and no need for multiple appended functions
if EffectManager.CUSTOM_CLASSES_TO_REGISTER_XML_PATH == nil then
    EffectManager.CUSTOM_CLASSES_TO_REGISTER_XML_PATH = {}

    EffectManager.registerEffectXMLPaths = Utils.appendedFunction(EffectManager.registerEffectXMLPaths, function(schema, basePath)
        local classes = EffectManager.CUSTOM_CLASSES_TO_REGISTER_XML_PATH

        if classes == nil and g_effectManager.registeredEffectClasses ~= nil then
            classes = g_effectManager.registeredEffectClasses
        end

        if classes ~= nil then
            schema:setXMLSharedRegistration("EffectNode", basePath)

            for className, effectClass in pairs (classes) do
                if string.find(tostring(className), ".") and rawget(effectClass, "registerEffectXMLPaths") then
                    effectClass.registerEffectXMLPaths(schema, basePath)
                end
            end

            schema:setXMLSharedRegistration()
        end
    end)
end

-- Add class to the table so it will be available
EffectManager.CUSTOM_CLASSES_TO_REGISTER_XML_PATH[customClassName] = SequencedParticleEffect

-- Unlike Animation manager this register function is localised, i.e 'modName.className'
g_effectManager:registerEffectClass("SequencedParticleEffect", SequencedParticleEffect)
