package core;

import flixel.FlxG;

import flixel.input.FlxInput.FlxInputState;

import flixel.input.keyboard.FlxKey;

class Inputs
{
    public static var list:Map<String, Array<FlxKey>> =
    [
        "NOTE:LEFT" => [FlxKey.Z, FlxKey.LEFT],

        "NOTE:DOWN" => [FlxKey.X, FlxKey.DOWN],

        "NOTE:UP" => [FlxKey.PERIOD, FlxKey.UP],

        "NOTE:RIGHT" => [FlxKey.SLASH, FlxKey.RIGHT],

        "UI:ACCEPT" => [FlxKey.ENTER],

        "UI:CANCEL" => [FlxKey.BACKSPACE],

        "DEBUG:0" => [FlxKey.EIGHT]
    ];

    public static function checkStatus(input:String, status:FlxInputState):Null<Bool>
    {
        if (!list.exists(input))
        {
            return null;
        }

        for (i in 0 ... list[input].length)
        {
            if (FlxG.keys.checkStatus(list[input][i], status))
            {
                return true;
            }
        }

        return false;
    }

    public static function inputsJustPressed(inputs:Array<String>):Null<Bool>
    {
        for (i in 0 ... inputs.length)
        {
            if (!list.exists(inputs[i]))
            {
                return null;
            }

            if (checkStatus(inputs[i], JUST_PRESSED))
            {
                return true;
            }
        }

        return false;
    }

    public static function inputsPressed(inputs:Array<String>):Null<Bool>
    {
        for (i in 0 ... inputs.length)
        {
            if (!list.exists(inputs[i]))
            {
                return null;
            }

            if (checkStatus(inputs[i], PRESSED))
            {
                return true;
            }
        }

        return false;
    }

    public static function inputsJustReleased(inputs:Array<String>):Null<Bool>
    {
        for (i in 0 ... inputs.length)
        {
            if (!list.exists(inputs[i]))
            {
                return null;
            }

            if (checkStatus(inputs[i], JUST_RELEASED))
            {
                return true;
            }
        }

        return false;
    }

    public static function inputsReleased(inputs:Array<String>):Null<Bool>
    {
        for (i in 0 ... inputs.length)
        {
            if (!list.exists(inputs[i]))
            {
                return null;
            }

            if (checkStatus(inputs[i], RELEASED))
            {
                return true;
            }
        }

        return false;
    }
}