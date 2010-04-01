package septenary.duelparty {
    public interface Fightmaster {
        function getForeGuard():Fighter;
        function getRearGuard():Fighter;
        function isFacingForward():Boolean;
        function damage(damage:int, fromFront:Boolean, fromCounter:Boolean):void;
        function payoutBounty():Object;
    }
}