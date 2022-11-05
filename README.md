# Effect Nodes for Farming Simulator 22

 `Farming Simulator  22`   `Game Version: 1.8.1.0`

## Usage
These scripts are free for use in any Farming Simulator 22 **Map** , **Placeable** or **Vehicle** mod for both ***Private*** and ***Public*** release.

## Publishing
The publishing of these scripts when not included in its entirety as part of a **Map** , **Placeable** or **Vehicle** mod is not permitted.

## Modification / Converting
Only GtX | Andy is permitted to make modifications to this code including but not limited to bug fixes, enhancements or the addition of new features.

Converting these scripts or parts there of to other version of the Farming Simulator series is not permitted without written approval from GtX | Andy.

## Versioning
All versioning is controlled by GtX | Andy and not by any other page, individual or company.

## Documentation
These effect scripts require the parent to make use of the g_effectManager.

Note: Some specializations do not correctly assign the mod custom environment correctly, for example version 1.8.1.0 of the base game **ProductionPoint** does not correctly do this so it must be manually set.

If you receive an invalid class name message you will need to add the mod name to the start of the class name.

Example: `FS22_MyGreatMod.SequencedMorphPositionEffect` or `FS22_MyGreatMod.SequencedParticleEffect` or `FS22_MyGreatMod.SequencedPipeEffect` or `FS22_MyGreatMod.SequencedShaderPlaneEffect`

>### SequencedMorphPositionEffect

This effect has the same features as the base 'MorphPositionEffect' class but adds the possibility to use `sequenceOnTime` and `sequenceOffTime` to create more immersive mods. Sequenced times are calculated in seconds.

```xml
<modDesc descVersion="71">
    <extraSourceFiles>
        <sourceFile filename="SequencedMorphPositionEffect.lua"/>
    </extraSourceFiles>
</modDesc>

<placeable type="productionPoint">
    </productionPoint>
        <effectNodes>
            <effectNode effectNode="node" effectClass="FS22_MyGreatMod.SequencedMorphPositionEffect" dynamicFillType="false" defaultFillType="WHEAT" materialType="belt" delay="0" fadeTime="3" speed="0.9" scrollLength="5" scrollSpeed="0.8" sequenceOnTime="7" sequenceOffTime="9"/>
        </effectNodes>
    </productionPoint>
</placeable>
```

>### SequencedPipeEffect

This effect has the same features as the base 'PipeEffect' class but adds the possibility to use `sequenceOnTime` and `sequenceOffTime` to create more immersive mods. Sequenced times are calculated in seconds.

```xml
<modDesc descVersion="71">
    <extraSourceFiles>
        <sourceFile filename="SequencedPipeEffect.lua"/>
    </extraSourceFiles>
</modDesc>

<placeable type="productionPoint">
    </productionPoint>
        <effectNodes>
            <effectNode effectNode="node" effectClass="FS22_MyGreatMod.SequencedPipeEffect" materialType="UNLOADING" startDelay="3.5" sequenceOnTime="9.5" sequenceOffTime="6.5" />
        </effectNodes>
    </productionPoint>
</placeable>
```

>### SequencedShaderPlaneEffect

This effect has the same features as the base 'ShaderPlaneEffect' class but adds the possibility to use `sequenceOnTime` and `sequenceOffTime` to create more immersive mods. Sequenced times are calculated in seconds.

```xml
<modDesc descVersion="71">
    <extraSourceFiles>
        <sourceFile filename="SequencedShaderPlaneEffect.lua"/>
    </extraSourceFiles>
</modDesc>

<placeable type="productionPoint">
    </productionPoint>
        <effectNodes>
            <effectNode effectNode="node" effectClass="FS22_MyGreatMod.SequencedShaderPlaneEffect" materialType="unloadingSmoke" fadeTime="0.5" startDelay="3.5" sequenceOnTime="9.5" sequenceOffTime="6.5"/>
        </effectNodes>
    </productionPoint>
</placeable>
```

>### SequencedParticleEffect

This effect has the same features as the base 'ParticleEffect' class but adds the possibility to use `sequenceOnTime` and `sequenceOffTime` to create more immersive mods. Sequenced times are calculated in seconds.
It is also possible to use shared particle effects or an emitter directly in the mod i3d.


```xml
<modDesc descVersion="71">
    <extraSourceFiles>
        <sourceFile filename="SequencedParticleEffect.lua"/>
    </extraSourceFiles>
</modDesc>

<placeable type="productionPoint">
    </productionPoint>

        <effectNodes>
            <!-- Emitter as part of the mod -- >
            <effectNode effectNode="node" effectClass="FS22_MyGreatMod.SequencedParticleEffect" dynamicFillType="false" defaultFillType="WHEAT" materialType="unloadingParticle" delay="3" sequenceOnTime="7" sequenceOffTime="9"/>

            <!-- Shared particle effect load from I3D -- >
            <effectNode effectNode="smokeLinkNode" effectClass="FS22_MyGreatMod.SequencedParticleEffect" file="$data/effects/smoke/industrial/smokeParticles.i3d" startTime="3"/>
        </effectNodes>
    </productionPoint>
</placeable>
```

## Copyright
Copyright (c) 2022 [GtX (Andy)](https://github.com/GtX-Andy)