﻿  package septenary.duelparty {	import flash.geom.Rectangle;	import flash.geom.Point;	import flash.display.Sprite;	import com.greensock.TweenLite;	    public class BattleBehaviours {        public static function mortarAttackBehaviour(fighter:Fighter, targFightable:Fightable, attackFront:Boolean, callback:Function):void {			const sourceRadius:Number = 10;			const sourceOffset:Point = new Point(0, -5);						var targFighterPoint:Point = pointForTargFighter(targFightable, attackFront);			var targPt = targFighterPoint != null ? targFighterPoint : pointForTargFightable(targFightable);						function projectileDone():void {				callback();				}			function weaponRotated():void {				var sourcePt:Point = new Point(fighter.weapon.x + sourceRadius * Math.cos(fighter.weapon.rotation) + sourceOffset.x,											   fighter.weapon.y + sourceRadius * Math.sin(fighter.weapon.rotation) + sourceOffset.y);				trace("SOURCE PT:", sourcePt, "ROTATION:", fighter.weapon.rotation);				sourcePt = GameBoard.getGameBoard().field.globalToLocal(fighter.localToGlobal(sourcePt));				ProjectileBurstFactory.createProjectileBurst(ProjectileBurstFactory.CANNONBALL_TYPE, sourcePt, targPt, projectileDone);			}						rotateWeaponToFacePoint(fighter, targPt, weaponRotated);		}				protected static function pointForTargFightable(targFightable:Fightable):Point {			var targSprite:Sprite = targFightable as Sprite;			return new Point(targSprite.x, targSprite.y);		}				protected static function pointForTargFighter(targFightable:Fightable, attackFront:Boolean):Point {			var targFighter:Fighter = attackFront ? targFightable.getForeGuard() : targFightable.getRearGuard();			return targFighter != null ? new Point(targFighter.x, targFighter.y) : null;		}				protected static function randomPointInTargetRect(targetRect:Rectangle):Point {			var randX:Number = Math.random() * targetRect.width + targetRect.x;			var randY:Number = Math.random() * targetRect.height + targetRect.y;			return new Point(randX, randY);		}				protected static function rotateWeaponToFacePoint(fighter:Fighter, pt:Point, callback:Function):void {           	const rotSpeed:Number = 100;            var rot:Number = Math.atan2(pt.y - fighter.y, pt.x - fighter.x);			var rotDiff:Number = Utilities.angleDiff(fighter.weapon.rotation, rot);			TweenLite.to(fighter.weapon, rotDiff/rotSpeed, {shortRotation:{rotation:(rot * 180 / Math.PI)}, onComplete:callback});        }    }}