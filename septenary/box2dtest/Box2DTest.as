package septenary.box2dtest {
	import flash.display.Sprite;
	import flash.events.TimerEvent;
    import flash.utils.setInterval;

    import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Common.*;
	import Box2D.Common.Math.*;

    public class Box2DTest extends Sprite {

        private static const B2_VELOCITY_ITERATIONS:int = 10;
		private static const B2_POSITION_ITERATIONS:int = 10;
		private static const B2_TIME_STEP:Number = 1.0/30.0;
        private static const B2_PIXEL_SCALE:Number = 30;

        private var _world:b2World;
        private var _debugSprite:Sprite;

        private var _body:b2Body;
        private var _bodyJoint:b2Joint;
        private var _jointStatus:int = 0;

		public function Box2DTest():void {
            //Create world box
            var worldAABB:b2AABB = new b2AABB();
			worldAABB.lowerBound.Set(-1000.0, -1000.0);
			worldAABB.upperBound.Set(1000.0, 1000.0);

			//Define the gravity vector
			var gravity:b2Vec2 = new b2Vec2(0.0, 0.0);

			//Allow bodies to sleep
			var doSleep:Boolean = true;

			//Construct a world object
			_world = new b2World(gravity, doSleep);
			_world.SetWarmStarting(true);

			//Set debug draw
            _debugSprite = new Sprite();
            addChild(_debugSprite);
            
			var dbgDraw:b2DebugDraw = new b2DebugDraw();
            dbgDraw.SetSprite(_debugSprite);
			dbgDraw.SetDrawScale(30.0);
			dbgDraw.SetFillAlpha(0.3);
			dbgDraw.SetLineThickness(1.0);
			dbgDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			_world.SetDebugDraw(dbgDraw);

            var box1:b2Body = createAndAddBox(70, 100);
            var box2:b2Body = createAndAddBox(230, 100);

            //Join boxes
            var connect:b2Body = createAndAddConnector(150,100);
            var jP12:b2Vec2 = connect.GetPosition();
            jP12.Add(new b2Vec2(-50/B2_PIXEL_SCALE, 0));
            var jP22:b2Vec2 = connect.GetPosition();
            jP22.Add(new b2Vec2(50/B2_PIXEL_SCALE, 0));

            var jointDef:b2JointDef;

            jointDef = new b2RevoluteJointDef();
            (jointDef as b2RevoluteJointDef).Initialize(box1, connect, jP12);
            _world.CreateJoint(jointDef);

            jointDef = new b2RevoluteJointDef();
            (jointDef as b2RevoluteJointDef).Initialize(box2, connect, jP22);
            _world.CreateJoint(jointDef);

            //Join boxes to rail
            /*jointDef = new b2LineJointDef();
            (jointDef as b2LineJointDef).Initialize(_world.GetGroundBody(), box1, box1.GetWorldCenter(), new b2Vec2(0.0, 1.0));
            _bodyJoint =_world.CreateJoint(jointDef);
            _body = box1;
            jointDef = new b2PrismaticJointDef();
            (jointDef as b2PrismaticJointDef).Initialize(_world.GetGroundBody(), box2, box2.GetWorldCenter(), new b2Vec2(1.0, 0.0));
            _world.CreateJoint(jointDef);*/

            //Start update timer
            setInterval(update, B2_TIME_STEP * 1000);
		}

		public function update():void {
            _world.Step(B2_TIME_STEP, B2_VELOCITY_ITERATIONS, B2_POSITION_ITERATIONS);
			_world.ClearForces();
            _world.DrawDebugData();

            for (var bb:b2Body = _world.GetBodyList(); bb; bb = bb.GetNext()){
				if (bb.GetUserData() is Sprite){
					var sprite:Sprite = bb.GetUserData() as Sprite;
					sprite.x = bb.GetPosition().x * 30;
					sprite.y = bb.GetPosition().y * 30;
					sprite.rotation = bb.GetAngle() * (180/Math.PI);

                    if (bb != _body) bb.ApplyForce(new b2Vec2(50, 0), bb.GetWorldCenter());
                    else bb.ApplyForce(new b2Vec2(0, 10), bb.GetWorldCenter());
				}
			}

            /*if (_jointStatus == 0 && _body.GetUserData().y >= 120) {
                _world.DestroyJoint(_bodyJoint);
                var jointDef3:b2LineJointDef = new b2LineJointDef();
                jointDef3.Initialize(_world.GetGroundBody(), _body, _body.GetWorldCenter(), new b2Vec2(1.0, 1.0));
                _bodyJoint = _world.CreateJoint(jointDef3);
                _jointStatus++;
            } else if (_jointStatus == 1 && _body.GetUserData().y >= 160) {
                _world.DestroyJoint(_bodyJoint);
                var jointDef4:b2LineJointDef = new b2LineJointDef();
                jointDef4.Initialize(_world.GetGroundBody(), _body, _body.GetWorldCenter(), new b2Vec2(1.0, 0.0));
                _bodyJoint = _world.CreateJoint(jointDef4);
                _jointStatus++;
            }*/
		}

        private function createAndAddBox(x:Number, y:Number):b2Body {
            //Create body
            var bdyDef:b2BodyDef = new b2BodyDef();
            bdyDef.type = b2Body.b2_dynamicBody;
            bdyDef.position.Set(x/B2_PIXEL_SCALE, y/B2_PIXEL_SCALE);
            bdyDef.userData = new Box();
            var bdy:b2Body = _world.CreateBody(bdyDef);

            //Fix (add) shapes
            var fixtureDef:b2FixtureDef = new b2FixtureDef();
            var shp:b2PolygonShape = new b2PolygonShape();
            shp.SetAsBox(30 / B2_PIXEL_SCALE, 30.0 / B2_PIXEL_SCALE);
            fixtureDef.shape = shp;
            fixtureDef.density = 1.0;
            bdy.CreateFixture(fixtureDef);

            addChild(bdyDef.userData);
            return bdy;
        }

        private function createAndAddConnector(x:Number, y:Number):b2Body {
            //Create body
            var bdyDef:b2BodyDef = new b2BodyDef();
            bdyDef.type = b2Body.b2_dynamicBody;
            bdyDef.position.Set(x/B2_PIXEL_SCALE, y/B2_PIXEL_SCALE);
            bdyDef.userData = new Connector();
            var bdy:b2Body = _world.CreateBody(bdyDef);

            //Fix (add) shapes
            var fixtureDef:b2FixtureDef = new b2FixtureDef();
            var shp:b2PolygonShape = new b2PolygonShape();
            shp.SetAsBox(84 / B2_PIXEL_SCALE, 7 / B2_PIXEL_SCALE);
            fixtureDef.shape = shp;
            fixtureDef.density = 1.0;
            bdy.CreateFixture(fixtureDef);

            addChild(bdyDef.userData);
            return bdy;
        }
	}
}
