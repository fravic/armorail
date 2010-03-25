package septenary.duelparty.pmovement {
    import septenary.duelparty.Projectile;
    import flash.geom.Point;

    public interface MovementBehaviour {
        function move(proj:Projectile):Object;
    }
}