package septenary.duelparty {
    import flash.display.Sprite;

    public interface Fightmaster {
        function getDisplay():Sprite;
        
        function getForeGuard():Fighter;
        function getRearGuard():Fighter;
        function isFacingForward():Boolean;
        function damage(damage:int, fromFront:Boolean, fromCounter:Boolean):void;
        function payoutBounty():Object;
    }
}