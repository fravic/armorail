package septenary.duelparty.projectiles {
    import septenary.duelparty.Projectile;
    import flash.geom.Point;

    public interface IMovementBehaviour {
        function move(proj:Projectile):Object;
    }
}