package septenary.duelparty {
    public interface Fightable {
        function getForeGuard():Fighter;
        function getRearGuard():Fighter;
        function isFacingForward():Boolean;
        function damage(damage:int, fromFront:Boolean, fromCounter:Boolean):void;
        function payoutBounty():int;
    }
}