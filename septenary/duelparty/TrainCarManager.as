package septenary.duelparty {
    import flash.geom.Point;
    import flash.events.EventDispatcher;

    public class TrainCarManager extends EventDispatcher {

        protected var _frontCar:TrainCarMovement;

        public function TrainCarManager(frontCar:TrainCarMovement) {
            _frontCar = frontCar;
        }

        public function update():void {
            executeFunctionOnCars("update");
        }

        public function executeFunctionOnCars(funcName:String, args:Array=null, includeFront:Boolean=true):void {
            var nextCar:TrainCarMovement = includeFront ? _frontCar : _frontCar.carBehind;
            while (nextCar != null) {
                nextCar[funcName].apply(nextCar, args);
                nextCar = nextCar.carBehind;
            }
        }

        public function attachCar(car:TrainCarMovement, toFront:Boolean):void {
            if (car.manager != this) car.manager = this;
            
            if (toFront) {
                _frontCar.insertCar(car, toFront);
                _frontCar = car;
            } else {
                getBackCar().insertCar(car, toFront);
            }
        }

        public function detatchCar(fromFront:Boolean):void {
            if (fromFront) {
                _frontCar = _frontCar.carBehind;
                _frontCar.carAhead = null;
            } else {
                var backCar:TrainCarMovement = getBackCar();
                if (backCar.carAhead) {
                    backCar.carAhead.carBehind = null;
                }
            }
        }

        public function switchFightersAroundCar(car:TrainCarMovement):void {
            car.switchSurroundingCars();

            var nextCar:TrainCarMovement = car;
            while (nextCar != null) {
                _frontCar = nextCar;
                nextCar = nextCar.carAhead;
            }

            dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE));
        }

        public function moveTo(pt:Point, callback:Function=null):void {
            _frontCar.moveTo(pt, callback);
        }

        public function pushPulleyFromFront():void {
            _frontCar.pushPulleyBack();
        }

        public function reverseDirection():void {
            var thisCar:TrainCarMovement = _frontCar, nextCar:TrainCarMovement;
            while (thisCar != null) {
                //Reverse doubly-linked list
                nextCar = thisCar.carBehind;
                thisCar.carBehind = thisCar.carAhead;
                thisCar.carAhead = nextCar;

                if (thisCar.carAhead == null){
                    thisCar.faceOppositeDirection();
                } else {
                    thisCar.rotateToFaceCarAhead();
                }

                _frontCar = thisCar;
                thisCar = nextCar;
            }
        }

        protected function getBackCar():TrainCarMovement {
            var nextCar:TrainCarMovement = _frontCar;
            while (nextCar.carBehind != null) {
                nextCar = nextCar.carBehind;
            }
            return nextCar;
        }
    }
}