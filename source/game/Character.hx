package game;

import haxe.Json;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import flixel.math.FlxMath;
import flixel.math.FlxPoint;

import core.AssetMan;
import core.Conductor;
import core.Inputs;
import core.Paths;

using StringTools;

class Character extends FlxSprite
{
    public static function findConfig(path:String):CharacterConfig
    {
        return Json.parse(AssetMan.text(Paths.json(path)));
    }
    
    public var conductor(default, set):Conductor;

    @:noCompletion
    function set_conductor(conductor:Conductor):Conductor
    {
        this.conductor?.beatHit?.remove(beatHit);

        conductor?.beatHit?.add(beatHit);

        return this.conductor = conductor;
    }

    public var inputs:Array<Input>;
    
    public var config:CharacterConfig;

    public var danceSteps:Array<String>;

    public var danceStep:Int;

    public var danceInterval:Float;

    public var singDuration:Float;

    public var skipDance:Bool;

    public var skipSing:Bool;

    public var singCount:Float;

    public var role:CharacterRole;

    public function new(conductor:Conductor, x:Float = 0.0, y:Float = 0.0, config:CharacterConfig, role:CharacterRole):Void
    {
        super(x, y);

        this.conductor = conductor;

        inputs =
        [
            new Input([90, 65, 37]),

            new Input([88, 83, 40]),

            new Input([190, 87, 38]),

            new Input([191, 68, 39])
        ];
        
        this.config = config;

        switch (config.format ?? "".toLowerCase():String)
        {
            case "sparrow": frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png(config.png)), Paths.xml(config.xml));

            case "texturepackerxml": frames = FlxAtlasFrames.fromTexturePackerXml(AssetMan.graphic(Paths.png(config.png)), Paths.xml(config.xml));
        }

        antialiasing = config.antialiasing ?? true;

        scale.set(config.scale?.x ?? 1.0, config.scale?.y ?? 1.0);

        updateHitbox();

        flipX = config.flipX ?? false;

        flipY = config.flipY ?? false;

        for (i in 0 ... config.frames.length)
        {
            var _frames:CharacterFramesConfig = config.frames[i];

            if (animation.exists(_frames.name))
                throw "game.Character: Invalid animation name!";

            if (_frames.indices.length > 0)
            {
                animation.addByIndices
                (
                    _frames.name,

                    _frames.prefix,

                    _frames.indices,

                    "",

                    _frames.frameRate ?? 24.0,

                    _frames.looped ?? false,

                    _frames.flipX ?? false,

                    _frames.flipY ?? false
                );
            }
            else
            {
                animation.addByPrefix
                (
                    _frames.name,

                    _frames.prefix,

                    _frames.frameRate ?? 24.0,

                    _frames.looped ?? false,

                    _frames.flipX ?? false,

                    _frames.flipY ?? false
                );
            }
        }

        danceSteps = config.danceSteps;

        danceStep = 0;

        danceInterval = config.danceInterval ?? 2.0;

        singDuration = config.singDuration ?? 8.0;

        skipDance = false;

        skipSing = false;

        singCount = 0.0;

        this.role = role;

        dance();

        animation.finish();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (conductor == null)
            return;

        if (Inputs.inputsJustPressed(inputs) && role == PLAYABLE)
            singCount = 0.0;

        if ((animation.name ?? "").startsWith("Sing"))
        {
            singCount += elapsed;

            var requiredTime:Float = singDuration * ((conductor.crotchet * 0.25) * 0.001);

            if ((animation.name ?? "").endsWith("MISS"))
                requiredTime *= FlxG.random.float(1.35, 1.85);

            if (singCount >= requiredTime && (role == PLAYABLE ? !Inputs.inputsPressed(inputs) : true))
            {
                singCount = 0.0;
                
                dance(true);
            }
        }
        else
            singCount = 0.0;
    }

    override function destroy():Void
    {
        super.destroy();

        conductor?.beatHit?.remove(beatHit);
    }

    override function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
    {
        var output:FlxPoint = super.getScreenPosition(result, camera);

        for (i in 0 ... config.frames.length)
        {
            var _frames:CharacterFramesConfig = config.frames[i];
            
            if (animation.name ?? "" == _frames.name)
                output.add(_frames.offset?.x ?? 0.0, _frames.offset?.y ?? 0.0);
        }

        return output;
    }

    public function beatHit(beat:Int):Void
    {
        if (beat % danceInterval == 0.0)
            dance();
    }

    public function dance(forceful:Bool = false):Void
    {
        if (skipDance)
            return;
        
        if (!forceful && (animation.name ?? "").startsWith("Sing"))
            return;

        animation.play(danceSteps[danceStep = FlxMath.wrap(danceStep + 1, 0, danceSteps.length - 1)], forceful);
    }
}

typedef CharacterConfig =
{
    var name:String;
    
    var format:String;

    var png:String;

    var xml:String;

    var ?antialiasing:Bool;

    var ?scale:{?x:Float, ?y:Float};

    var ?flipX:Bool;

    var ?flipY:Bool;

    var frames:Array<CharacterFramesConfig>;

    var danceSteps:Array<String>;

    var ?danceInterval:Float;

    var ?singDuration:Float;
};

typedef CharacterFramesConfig =
{
    var name:String;
    
    var prefix:String;
    
    var indices:Array<Int>;
    
    var ?frameRate:Float;
    
    var ?looped:Bool;
    
    var ?flipX:Bool;
    
    var ?flipY:Bool;

    var ?offset:{?x:Float, ?y:Float};
};

enum abstract CharacterRole(String) from String to String
{
    var ARTIFICIAL:CharacterRole;

    var PLAYABLE:CharacterRole;

    var OTHER:CharacterRole;
}