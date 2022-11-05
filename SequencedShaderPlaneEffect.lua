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

SequencedShaderPlaneEffect = {}

local modName = g_currentModName or ""
local modDirectory = g_currentModDirectory or ""

local customClassName = modName .. ".SequencedShaderPlaneEffect"
local SequencedShaderPlaneEffect_mt = Class(SequencedShaderPlaneEffect, ShaderPlaneEffect)

function SequencedShaderPlaneEffect.new(customMt)
    local self = ShaderPlaneEffect.new(customMt or SequencedShaderPlaneEffect_mt)

    self.sequenceOnTime = 0
    self.sequenceOffTime = 0

    self.useSequenceTimes = false
    self.currentSequenceTime = 0

    self.effectEnabled = false

    return self
end

function SequencedShaderPlaneEffect:loadEffectAttributes(xmlFile, key, node, i3dNode, i3dMapping)
    if not SequencedShaderPlaneEffect:superClass().loadEffectAttributes(self, xmlFile, key, node, i3dNode, i3dMapping) then
        return false
    end

    self.sequenceOnTime = (Effect.getValue(xmlFile, key, node, "sequenceOnTime", 0) or 0) * 1000
    self.sequenceOffTime = (Effect.getValue(xmlFile, key, node, "sequenceOffTime", 0) or 0) * 1000

    self.useSequenceTimes = self.sequenceOnTime > 0 and self.sequenceOffTime > 0

    return true
end

function SequencedShaderPlaneEffect:update(dt)
    if self.effectEnabled and self.useSequenceTimes then
        self.currentSequenceTime = self.currentSequenceTime - dt

        if self.currentSequenceTime <= 0 then
            if (self.state == ShaderPlaneEffect.STATE_OFF or self.state == ShaderPlaneEffect.STATE_TURNING_OFF) then
                SequencedShaderPlaneEffect:superClass().start(self)
                self.currentSequenceTime = self.sequenceOnTime
            else
                SequencedShaderPlaneEffect:superClass().stop(self)
                self.currentSequenceTime = self.sequenceOffTime
            end
        end
    end

    if self.state ~= ShaderPlaneEffect.STATE_OFF then
        SequencedShaderPlaneEffect:superClass().update(self, dt)
    end
end

function SequencedShaderPlaneEffect:isRunning()
    if self.effectEnabled and self.useSequenceTimes then
        return true
    end

    return self.state ~= ShaderPlaneEffect.STATE_OFF
end

function SequencedShaderPlaneEffect:start()
    self.effectEnabled = true
    self.currentSequenceTime = self.sequenceOnTime

    return SequencedShaderPlaneEffect:superClass().start(self)
end

function SequencedShaderPlaneEffect:stop()
    self.effectEnabled = false
    self.currentSequenceTime = self.sequenceOffTime

    return SequencedShaderPlaneEffect:superClass().stop(self)
end

function SequencedShaderPlaneEffect:reset()
    SequencedShaderPlaneEffect:superClass().reset(self)

    self.effectEnabled = false
    self.currentSequenceTime = self.sequenceOffTime
end

function SequencedShaderPlaneEffect.registerEffectXMLPaths(schema, basePath)
    ShaderPlaneEffect.registerEffectXMLPaths(schema, basePath .. ".effectNode(?)")

    schema:register(XMLValueType.FLOAT, basePath .. ".effectNode(?)#sequenceOnTime", "(SequencedShaderPlaneEffect) When used with 'sequenceOffTime' this is the time the effect is active for in sequence (sec.)", 0)
    schema:register(XMLValueType.FLOAT, basePath .. ".effectNode(?)#sequenceOffTime", "(SequencedShaderPlaneEffect) When used with 'sequenceOnTime' this is the time the effect is inactive for in sequence (sec.)", 0)
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
EffectManager.CUSTOM_CLASSES_TO_REGISTER_XML_PATH[customClassName] = SequencedShaderPlaneEffect

-- Unlike Animation manager this register function is localised, i.e 'modName.className'
g_effectManager:registerEffectClass("SequencedShaderPlaneEffect", SequencedShaderPlaneEffect)
